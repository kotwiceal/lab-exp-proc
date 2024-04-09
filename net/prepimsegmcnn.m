function varargout = prepimsegmcnn(input, output, kwargs)
    %% Create dataset to train convolutional neural network performed image segmentation.

    arguments
        input {mustBeA(input, {'double'})}
        output {mustBeA(output, {'double', 'categorical'})}
        kwargs.IterationDimension (1,:) double = [3, 3]
        kwargs.suffle (1,1) logical = true
        kwargs.partition (1,:) cell = {}
    end

    sz = size(input); n = sz(kwargs.IterationDimension(1));
    if isempty(kwargs.partition); kwargs.partition{1} = 1:n; end

    if isa(input, 'double'); input = arrayDatastore(input, IterationDimension = kwargs.IterationDimension(1)); end
    if isa(output, 'double'); output = categorical(output); end
    output = arrayDatastore(output, IterationDimension = kwargs.IterationDimension(2));

    totalDataStore = combine(input, output);
    if kwargs.suffle; totalDataStore = shuffle(totalDataStore); end

    for i = 1:numel(kwargs.partition)
        if ~isempty(kwargs.partition{i})
            varargout{i} = subset(totalDataStore, kwargs.partition{i}); 
        end
    end
    
end