function data = roislicedata(roi, target, data, dims, options)
    arguments
        roi
        target
        data
        dims (1,:) double
        options.fill {mustBeMember(options.fill, {'none', 'nan'})} = 'none'
        options.shape {mustBeMember(options.shape, {'bounds', 'trim'})} = 'bounds'
        options.snap (1,1) logical = true
    end
    roisnaphandler(roi, target, snap = options.snap)
    if ~(isfield(roi.UserData, 'subind') && isfield(roi.UserData, 'linindr'))
        data = [];
        return;
    end
    switch options.fill
        case 'none'
            switch options.shape
                case 'bounds'
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind(dims) = cellfun(@(x) min(x):max(x), roi.UserData.subind, UniformOutput = false);
                case 'trim'
                    dn = setdiff((1:ndims(data)), dims);
                    szc = num2cell(size(data));
                    szc = cat(2, szc(dn), {[]});
                    data = reshape(permute(data, [dn, dims]), szc{:});
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind{end} = roi.UserData.linindr;
            end
            data = data(ind{:});
        case 'nan'
            switch options.shape
                case 'bounds'
                    ind = cellfun(@(x) 1:x, num2cell(size(data)), UniformOutput = false);
                    ind(dims) = cellfun(@(x) min(x):max(x), roi.UserData.subind, UniformOutput = false);
                    data(ind{:}) = nan;
                case 'trim'
                    bl = nan(size(data, dims));
                    bl(roi.UserData.linindr) = 1;
                    dn = (1:ndims(data));
                    [~, i] = setdiff((1:ndims(data)), dims);
                    dn(i) = numel(dims)+(1:numel(i));
                    dn(dims) = 1:numel(dims);
                    data = data.*permute(bl, dn);
            end
    end
end