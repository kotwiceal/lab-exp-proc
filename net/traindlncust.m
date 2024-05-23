function varargout = traindlncust(data, layers, kwargs)
    %% Custom train loop of deep neural network by given settings.

    arguments
        %% main paramters
        data {mustBeA(data, {'matlab.io.datastore.CombinedDatastore'})}
        layers (:,:) {mustBeA(layers, {'nnet.cnn.layer.Layer', 'dlnetwork'})}
        %% train settings
        kwargs.lossfnc {mustBeA(kwargs.lossfnc, {'double', 'function_handle'})} = []
        %% learn rate settings
        kwargs.InitialLearnRate (1,:) double = 1e-2
        kwargs.learnRate {mustBeA(kwargs.learnRate, {'double', 'function_handle'})} = []
        kwargs.decay (1,1) double = 0.1
        kwargs.momentum (1,1) double = 0.9
        %% regularization settings
        kwargs.regul {mustBeA(kwargs.regul, {'double', 'function_handle'})} = []
        %% evaluation settings
        kwargs.MaxEpochs (1,1) double {mustBeInteger(kwargs.MaxEpochs), mustBeGreaterThanOrEqual(kwargs.MaxEpochs, 1)} = 10
        kwargs.ValidationData {mustBeA(kwargs.ValidationData, {'double', 'matlab.io.datastore.CombinedDatastore'})} = []
        kwargs.ValidationFrequency (1,1) double = 10
        kwargs.TestingData {mustBeA(kwargs.TestingData, {'double', 'matlab.io.datastore.CombinedDatastore'})} = []
        kwargs.testhandler {mustBeA(kwargs.testhandler, {'double', 'function_handle'})} = []
        %% mini-batch settings
        kwargs.MiniBatchSize (1,1) {mustBeInteger(kwargs.MiniBatchSize), mustBeGreaterThanOrEqual(kwargs.MiniBatchSize, 1)} = 12
        kwargs.MiniBatchFormat (1,:) {mustBeA(kwargs.MiniBatchFormat, {'string', 'char', 'cell'})} = ["SSBC", "BC"]
        %% monitor settings
        kwargs.monitorqueue parallel.pool.DataQueue = parallel.pool.DataQueue
        kwargs.monitorhandler {mustBeA(kwargs.monitorhandler, {'double', 'function_handle'})} = []
        kwargs.MonitorFrequency (1,1) double = 1
    end

    function [loss, gradients, Y, state] = losseval(net, X, T)
        [Y, state] = forward(net, X);
        loss = kwargs.lossfnc(Y, T);
        loss = kwargs.regul(loss, Y, T);
        gradients = dlgradient(loss, net.Learnables);
        loss = gather(extractdata(loss));
    end

    function result = predeval(net, mnq)
        targ = {}; score = []; pred = {};
        while hasdata(mnq)
            [X, T] = next(mnq);
            Y = predict(net, X);
            score = kwargs.lossfnc(Y, T);
            score = cat(2, score, kwargs.regul(score, Y, T));
            targ = cat(2, targ, gather(extractdata(T)));
            pred = cat(2, pred, gather(extractdata(Y)));
        end
        score = mean(score, 'all');
        result = struct(T = {targ}, Y = {pred}, score = gather(extractdata(score)));
    end

    function net = trainloop(net, mbq, kwargs)
        % counters
        epoch = 0; iteration = 0; 
        validcnt = -kwargs.ValidationFrequency;
        monitorcnt = -kwargs.MonitorFrequency;

        % metrics
        score = struct(value = [], iteration = []);
        loss = struct(value = [], iteration = []);
        
        % support
        velocity = []; learnRate = [];

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
                [trainloss, gradients, Y, state] = dlfeval(@kwargs.losseval, net, X, T);
                net.State = state;

                % accumuate train loss
                loss.value = cat(1, loss.value, trainloss); loss.iteration = cat(1, loss.iteration, iteration);

                % validation
                if ~isempty(kwargs.ValidationData)
                    if iteration - validcnt >= kwargs.ValidationFrequency
                        validcnt = iteration;
                        % create validation mini-batch of data
                        validmnq = minibatchqueue(kwargs.ValidationData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
                        % predict model
                        predvalid = kwargs.predict(net, validmnq);
                        % accumuate validation score
                        score.value = cat(1, score.value, predvalid.score); score.iteration = cat(1, score.iteration, iteration);
                    end
                end

                % update learn rate
                learnRate = cat(1, learnRate, kwargs.learnRate(iteration));
                
                % send data to monitor
                if kwargs.monitorqueue.QueueLength < 1 && (iteration - monitorcnt >= kwargs.MonitorFrequency)
                    monitorcnt = iteration; pause(0.5);
                    % gather data
                    X = gather(extractdata(X)); Y = gather(extractdata(Y)); T = gather(extractdata(T));
                    packet = struct(loss = loss, score = score, X = X, T = T, Y = Y, learnRate = learnRate, net = net);
                    send(kwargs.monitorqueue, packet);
                end
    
                % update the network parameters using the SGDM optimizer
                [net, velocity] = sgdmupdate(net, gradients, velocity, learnRate(end), kwargs.momentum);
            end
        end

        if kwargs.monitorqueue.QueueLength < 1
            pause(0.5); 
            % gather data
            X = gather(extractdata(X)); Y = gather(extractdata(Y)); T = gather(extractdata(T));
            packet = struct(loss = loss, score = score, X = X, T = T, Y = Y, learnRate = learnRate, net = net);
            send(kwargs.monitorqueue, packet);
        end
    end

    % create custom monitor
    if ~isempty(kwargs.monitorhandler)
        fig = figure('WindowStyle', 'Docked'); tl = tiledlayout(fig, 'flow');
        kwargs.monitorhandler = @(x) kwargs.monitorhandler(x, tl);
        afterEach(kwargs.monitorqueue, @kwargs.monitorhandler)
    end

    % create network
    if isa(layers, 'nnet.cnn.layer.Layer'); net = dlnetwork(layers); else; net = layers; end

    % define loss method
    if isempty(kwargs.lossfnc); kwargs.lossfnc = @mse; end

    % redefine rugulariation method
    if isempty(kwargs.regul); kwargs.regul = @(x,y,t) x; end

    % define loss handle
    kwargs.losseval = @losseval;

    % define prediction handle
    kwargs.predict = @predeval;

    % redefine learnRate handle
    if isempty(kwargs.learnRate); kwargs.learnRate = @(x) kwargs.InitialLearnRate/(1+kwargs.decay*x); else
        if isa(kwargs.learnRate, 'double'); kwargs.learnRate = @(x) kwargs.learnRate; end; end

    % create training mini-batch
    trainmbq = minibatchqueue(data, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);

    % start train
    net = trainloop(net, trainmbq, kwargs);
        
    % store output
    result = struct();
    result.net = net;

    % prediction of test data
    if ~isempty(kwargs.TestingData)
        testmnq = minibatchqueue(kwargs.TestingData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
        result.test = kwargs.predict(net, testmnq);
        if ~isempty(kwargs.testhandler); kwargs.testhandler(result.test); end
    end

    varargout{1} = result;

end