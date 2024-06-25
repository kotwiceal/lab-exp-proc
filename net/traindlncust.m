function varargout = traindlncust(data, layers, kwargs)
    %% Custom train loop of deep neural network by given settings.

    arguments
        %% main paramters
        data {mustBeA(data, {'matlab.io.datastore.CombinedDatastore'})}
        layers (:,:) {mustBeA(layers, {'nnet.cnn.layer.Layer', 'dlnetwork'})}
        %% evalutation settings
        kwargs.lossfnc {mustBeA(kwargs.lossfnc, {'double', 'function_handle'})} = []
        kwargs.regulfnc {mustBeA(kwargs.regulfnc, {'double', 'function_handle'})} = []
        kwargs.accuracyfnc {mustBeA(kwargs.accuracyfnc, {'double', 'function_handle'})} = []
        kwargs.errorfnc {mustBeA(kwargs.errorfnc, {'double', 'function_handle'})} = []
        %% SGDM settings
        kwargs.InitialLearnRate (1,:) double = 1e-2
        kwargs.learnRate {mustBeA(kwargs.learnRate, {'double', 'function_handle'})} = []
        kwargs.decay (1,1) double = 0.1
        kwargs.momentum (1,1) double = 0.9
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

    function accuracy = accureval(y, t)
        [~, y] = max(y, [], 1);
        [~, t] = max(t, [], 1);
        accuracy = sum((t-y)==0,'all')/numel(t);
    end

    function [metrics, gradients, Y, state] = losseval(net, X, T)
        [Y, state] = forward(net, X);
        loss = kwargs.lossfnc(Y, T);
        if ~isempty(kwargs.regulfnc); loss = kwargs.regulfnc(loss, Y, T); end
        gradients = dlgradient(loss, net.Learnables);
        metrics.loss = loss;
        if ~isempty(kwargs.accuracyfnc); metrics.accuracy = kwargs.accuracyfnc(Y, T); end
        if ~isempty(kwargs.errorfnc); metrics.error = kwargs.errorfnc(Y, T); end
    end

    function [data, metrics] = predeval(net, mnq)
        [X, T] = next(mnq);
        Y = predict(net, X);
        score = kwargs.lossfnc(Y, T);
        if ~isempty(kwargs.regulfnc); score = kwargs.regulfnc(score, Y, T); end
        data = struct(X = X, T = T, Y = Y);
        metrics.score = score;
        if ~isempty(kwargs.accuracyfnc); metrics.accuracy = kwargs.accuracyfnc(Y, T); end
        if ~isempty(kwargs.errorfnc); metrics.error = kwargs.errorfnc(Y, T); end
    end

    function metrics = updateMetrics(metrics, metric, iteration)
        fields = fieldnames(metric);
        if isempty(metrics)
            metrics = metric;
            metrics.iteration = iteration;
        else
            for i = 1:numel(fields)
                metrics.(fields{i}) = cat(1, metrics.(fields{i}), metric.(fields{i}));
            end
            metrics.iteration = cat(1, metrics.iteration, iteration);
        end
    end

    function net = trainloop(net, mbq, kwargs)
        % counters
        epoch = 0; iteration = 0; 
        validcnt = -kwargs.ValidationFrequency;
        monitorcnt = -kwargs.MonitorFrequency;
        
        % metrics
        trainmetrics = []; validmetrics = [];

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
                
                % evaluate the model gradients and metrics
                [metrics, gradients, Y, state] = dlfeval(@kwargs.losseval, net, X, T);
                net.State = state;

                % accumuate metrics at training
                trainmetrics = updateMetrics(trainmetrics, metrics, iteration);

                % validate network
                if ~isempty(kwargs.ValidationData)
                    if iteration - validcnt >= kwargs.ValidationFrequency
                        validcnt = iteration;
                        % reset validation mini-batch
                        reset(kwargs.validmnq);
                        % predict model
                        [~, metrics] = kwargs.predict(net, kwargs.validmnq);
                        % accumuate metrics at validation
                        validmetrics = updateMetrics(validmetrics, metrics, iteration);
                    end
                end

                % update learn rate
                learnRate = cat(1, learnRate, kwargs.learnRate(iteration));
                
                % send data to monitor
                if kwargs.monitorqueue.QueueLength < 1 && (iteration - monitorcnt >= kwargs.MonitorFrequency)
                    monitorcnt = iteration; pause(0.5);
                    % gather data
                    X = gather(extractdata(X)); Y = gather(extractdata(Y)); T = gather(extractdata(T));
                    packet = struct(X = X, T = T, Y = Y, learnRate = learnRate, net = net, ...
                        metrics = struct(train = trainmetrics, valid = validmetrics));
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
            packet = struct(X = X, T = T, Y = Y, ...
                learnRate = learnRate, net = net, ...
                metrics = struct(train = trainmetrics, valid = validmetrics));
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

    % define loss handle
    kwargs.losseval = @losseval;

    % define prediction handle
    kwargs.predict = @predeval;

    % redefine learnRate handle
    if isempty(kwargs.learnRate); kwargs.learnRate = @(x) kwargs.InitialLearnRate/(1+kwargs.decay*x); else
        if isa(kwargs.learnRate, 'double'); kwargs.learnRate = @(x) kwargs.learnRate; end; end

    % create training mini-batch
    trainmbq = minibatchqueue(data, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);

    % create validation mini-batch
    if ~isempty(kwargs.ValidationData)
        kwargs.validmnq = minibatchqueue(kwargs.ValidationData, MiniBatchSize = size(readall(kwargs.ValidationData.UnderlyingDatastores{1}), 1), ...
            MiniBatchFormat = kwargs.MiniBatchFormat);
    end

    % start train
    net = trainloop(net, trainmbq, kwargs);
        
    % store output
    result = struct();
    result.net = net;

    % prediction of test data
    if ~isempty(kwargs.TestingData)
        testmnq = minibatchqueue(kwargs.TestingData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
        [result.test.data, result.test.metrics] = kwargs.predict(net, testmnq);
        if ~isempty(kwargs.testhandler); kwargs.testhandler(result.test); end
    end

    varargout{1} = result;

end