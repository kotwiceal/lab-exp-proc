function animrec(varargin, kwargs)
    %% Animation recorder of 2D multi-frame data.

    %% Examples:
    %% 1. Record animation of set 2D multi-frame
    % animrec(rand(120, 140, 10), filename = 'test.gif', clim = [-1, 1], aspect = 'equal')
    %% 2. Record animation by means custom scene
    % animrec(plotfunc = @(axis,index) handle(axis,index,data), range = 1:size(data,3), ...
    %   filename = 'test.gif')
    %% 3. Record animation of tiled images
    % animrec([rand(120, 140, 10), rand(120, 140, 10)], plotfunc = 'imtile', ...
    %   xticklabels = {'tile-1', 'tile-2'}, filename = 'test.gif', clim = [-1, 1])

    arguments (Input, Repeating)
        varargin (:,:,:)
    end

    arguments (Input)
        kwargs.range (1,:) double = [] % index frame
        kwargs.x (:,:) double = [] % longitudinal spatial coordinate
        kwargs.y (:,:) double = [] % transversal spatial coordinate
        % kwargs.plotfunc {mustBeA(kwargs.plotfunc, {'function_handle', 'char'}), mustBeMember(kwargs.plotfunc, {'none', 'imtile'})} = 'none' % custom plotter handle
        kwargs.plotfunc = 'none' % custom plotter handle
        kwargs.filename = '' % filename of storing animation
        kwargs.resolution (1,1) double = 300
        kwargs.mask (:,:) double = [] % roi mask
        kwargs.roi (1,1) logical = false % cut data by roi
        kwargs.hold (1,:) char {mustBeMember(kwargs.hold, {'on', 'off'})} = 'off'
        kwargs.grid (1,:) char {mustBeMember(kwargs.grid, {'on', 'off'})} = 'on'
        kwargs.box (1,:) char {mustBeMember(kwargs.box, {'on', 'off'})} = 'on'
        kwargs.xlabel (1,:) char = [] % x-axis label
        kwargs.ylabel (1,:) char = [] % y-axis label
        kwargs.aspect (1,:) {mustBeA(kwargs.aspect, {'char', 'cell'}), mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        kwargs.pbaspect (1,:) = [1, 1, 1]
        kwargs.fontsize (1,1) double = 14
        kwargs.fontunits {mustBeMember(kwargs.fontunits, {'points', 'pixels', 'inches', 'centimeters'})} = 'centimeters'
        kwargs.xlim (:,:) {mustBeA(kwargs.xlim, {'double', 'cell'})} = [] % x-axis limit
        kwargs.ylim (:,:) {mustBeA(kwargs.ylim, {'double', 'cell'})} = [] % y-axis limit
        kwargs.clim (1,:) double = [] % color axis limit
        kwargs.colorbar (1,1) logical = false % show colorbar
        kwargs.colorbarloc (1,:) char = 'eastoutside' % colorbar location
        kwargs.clabel (1,:) {mustBeA(kwargs.clabel, {'char', 'cell'})} = {} % color-axis label
        kwargs.title (1,:) char = [] % figure title
        kwargs.xticklabels = []
        kwargs.yticklabels = []
        kwargs.colormap {mustBeMember(kwargs.colormap, {'parula','turbo','hsv','hot','cool','spring','summer','autumn',...
            'winter','gray','bone','copper','pink','sky','abyss','jet','lines','colorcube','prism','flag','white'})} = 'turbo'
        kwargs.docked (1,1) logical = true
        kwargs.figsize = []
        kwargs.figunits {mustBeMember(kwargs.figunits, {'points', 'pixels', 'inches', 'centimeters'})} = 'centimeters'
        kwargs.md (1,:) char = []
        kwargs.framesz (1,1) = 400
        kwargs.theme {mustBeMember(kwargs.theme, {'light', 'dark', 'auto'})} = "light"
    end

    if nargin == 0
        data = [];
    else
        data = varargin{1};
    end

    function plotfunc(ax, index)
        cla(ax); set(ax, 'FontSize', kwargs.fontsize, 'FontUnits', kwargs.fontunits); pbaspect(kwargs.pbaspect);
        if display
            imagesc(ax, data(:,:,index));
            if display_label
                xlabel(ax, 'x_{n}'); ylabel(ax, 'z_[n}');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
        else
            hold(ax, kwargs.hold);
            contourf(ax, kwargs.x, kwargs.y, data(:,:,index), 100, 'LineStyle', 'None');
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

    function imtilehand(ax, index)   
        cla(ax); imagesc(data(:,:,index)); axis(ax, 'image');
        
        xtick = numel(kwargs.xticklabels);
        ytick = numel(kwargs.yticklabels);

        if ~isempty(xtick)
            xtick = size(data,2)/(2*xtick):size(data,2)/xtick:size(data,2);
        end
    
        if ~isempty(ytick)
            ytick = size(data,1)/(2*ytick):size(data,1)/ytick:size(data,1);
        end
    
        set(ax, 'XTick', xtick, 'YTick', ytick, ...
            'XTickLabels', kwargs.xticklabels, 'YTickLabels', kwargs.yticklabels, ...
            'FontSize', kwargs.fontsize, 'FontUnits', kwargs.fontunits)
    
        ytickangle(ax, 90);

        if ~isempty(kwargs.clim); clim(ax, kwargs.clim); end
        colormap(ax, kwargs.colormap);
    
        if class(kwargs.title) == "function_handle"
            label = kwargs.title(index);
        else
            label = kwargs.title;
        end
    
        title(label, FontWeight = 'normal');
    
    end

    function eventroiselmoving(~, ~)
        data = select(rois{1});
        kwargs.plotfunc(ax, 1);
    end

    display = isempty(kwargs.x) & isempty(kwargs.y); 
    display_label = isempty(kwargs.xlabel) & isempty(kwargs.ylabel);
    rois = [];

    datacopy = data;
    if display
        select = @(roiobj) guigetdata(roiobj, datacopy, shape = 'raw');
    else
        select = @(roiobj) guigetdata(roiobj, datacopy, shape = 'raw', x = kwargs.x, z = kwargs.y);
    end

    if isempty(kwargs.plotfunc); kwargs.plotfunc = @plotfunc; end

    switch class(kwargs.plotfunc)
        % case 'function_handle'
        %     kwargs.plotfunc = @plotfunc;
        case 'char'
            switch kwargs.plotfunc
                case 'imtile'
                    kwargs.plotfunc = @imtilehand;
                otherwise
                    kwargs.plotfunc = @plotfunc;
            end
    end


    if isempty(data) && isempty(kwargs.range) && isempty(kwargs.plotfunc); error('empty instruction'); end
    if isempty(kwargs.range); kwargs.range = 2:size(data,3); end

    if isfolder(kwargs.filename); kwargs.filename = fullfile(kwargs.filename, strrep(string(datetime), ':', '-')+".gif"); end 
    
    if kwargs.docked; fig = figure(WindowStyle = 'docked'); else clf; fig = gcf; end
    clf; tiledlayout('flow'); nexttile; ax = gca;

    if ~isempty(kwargs.figsize)
        set(fig, WindowStyle = 'normal')
        set(fig, Units = kwargs.figunits, Position = [0, 0, kwargs.figsize])
    end

    try; theme(fig, kwargs.theme); catch; end

    tf = true;
    for i = kwargs.range
        kwargs.plotfunc(ax, i);
        if tf
            if kwargs.roi
                    rois = guiselectregion(ax, moving = @eventroiselmoving, shape = 'poly', ...
                    mask = kwargs.mask, interaction = 'all', number = 1);
                eventroiselmoving()
            end
            exportgraphics(ax, kwargs.filename, Resolution = kwargs.resolution);
            tf = false;
        else
            exportgraphics(ax, kwargs.filename, Append = true, Resolution = kwargs.resolution);
        end
    end

    if kwargs.docked; set(fig, WindowStyle = 'docked'); end

    if ~isempty(kwargs.md)
        [~, filename, extension] = fileparts(kwargs.filename);
        obscontpast(kwargs.md, strcat(filename, extension), fig = false, size = kwargs.framesz);
    end

end