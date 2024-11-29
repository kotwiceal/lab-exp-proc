function animrec(kwargs)
    %% Animation recorder of 2D multi-frame data.

    %% Examples:
    %% 1. Record animation of set 2D multi-frame
    % animrec(data = rand(120, 140, 10), filename = 'test.gif', clim = [-1, 1], axis = 'equal')

    arguments
        kwargs.data (:,:,:) double = [] % data
        kwargs.range (1,:) double = [] % index frame
        kwargs.x (:,:) double = [] % longitudinal spatial coordinate
        kwargs.y (:,:) double = [] % transversal spatial coordinate
        kwargs.plotfunc (1,:) {mustBeA(kwargs.plotfunc, {'function_handle', 'double'})} = [] % custom plotter handle
        kwargs.filename = '' % filename of storing animation
        kwargs.resolution (1,1) double = 100
        kwargs.mask (:,:) double = [] % roi mask
        kwargs.roi (1,1) logical = false % cut data by roi
        kwargs.hold (1,:) char {mustBeMember(kwargs.hold, {'on', 'off'})} = 'on'
        kwargs.grid (1,:) char {mustBeMember(kwargs.grid, {'on', 'off'})} = 'on'
        kwargs.box (1,:) char {mustBeMember(kwargs.box, {'on', 'off'})} = 'on'
        kwargs.xlabel (1,:) char = [] % x-axis label
        kwargs.ylabel (1,:) char = [] % y-axis label
        kwargs.aspect (1,:) {mustBeA(kwargs.aspect, {'char', 'cell'}), mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        kwargs.fontsize (1,1) double = 14
        kwargs.xlim (:,:) {mustBeA(kwargs.xlim, {'double', 'cell'})} = [] % x-axis limit
        kwargs.ylim (:,:) {mustBeA(kwargs.ylim, {'double', 'cell'})} = [] % y-axis limit
        kwargs.clim (1,:) double = [] % color axis limit
        kwargs.colormap (1,:) char = 'turbo' % colomap name
        kwargs.colorbar (1,1) logical = false % show colorbar
        kwargs.colorbarloc (1,:) char = 'eastoutside' % colorbar location
        kwargs.clabel (1,:) {mustBeA(kwargs.clabel, {'char', 'cell'})} = {} % color-axis label
        kwargs.title (1,:) char = [] % figure title
    end

    function plotfunc(ax, index)
        cla(ax); set(ax, 'FontSize', kwargs.fontsize);
        if display
            imagesc(ax, kwargs.data(:,:,index));
            if display_label
                xlabel(ax, 'x_{n}'); ylabel(ax, 'z_[n}');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
        else
            hold(ax, kwargs.hold);
            contourf(ax, kwargs.x, kwargs.y, kwargs.data(:,:,index), 100, 'LineStyle', 'None');
            box(ax, kwargs.box); grid(ax, kwargs.grid);
            if isempty(kwargs.xlim)
                xlim(ax, [min(kwargs.x(:)), max(kwargs.x(:))]);
            else
                xlim(ax, kwargs.xlim); 
            end
            if isempty(kwargs.ylim)
                ylim(ax, [min(kwargs.y(:)), max(kwargs.y(:))]);
            else
                ylim(ax, kwargs.ylim); 
            end
            if display_label
                xlabel(ax, 'x, mm'); ylabel(ax, 'z, mm');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
            box(ax, 'on');
        end
        axis(ax, kwargs.aspect);
        xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
        if isempty(kwargs.clim); kwargs.clim = clim(ax); end
        clim(ax, kwargs.clim);
        colormap(ax, kwargs.colormap);
        if kwargs.colorbar; clb = colorbar(kwargs.colorbarloc); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel); end; end
        if ~isempty(kwargs.title); title(kwargs.title,FontWeight='normal'); end
    end

    function eventroiselmoving(~, ~)
        kwargs.data = select(rois{1});
        kwargs.plotfunc(ax, 1);
    end

    display = isempty(kwargs.x) & isempty(kwargs.y); 
    display_label = isempty(kwargs.xlabel) & isempty(kwargs.ylabel);
    rois = [];

    datacopy = kwargs.data;
    if display
        select = @(roiobj) guigetdata(roiobj, datacopy, shape = 'raw');
    else
        select = @(roiobj) guigetdata(roiobj, datacopy, shape = 'raw', x = kwargs.x, z = kwargs.y);
    end

    if isempty(kwargs.plotfunc); kwargs.plotfunc = @plotfunc; end

    if isempty(kwargs.data) && isempty(kwargs.range) && isempty(kwargs.plotfunc); error('empty instruction'); end
    if isempty(kwargs.range); kwargs.range = 2:size(kwargs.data,3); end

    clf; tiledlayout('flow'); nexttile; ax = gca;
    kwargs.plotfunc(ax, 1);
    if kwargs.roi
            rois = guiselectregion(ax, moving = @eventroiselmoving, shape = 'poly', ...
            mask = kwargs.mask, interaction = 'all', number = 1);
        eventroiselmoving()
    end
    exportgraphics(ax, kwargs.filename, Resolution = kwargs.resolution);

    for i = kwargs.range
        kwargs.plotfunc(ax, i);
        exportgraphics(ax, kwargs.filename, Append = true, Resolution = kwargs.resolution);
    end
end