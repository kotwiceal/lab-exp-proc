function data = roislicedata(roi, target, data, dims, options)
    arguments
        roi
        target
        data
        dims (1,:) double
        options.fill {mustBeMember(options.fill, {'none', 'innan', 'outnan'})} = 'none'
        options.shape {mustBeMember(options.shape, {'bounds', 'trim'})} = 'bounds'
        options.snap (1,1) logical = true
    end
    roisnaphandler(roi, target, snap = options.snap)
    if ~(isfield(roi.UserData, 'subind') && isfield(roi.UserData, 'linindr'))
        data = [];
        return;
    end

    data = mdslice(roi.UserData.subind, roi.UserData.linindr, data, dims = dims, ...
        fill = options.fill, shape = options.shape);

end