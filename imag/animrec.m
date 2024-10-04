function animrec(data, kwargs)
    %% Animation recorder of 2D multi-frame data.

    %% Examples:
    %% 1. Record animation of set 2D multi-frame
    % animrec(rand(120, 140, 10), filename = 'test.gif', clim = [-1, 1], axis = 'equal')

    arguments
        data (:,:,:) double % data
        kwargs.x double = [] % longitudinal spatial coordinate
        kwargs.z double = [] % transversal spatial coordinate
        kwargs.filename = '' % filename of storing animation
        kwargs.mask (:,:) double = [] % roi mask
        kwargs.roi (1,1) logical = false % cut data by roi
        kwargs.xlabel (1,:) char = [] % x-axis label
        kwargs.ylabel (1,:) char = [] % y-axis label
        kwargs.aspect (1,:) {mustBeA(kwargs.aspect, {'char', 'cell'}), mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        kwargs.fontsize (1,1) double = 14
        kwargs.clim (1,:) double = [] % color axis limit
        kwargs.colormap (1,:) char = 'turbo' % colomap name
        kwargs.colorbar (1,1) logical = false % show colorbar
        kwargs.colorbarloc (1,:) char = []
        kwargs.clabel (1,:) {mustBeA(kwargs.clabel, {'char', 'cell'})} = {} % color-axis label
        kwargs.title (1,:) char = []
    end

    function plotframe(index)
        cla(ax); set(ax, 'FontSize', kwargs.fontsize);
        if display
            imagesc(ax, data(:,:,index));
            if display_label
                xlabel(ax, 'x_{n}'); ylabel(ax, 'z_[n}');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
        else
            hold(ax, 'on');
            contourf(ax, kwargs.x, kwargs.z, data(:,:,index), 100, 'LineStyle', 'None');
            xlim(ax, [min(kwargs.x(:)), max(kwargs.x(:))]);
            ylim(ax, [min(kwargs.z(:)), max(kwargs.z(:))]);
            if display_label
                xlabel(ax, 'x, mm'); ylabel(ax, 'z, mm');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
            box(ax, 'on');
        end
        axis(ax, kwargs.aspect);
        xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
        if isempty(kwargs.clim) && index == 1; kwargs.clim = clim(ax); end
        clim(ax, kwargs.clim);
        colormap(ax, kwargs.colormap);
        if kwargs.colorbar; clb = colorbar(); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel); end; end
        if ~isempty(kwargs.title); title(kwargs.title,FontWeight='normal'); end
    end

    function eventroiselmoving(~, ~)
        data = select(rois{1});
        plotframe(1);
    end

    display = isempty(kwargs.x) & isempty(kwargs.z); 
    display_label = isempty(kwargs.xlabel) & isempty(kwargs.ylabel);
    rois = [];

    datacopy = data;
    if display
        select = @(roiobj) guigetdata(roiobj, datacopy, shape = 'raw');
    else
        select = @(roiobj) guigetdata(roiobj, datacopy, shape = 'raw', x = kwargs.x, z = kwargs.z);
    end

    clf; tiledlayout('flow'); nexttile; ax = gca;
    plotframe(1);
    if kwargs.roi
            rois = guiselectregion(ax, moving = @eventroiselmoving, shape = 'poly', ...
            mask = kwargs.mask, interaction = 'all', number = 1);
        eventroiselmoving()
    end
    exportgraphics(ax, kwargs.filename);

    for i = 2:size(data, 3)
        plotframe(i);
        exportgraphics(ax, kwargs.filename, Append = true);
    end
end