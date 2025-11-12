function data = mdslice(subind, linindr, dims, data, options)
    %% Multidimensional data slicing
    arguments (Input)
        subind
        linindr
        dims (1,:) double
        data
        options.fill {mustBeMember(options.fill, {'none', 'innan', 'outnan'})} = 'none'
        options.shape {mustBeMember(options.shape, {'bounds', 'trim'})} = 'bounds'
    end
    switch options.fill
        case 'none'
            switch options.shape
                case 'bounds'
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind(dims) = cellfun(@(x) min(x):max(x), subind, UniformOutput = false);
                case 'trim'
                    dn = setdiff((1:ndims(data)), dims);
                    if isempty(dn)
                        ind = {linindr};
                    else
                        szc = num2cell(size(data));
                        szc = cat(2, szc(dn), {[]});
                        data = reshape(permute(data, [dn, dims]), szc{:});
                        ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                        ind{end} = linindr;
                    end
            end
            data = data(ind{:});
        otherwise
            switch options.shape
                case 'bounds'
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind(dims) = cellfun(@(x) min(x):max(x), subind, UniformOutput = false);
                    data(ind{:}) = nan;
                case 'trim'
                    bl = nan(size(data, dims));
                    bl(linindr) = 1;
                    dn = (1:ndims(data));
                    [~, i] = setdiff((1:ndims(data)), dims);
                    dn(i) = numel(dims)+(1:numel(i));
                    dn(dims) = 1:numel(dims);
                    data = data.*permute(bl, dn);
            end
    end
    if isrow(data); data = data(:); end
end