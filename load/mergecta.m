function result = mergecta(varargin)

    result = struct('scan', [], 'data', [], 'raw', []);

    for i = 1:numel(varargin)
        try result.scan = cat(1, result.scan, varargin{i}.scan); catch; end
        try result.data = cat(3, result.data, varargin{i}.data); catch; end
        try result.raw = cat(3, result.raw, varargin{i}.raw); catch; end
    end

end