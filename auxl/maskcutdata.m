function varargout = maskcutdata(mask, varargin, options)
    arguments (Input)
        mask (:,:) double
    end
    arguments (Input, Repeating)
        varargin
    end
    arguments (Input)
        options.dims (1,:) double = []
        options.fill {mustBeMember(options.fill, {'none', 'innan', 'outnan'})} = 'none'
        options.shape {mustBeMember(options.shape, {'bounds', 'trim'})} = 'bounds'
        options.ans {mustBeMember(options.ans, {'on', 'off'})} = 'off' % flip outputs
    end

    if isempty(options.dims); options.dims = 1:size(mask,2); end
    if numel(options.dims) ~= size(mask,2); error('`numel(dims)` must be same `size(mask,2)`'); end

    data = varargin{end};
    sz = size(data, options.dims);

    if isscalar(varargin)
        grid = cell(1, numel(options.dims));
        ind = cellfun(@(x) 1:x, num2cell(sz), UniformOutput = false);
        [grid{:}] = ndgrid(ind{:});
        varargin = cat(2, grid, varargin);
    else
        grid = varargin(1:end-1);
    end

    pos = cell2mat(cellfun(@(x) x(:), grid, UniformOutput = false));
    k = dsearchn(pos, mask);
    linind = k;
    [in, on] = inpolygon(pos(:,1), pos(:,2), mask(:,1), mask(:,2));
    switch options.fill
        case 'innan'
            ind = ~(in | on);
        case 'outnan'
            ind = in | on;
        otherwise
            ind = in | on;
    end
    linindr = find(ind);

    subind = cell(numel(sz), 1);
    [subind{:}] = ind2sub(sz, linind);

    dims = repmat({1:size(mask,2)}, 1, numel(varargin));

    varargout = cellfun(@(dim, data) mdslice(subind, linindr, dim, data, fill = options.fill, ...
        shape = options.shape), dims, varargin, UniformOutput = false);

    switch options.ans
        case 'on'
            varargout = flip(varargout);
    end

end