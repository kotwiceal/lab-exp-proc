function data = roislicedata(roi, target, dims, data, options)
    arguments
        roi
        target
        dims (1,:) double
        data
        options.fill {mustBeMember(options.fill, {'none', 'innan', 'outnan'})} = 'none'
        options.shape {mustBeMember(options.shape, {'bounds', 'trim'})} = 'bounds'
        options.snap (1,1) logical = true
    end
    roisnaphandler(roi, target, snap = options.snap)
    data = mdslice(roi.UserData.subind, roi.UserData.linindr, dims, data, ...
        fill = options.fill, shape = options.shape);
end