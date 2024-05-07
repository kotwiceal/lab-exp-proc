function varargout = traindlnvae(data, layersEncoder, layersDecoder, kwargs)
    %% Custom train loop of autoencoder by given settings.

    arguments
        %% main paramters
        data matlab.io.datastore.ArrayDatastore
        layersEncoder (:,:) nnet.cnn.layer.Layer
        layersDecoder (:,:) nnet.cnn.layer.Layer
        %% learn rate settings
        kwargs.InitialLearnRate (1,:) double = 1e-2
        kwargs.learnRate {mustBeA(kwargs.learnRate, {'double', 'function_handle'})} = []
        kwargs.decay (1,1) double = 0.01
        kwargs.momentum (1,1) double = 0.9
        %% evaluation settings
        kwargs.MaxEpochs (1,1) double {mustBeInteger(kwargs.MaxEpochs), mustBeGreaterThanOrEqual(kwargs.MaxEpochs, 1)} = 10
        kwargs.ValidationData {mustBeA(kwargs.ValidationData, {'double', 'matlab.io.datastore.ArrayDatastore'})} = []
        kwargs.ValidationFrequency (1,1) double = 10
        kwargs.TestingData {mustBeA(kwargs.TestingData, {'double', 'matlab.io.datastore.ArrayDatastore'})} = []
        kwargs.testhandler {mustBeA(kwargs.testhandler, {'double', 'function_handle'})} = []
        %% mini-batch settings
        kwargs.MiniBatchSize (1,1) {mustBeInteger(kwargs.MiniBatchSize), mustBeGreaterThanOrEqual(kwargs.MiniBatchSize, 1)} = 12
        kwargs.MiniBatchFormat (1,:) {mustBeA(kwargs.MiniBatchFormat, {'string', 'char', 'cell'})} = ["SSCB"]
        %% monitor settings
        kwargs.monitorqueue parallel.pool.DataQueue = parallel.pool.DataQueue
        kwargs.monitorhandler {mustBeA(kwargs.monitorhandler, {'cell', 'function_handle'})} = {}
        kwargs.MonitorFrequency (1,1) double = 1
    end

    function loss = elboloss(Y, T, mu, logSigmaSq)
        reconstructionLoss = mse(Y,T);
        KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq), 1);
        KL = mean(KL);
        loss = reconstructionLoss + KL;
    end

    function [loss, gradientsE, gradientsD] = losseval(netE, netD, X)
        [Z, mu, logSigmaSq] = forward(netE, X);
        Y = forward(netD, Z);
        loss = elboloss(Y, X, mu, logSigmaSq);
        [gradientsE, gradientsD] = dlgradient(loss, netE.Learnables, netD.Learnables);
        loss = gather(extractdata(loss));
    end

    function result = predeval(netE, netD, mnq)
        targ = []; latent = []; pred = [];
        while hasdata(mnq)
            X = next(mnq);
            Z = predict(netE, X);
            Y = predict(netD, Z);
            targ = cat(3, targ, squeeze(gather(extractdata(X))));
            latent = cat(2, latent, squeeze(gather(extractdata(Z))));
            pred = cat(3, pred, squeeze(gather(extractdata(Y))));
        end
        score = mean(mse(pred, targ));
        result = struct(T = targ, Z = latent, Y = pred, score = score);
    end

    function [netE, netD] = trainloop(netE, netD, mbq, kwargs)
        % counters
        epoch = 0; iteration = 0; validcnt = -kwargs.ValidationFrequency; monitorcnt = -kwargs.MonitorFrequency;
        
        % metrics
        score = struct(value = [], iteration = []);
        loss = struct(value = [], iteration = []);

        % suport
        trailingAvgE = []; trailingAvgSqE = []; trailingAvgD = []; trailingAvgSqD = []; packet = [];

        % loop over epochs
        while epoch < kwargs.MaxEpochs
            epoch = epoch + 1;
            shuffle(mbq);
            % loop over mini-batches
            while hasdata(mbq)
                iteration = iteration + 1;
                % read mini-batch of data
                X = next(mbq);
                % evaluate the model gradients, and loss
                [trainloss, gradientsE, gradientsD] = dlfeval(@kwargs.losseval, netE, netD, X);
                % accumuate train loss
                loss.value = cat(1, loss.value, trainloss); loss.iteration = cat(1, loss.iteration, iteration);
                % validate model
                if ~isempty(kwargs.ValidationData)
                    if iteration - validcnt >= kwargs.ValidationFrequency
                        validcnt = iteration;
                        % create validation mini-batch of data
                        validmnq = minibatchqueue(kwargs.ValidationData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
                        % predict model
                        predvalid = kwargs.predict(netE, netD, validmnq);
                        % accumuate validation score
                        score.value = cat(1, score.value, predvalid.score); score.iteration = cat(1, score.iteration, iteration);
                        % prepare packet
                        packet = struct(loss = loss, score = score, T = predvalid.T, Z = predvalid.Z, Y = predvalid.Y);
                    end
                end
                % send data to monitor
                if kwargs.monitorqueue.QueueLength < 1 && (iteration - monitorcnt >= kwargs.MonitorFrequency)
                    monitorcnt = iteration;
                    pause(0.5);
                    send(kwargs.monitorqueue, packet);
                end
                % update learn rate
                learnRate = kwargs.learnRate(iteration);
                % update learnable parameters
                [netE,trailingAvgE,trailingAvgSqE] = adamupdate(netE, ...
                    gradientsE, trailingAvgE, trailingAvgSqE, iteration, learnRate);  
                [netD, trailingAvgD, trailingAvgSqD] = adamupdate(netD, ...
                    gradientsD, trailingAvgD, trailingAvgSqD, iteration, learnRate);
            end
        end

        if kwargs.monitorqueue.QueueLength < 1
            pause(0.5);
            packet.loss = loss;
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
    netE = dlnetwork(layersEncoder);
    netD = dlnetwork(layersDecoder);

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
    [netE, netD] = trainloop(netE, netD, trainmbq, kwargs);

    % store output
    result = struct();
    result.netE = netE;
    result.netD = netD;

    % prediction of test data
    if ~isempty(kwargs.TestingData)
        testmnq = minibatchqueue(kwargs.TestingData, MiniBatchSize = kwargs.MiniBatchSize, MiniBatchFormat = kwargs.MiniBatchFormat);
        predtest = kwargs.predict(netE, netD, testmnq);
        varargout{2} = predtest;
        if ~isempty(kwargs.testhandler); kwargs.testhandler(predtest); end
    end

    varargout{1} = result;

end