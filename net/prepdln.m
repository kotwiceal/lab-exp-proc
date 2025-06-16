function varargout = prepdln(varargin, dskwargs, kwargs)
    %% Create dataset to train deep neural network.

    arguments (Repeating, Input)
        varargin {mustBeA(varargin, {'double', 'categorical', 'logical'})}
    end

    arguments (Input)
        dskwargs.IterationDimension (1,:) cell = []
        dskwargs.ReadSize {mustBeInteger, mustBePositive} = 1
        dskwargs.OutputType {mustBeMember(dskwargs.OutputType, {'cell', 'same'})} = 'cell'
        kwargs.wrapper (1,:) cell = {}
        kwargs.suffle (1,1) logical = true
        kwargs.partition (1,:) cell = {}
        kwargs.transform (1,:) cell = {}
        kwargs.augment (1,:) = []
        kwargs.inputDataFormats (1,:) char = ''
        kwargs.targetDataFormats (1,:) char = ''
    end

    arguments (Repeating, Output)
        varargout {mustBeA(varargout, {'matlab.io.datastore.TransformedDatastore', 'matlab.io.datastore.CombinedDatastore'})}
    end

    if isempty(dskwargs.IterationDimension)
        for i = 1:nargin
            dskwargs.IterationDimension{i} = ndims(varargin{i});
        end
    else
        assert(isequal(numel(dskwargs.IterationDimension), nargin), "`IterationDimension` vectro must be have same size to data arguments")
    end

    sz = zeros(1, nargin); for i = 1:nargin; sz(i) = size(varargin{i}, dskwargs.IterationDimension{i}); end

    if numel(unique(sz)) ~= 1; error(strcat("count of iteration ", jsonencode(sz)), " along given dimensional ", ...
            jsonencode(dskwargs.IterationDimension), " must be same"); end
    
    if isempty(kwargs.partition); kwargs.partition{1} = 1:sz(1); end

    if isempty(kwargs.wrapper); kwargs.wrapper = repmat({[]}, 1, nargin); else
        assert(isequal(numel(kwargs.wrapper), nargin), "`wrapper` vector must be have same size to data arguments"); end

    if isempty(kwargs.transform); kwargs.transform = repmat({[]}, 1, nargin); else
        assert(isequal(numel(kwargs.transform), nargin), "`transform` vector must be have same size to data arguments"); end
    
    dskwargs = namedargscomb(dskwargs, ans = 'cell');
    for i = 1:nargin
        if isempty(kwargs.wrapper{i})
            args = cat(2, varargin{i}, dskwargs(i,:));
        else
            args = cat(2, kwargs.wrapper{i}(varargin{i}), dskwargs(i,:));
        end
        varargin{i} = arrayDatastore(args{:});
        if ~isempty(kwargs.transform{i}); varargin{i} = transform(varargin{i}, @(x) kwargs.transform{i}(x)); end
    end

    if isscalar(varargin); totalDataStore = varargin{1}; else; totalDataStore = combine(varargin{:}); end
    if ~isempty(kwargs.augment); totalDataStore = transform(totalDataStore, @(x) augment(kwargs.augment, x)); end
    if kwargs.suffle; totalDataStore = shuffle(totalDataStore); end

    % create data partitions
    varargout = cell(1, numel(kwargs.partition));
    
    if numel(cell2mat(kwargs.partition)) == numel(kwargs.partition)
        partition = cell2mat(kwargs.partition);
        index = 1:sz(1);
        n = floor(partition*sz(1));
        n(end) = n(end) + sz(1) - sum(n);
        kwargs.partition = mat2cell(index, 1, n);
    end
    
    for i = 1:numel(kwargs.partition)
        varargout{i} = subset(totalDataStore, kwargs.partition{i}); 
    end
    
end