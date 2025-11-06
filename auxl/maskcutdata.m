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
            ind = in | on;
        case 'outnan'
            ind = ~(in | on);
        otherwise
            ind = in | on;
    end
    linindr = find(ind);

    subind = cell(numel(sz), 1);
    [subind{:}] = ind2sub(sz, linind);

    dims = repmat({1:size(mask,2)}, 1, numel(varargin));

    varargout = cellfun(@(dim, data) func1(subind, linindr, data, dims = dim, fill = options.fill, ...
        shape = options.shape), dims, varargin, UniformOutput = false);

end

function data = func1(subind, linindr, data, options)
    arguments (Input)
        subind
        linindr
        data
        options.dims (1,:) double = []
        options.fill {mustBeMember(options.fill, {'none', 'innan', 'outnan'})} = 'none'
        options.shape {mustBeMember(options.shape, {'bounds', 'trim'})} = 'bounds'
    end
    switch options.fill
        case 'none'
            switch options.shape
                case 'bounds'
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind(options.dims) = cellfun(@(x) min(x):max(x), subind, UniformOutput = false);
                case 'trim'
                    dn = setdiff((1:ndims(data)), options.dims);
                    if isempty(dn)
                        ind = {linindr};
                    else
                        szc = num2cell(size(data));
                        szc = cat(2, szc(dn), {[]});
                        data = reshape(permute(data, [dn, options.dims]), szc{:});
                        ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                        ind{end} = linindr;
                    end
            end
            data = data(ind{:});
        otherwise
            switch options.shape
                case 'bounds'
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind(options.dims) = cellfun(@(x) min(x):max(x), subind, UniformOutput = false);
                    data(ind{:}) = nan;
                case 'trim'
                    bl = nan(size(data, options.dims));
                    bl(linindr) = 1;
                    dn = (1:ndims(data));
                    [~, i] = setdiff((1:ndims(data)), options.dims);
                    dn(i) = numel(options.dims)+(1:numel(i));
                    dn(options.dims) = 1:numel(options.dims);
                    data = data.*permute(bl, dn);
            end
    end

end