function pointprobe(varargin, popt)
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'double', 'cell'})}
    end
    arguments (Input)
        popt.target = 1
        popt.marker = []
        popt.dims = []
    end
    
    if ~isa(plotname, 'cell'); plotname = {plotname}; end
    if isscalar(plotname) & isa(varargin{1}, 'cell'); plotname = repmat(plotname, 1, numel(varargin{1})); end
    plt = struct(plot = 1, contour = 2, contourf = 2, imagesc = 2, surf = 2);
    dims = cellfun(@(p) plt.(p), plotname);

    pltfunc = cellfun(@(p) str2func(p), plotname, UniformOutput = false);


    [plts, axs, rois] = cellplot('contourf', varargin{:}, target = popt.target, draw = 'drawpoint');

    funcs = cellfun(@(roi) roislicedata(roi, popt.target, popt.marker, popt.dims), rois, UniformOutput = false);

end