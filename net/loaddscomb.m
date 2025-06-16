function varargout = loaddscomb(filename, param)
    %% Make sequential combination of datastore objects from specified files.
    arguments (Input)
        filename {mustBeA(filename, {'cell', 'char'})}
        param.augmenter = []
        param.ans {mustBeMember(param.ans, {'cell', 'struct'})} = 'cell'
    end
    arguments (Output, Repeating)
        varargout {mustBeA(varargout, {'struct', 'matlab.io.datastore.SequentialDatastore', 'matlab.io.datastore.ArrayDatastore', 'matlab.io.datastore.TransformedDatastore', 'matlab.io.datastore.CombinedDatastore'})}
    end
    if isa(filename, 'char'); filename = {filename}; end
    datastores = cell(1, numel(filename));
    for i = 1:numel(filename)
        l = load(filename{i});
        f = fieldnames(l);
        datastores{i} = struct2cell(l);
    end
    datastores = cellfun(@(varargin) combine(varargin{:}, ReadOrder = 'sequential'), datastores{:}, UniformOutput = false);
    if isempty(param.augmenter)
        datastores = cellfun(@shuffle, datastores, UniformOutput = false);
    else
        datastores = cellfun(@(d) shuffle(combine(d, transform(d, @(x) augment(param.augmenter, x)), ReadOrder = 'sequential')), ...
            datastores, UniformOutput = false);
    end
    switch param.ans
        case 'cell'
            varargout = cell(numel(datastores), 1);
            [varargout{:}] = deal(datastores{:});
        case 'struct'
            varargout{1} = cell2struct(datastores, f, 1);
    end
end