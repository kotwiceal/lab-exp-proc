function result = mergecta(varargin)

    result = struct('scan', [], 'data', [], 'raw', []);

    for i = 1:numel(varargin)
        result.scan = cat(1, result.scan, varargin{i}.scan);
        result.data = cat(3, result.data, varargin{i}.data);
        result.raw = cat(3, result.raw, varargin{i}.raw);
    end

end