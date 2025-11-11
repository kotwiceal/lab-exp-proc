function data = mdslice(subind, linindr, data, options)
    %% Multidimensional data slicing
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