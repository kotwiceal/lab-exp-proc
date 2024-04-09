function [net, info] = trainimsegmcnn(data, layers, kwargs)
    %% Train convolutional neural network performed image segmentation.

    arguments
        data {mustBeA(data, {'matlab.io.datastore.CombinedDatastore'})}
        layers (:,:) {mustBeA(layers, {'nnet.cnn.layer.Layer'})}
        kwargs.solverName (1,:) char {mustBeMember(kwargs.solverName, {'sgdm', 'rmsprop', 'adam', 'lbfgs'})} = 'sgdm'
        kwargs.InitialLearnRate (1,:) double = 1e-2
        kwargs.MaxEpochs (1,1) double {mustBeInteger(kwargs.MaxEpochs), mustBeGreaterThanOrEqual(kwargs.MaxEpochs, 1)} = 50
        kwargs.MiniBatchSize (1,1) {mustBeInteger(kwargs.MiniBatchSize), mustBeGreaterThanOrEqual(kwargs.MiniBatchSize, 1)} = 12
        kwargs.ValidationData {mustBeA(kwargs.ValidationData, 'matlab.io.datastore.CombinedDatastore')} = []
        kwargs.ExecutionEnvironment (1,:) char {mustBeMember(kwargs.ExecutionEnvironment, {'cpu'})} = 'cpu'
        kwargs.Plots (1,:) char {mustBeMember(kwargs.Plots, {'none', 'training-progress'})} = 'training-progress'
        kwargs.filename (1,:) char = []
    end

    options = trainingOptions(kwargs.solverName, InitialLearnRate = kwargs.InitialLearnRate, ...
        MaxEpochs = kwargs.MaxEpochs, MiniBatchSize = kwargs.MiniBatchSize, ValidationData = kwargs.ValidationData,...
        Plots = kwargs.Plots, ExecutionEnvironment = kwargs.ExecutionEnvironment);

    [net, info] = trainnet(data, layers, 'crossentropy', options);

    if ~isempty(kwargs.filename); save(kwargs.filename, 'net'); end

end