function varargout = traindlncust(data, layers, kwargs)
    %% Custom train loop of deep neural network by given settings.

    arguments
        %% main paramters
        data {mustBeA(data, {'matlab.io.datastore.CombinedDatastore'})}
        layers (:,:) {mustBeA(layers, {'nnet.cnn.layer.Layer', 'dlnetwork'})}
        %% train settings
        kwargs.background (1,1) logical = false
        kwargs.lossfnc {mustBeA(kwargs.lossfnc, {'cell', 'function_handle'})} = {}
        %% learn rate settings
        kwargs.InitialLearnRate (1,:) double = 1e-2
        kwargs.learnRate {mustBeA(kwargs.learnRate, {'cell', 'function_handle'})} = {}
        kwargs.decay (1,1) double = 0.01
        kwargs.momentum (1,1) double = 0.9
        %% regularization settings
        kwargs.regul {mustBeA(kwargs.regul, {'double', 'function_handle'})} = []
        %% evaluation settings
        kwargs.MaxEpochs (1,1) double {mustBeInteger(kwargs.MaxEpochs), mustBeGreaterThanOrEqual(kwargs.MaxEpochs, 1)} = 10
        kwargs.ValidationData {mustBeA(kwargs.ValidationData, {'double', 'matlab.io.datastore.CombinedDatastore'})} = []
        kwargs.ValidationFrequency (1,1) double = 10
        kwargs.TestingData {mustBeA(kwargs.TestingData, {'double', 'matlab.io.datastore.CombinedDatastore'})} = []
        kwargs.testmonitorfnc {mustBeA(kwargs.testmonitorfnc, {'double', 'function_handle'})} = []
        %% mini-batch settings
        kwargs.MiniBatchSize (1,1) {mustBeInteger(kwargs.MiniBatchSize), mustBeGreaterThanOrEqual(kwargs.MiniBatchSize, 1)} = 12
        kwargs.MiniBatchFormat (1,:) {mustBeA(kwargs.MiniBatchFormat, {'string', 'char', 'cell'})} = ["SSBC", "BC"]
        %% monitor settings
        kwargs.monitorqueue parallel.pool.DataQueue = parallel.pool.DataQueue
        kwargs.monitorfnc {mustBeA(kwargs.monitorfnc, {'cell', 'function_handle'})} = {}
        kwargs.MonitorFrequency (1,1) double = 1
    end

    function [loss, gradients, state, Y] = losseval(net, X, T, lossfnc, regul)
        [Y, state] = forward(net, X);
        loss = lossfnc(Y, T);
        loss = regul(loss, Y, T);
        gradients = dlgradient(loss, net.Learnables);
    end

    function loss = validlosseval(net, mbq, lossfnc)
        loss = []; shuffle(mbq);
        while hasdata(mbq)
            [X, T] = next(mbq);
            Y = predict(net, X);
            loss = [loss, lossfnc(Y, T)];
        end
        loss = mean(loss);
    end

    function [targ, pred, score] = predtestfnc(net, kwargs)
        mnq = minibatchqueue(kwargs.TestingData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
        targ = {}; pred = {}; score = [];
        while hasdata(mnq)
            [X, T] = next(mnq);
            Y = predict(net, X);
            score = cat(2, score, kwargs.lossfnc(Y,T));
            targ = cat(2, targ, gather(extractdata(T)));
            pred = cat(2, pred, gather(extractdata(Y)));
        end
        targ = cell2mat(targ);
        pred = cell2mat(pred);
        score = mean(score);
    end

    function net = trainloop(net, mbq, kwargs)
        packet = struct(i = [], x = [], y = [], t = [], loss = [], lossind = [], validloss = [], validlossind = []);

        % counters
        epoch = 0; iteration = 0; validinc = -kwargs.ValidationFrequency;
        velocity = []; monitorinc = -kwargs.MonitorFrequency;
        
        % loop over epochs
        while epoch < kwargs.MaxEpochs
            epoch = epoch + 1;
            shuffle(mbq);

            % loop over mini-batches
            while hasdata(mbq)
                iteration = iteration + 1;
                
                % read mini-batch of data
                [X, T] = next(mbq);
                
                % evaluate the model gradients, state, and loss
                [loss, gradients, state, Y] = dlfeval(@kwargs.losseval, net, X, T);
                net.State = state;

                % validation
                if ~isempty(kwargs.ValidationData)
                    if iteration - validinc >= kwargs.ValidationFrequency
                        validinc = iteration;
                        packet.validlossind = cat(1, packet.validlossind, iteration);
                        validloss = kwargs.validlosseval(net, kwargs.ValidationData);
                        packet.validloss = cat(1, packet.validloss, validloss);
                    end
                end
                
                % accumuate loss
                packet.lossind = cat(1, packet.lossind, iteration);
                packet.loss = cat(1, packet.loss, loss);

                % send data to monitor
                if kwargs.monitorqueue.QueueLength < 1 && (iteration - monitorinc >= kwargs.MonitorFrequency)
                    monitorinc = iteration;
                    pause(0.5)
                    packet.x = extractdata(X); packet.y = extractdata(Y);
                    packet.t = extractdata(T); packet.i = iteration;
                    send(kwargs.monitorqueue, packet);
                end
    
                % update learn rate
                learnRate = kwargs.learnRate(iteration);

                % update the network parameters using the SGDM optimizer
                [net, velocity] = sgdmupdate(net, gradients, velocity, learnRate, kwargs.momentum);
            end
        end

        if kwargs.monitorqueue.QueueLength < 1
            pause(0.5)
            packet.x = extractdata(X); packet.y = extractdata(Y);
            packet.t = extractdata(T); packet.i = iteration;
            send(kwargs.monitorqueue, packet);
        end
    end

    % create custom monitor
    if ~isempty(kwargs.monitorfnc)
        fig = figure('WindowStyle', 'Docked'); tl = tiledlayout(fig, 'flow');
        kwargs.monitorfnc = @(x)kwargs.monitorfnc(x,tl);
        afterEach(kwargs.monitorqueue, @kwargs.monitorfnc)
    end

    % create network
    if isa(layers, 'nnet.cnn.layer.Layer'); net = dlnetwork(layers); else; net = layers; end

    % define loss method
    if isempty(kwargs.lossfnc); kwargs.lossfnc = @mse; end

    % redefine rugulariation method
    if isempty(kwargs.regul); kwargs.regul = @(x,y,t) x; end

    % define loss handle
    kwargs.losseval = @(n,x,t) losseval(n,x,t,kwargs.lossfnc,kwargs.regul);

    % define validation handle
    kwargs.validlosseval = @(n,d) validlosseval(n,d,kwargs.lossfnc);

    % redefine learnRate handle
    if isempty(kwargs.learnRate); kwargs.learnRate = @(x) kwargs.InitialLearnRate/(1+kwargs.decay*x); end

    % create training mini-batch
    trainmbq = minibatchqueue(data, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);

    % create validation mini-batch
    if ~isempty(kwargs.ValidationData)
        kwargs.ValidationData = minibatchqueue(kwargs.ValidationData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
    end

    % start train
    if kwargs.background
        varargout{1} = parfeval(@trainloop, 1, net, trainmbq, kwargs);
    else
        net = trainloop(net, trainmbq, kwargs);
        varargout{1} = net;
    end

    % prediction of test data
    if ~isempty(kwargs.TestingData)
        [targ, pred, score] = predtestfnc(net, kwargs);
        varargout{2} = targ;
        varargout{3} = pred;
        varargout{4} = score;
        if ~isempty(kwargs.testmonitorfnc); kwargs.testmonitorfnc(targ, pred, score); end
    end

end