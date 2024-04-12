function varargout = prepdln(varargin, kwargs)
    %% Create dataset to train deep neural network.

    arguments (Repeating)
        varargin {mustBeA(varargin, {'double', 'categorical'})}
    end

    arguments
        kwargs.IterationDimension (1,:) double = []
        kwargs.wrapper (1,:) cell = {}
        kwargs.suffle (1,1) logical = true
        kwargs.partition (1,:) cell = {}
        kwargs.transform (1,:) cell = {}
    end

    if isempty(kwargs.IterationDimension)
        for i = 1:numel(varargin)
            kwargs.IterationDimension(i) = ndims(varargin{i});
        end
    else
        assert(isequal(numel(kwargs.IterationDimension), numel(varargin)), "IterationDimension vectro must be have same size to data arguments")
    end

    sz = zeros(1, numel(varargin)); for i = 1:numel(varargin); sz(i) = size(varargin{i}, kwargs.IterationDimension(i)); end

    if numel(unique(sz)) ~= 1; error(strcat("count of iteration ", jsonencode(sz)), " along given dimensional ", ...
            jsonencode(kwargs.IterationDimension), " must be same"); end
    
    if isempty(kwargs.partition); kwargs.partition{1} = 1:sz(1); end

    if isempty(kwargs.wrapper); kwargs.wrapper = repmat({[]}, 1, numel(varargin)); else
        assert(isequal(numel(kwargs.wrapper), numel(varargin)), "wrapper vectro must be have same size to data arguments"); end

    if isempty(kwargs.transform); kwargs.transform = repmat({[]}, 1, numel(varargin)); else
        assert(isequal(numel(kwargs.transform), numel(varargin)), "transform vectro must be have same size to data arguments"); end

    for i = 1:numel(varargin)
        if isempty(kwargs.wrapper{1}); data = varargin{i}; else; data = kwargs.wrapper{1}(varargin{i}); end
        varargin{i} = arrayDatastore(data, IterationDimension = kwargs.IterationDimension(i));
        if ~isempty(kwargs.transform{i}); varargin{i} = transform(varargin{i}, @(x)kwargs.transform{i}(x)); end
    end

    totalDataStore = combine(varargin{:});
    if kwargs.suffle; totalDataStore = shuffle(totalDataStore); end

    for i = 1:numel(kwargs.partition)
        varargout{i} = subset(totalDataStore, kwargs.partition{i}); 
    end
    
end