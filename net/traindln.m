function [net, info] = traindln(data, layers, kwargs)
    %% Train deep neural network by given settings.

    arguments
        data {mustBeA(data, {'matlab.io.datastore.CombinedDatastore'})}
        layers (:,:) {mustBeA(layers, {'nnet.cnn.layer.Layer', 'dlnetwork'})}
        kwargs.loss (1,:) char {mustBeMember(kwargs.loss, {'crossentropy', 'mse'})} = 'crossentropy'
        kwargs.solverName (1,:) char {mustBeMember(kwargs.solverName, {'sgdm', 'rmsprop', 'adam', 'lbfgs'})} = 'sgdm'
        kwargs.InitialLearnRate (1,:) double = 1e-2
        kwargs.MaxEpochs (1,1) double {mustBeInteger(kwargs.MaxEpochs), mustBeGreaterThanOrEqual(kwargs.MaxEpochs, 1)} = 50
        kwargs.MiniBatchSize (1,1) {mustBeInteger(kwargs.MiniBatchSize), mustBeGreaterThanOrEqual(kwargs.MiniBatchSize, 1)} = 12
        kwargs.ValidationData {mustBeA(kwargs.ValidationData, {'double', 'matlab.io.datastore.CombinedDatastore'})} = []
        kwargs.ValidationFrequency (1,1) double = 30
        kwargs.ExecutionEnvironment (1,:) char {mustBeMember(kwargs.ExecutionEnvironment, {'cpu', 'gpu', 'parallel-auto', 'multi-gpu'})} = 'cpu'
        kwargs.Plots (1,:) char {mustBeMember(kwargs.Plots, {'none', 'training-progress'})} = 'training-progress'
        kwargs.Metrics {mustBeA(kwargs.Metrics, {'double', 'cell', 'char', 'string', 'function_handle'})} = []
        kwargs.OutputFcn {mustBeA(kwargs.OutputFcn, {'cell', 'function_handle'})} = {}
        kwargs.filename (1,:) char = []
    end

    options = trainingOptions(kwargs.solverName, InitialLearnRate = kwargs.InitialLearnRate, ...
        MaxEpochs = kwargs.MaxEpochs, MiniBatchSize = kwargs.MiniBatchSize, ValidationData = kwargs.ValidationData,...
        Plots = kwargs.Plots, ExecutionEnvironment = kwargs.ExecutionEnvironment, Metrics = kwargs.Metrics, ...
        OutputFcn = kwargs.OutputFcn, ValidationFrequency = kwargs.ValidationFrequency);

    [net, info] = trainnet(data, layers, kwargs.loss, options);

    if ~isempty(kwargs.filename); save(kwargs.filename, 'net'); end

end