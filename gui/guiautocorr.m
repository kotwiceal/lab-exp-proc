function getdata = guiautocorr(data, kwargs)
    %% Visualize auto-correlation function of selected by rectangle ROI data.

    %% The function returns following results:
    %   getdata: [function handle] - function returning the last auto-correlation processing

    %% Examples
    %% 1. Show auto-correlation of signal with default parameters:
    % guiautocorr(data);
    %% 2. Show auto-correlation of signal with custom parameters:
    % guiautocorr(data, mask = [100, 150, 25, 25], display = '2d', clim = [0, 1], aspect = 'auto');
    
    arguments
        data (:,:) double % matrix data
        kwargs.x (:,:) double = [] % longitudinal spatial coordinate
        kwargs.y (:,:) double = [] % transversal spatial coordinate
        %% spectra processing parameters
        kwargs.norm (1,1) logical = false % norm auto-correlation
        kwargs.center (1,:) char {mustBeMember( kwargs.center, {'none', 'poly11', 'mean'})} = 'poly11' % center data
        %% roi and axis parameters
        kwargs.mask (1,:) double = [] % location and size of rectangle selection
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal' % axis aspect ratio
        kwargs.clim (1,:) double = [] % color axis limit
        kwargs.climspec (1,:) double = []
        kwargs.cscale (1,:) char {mustBeMember(kwargs.cscale, {'linear', 'log'})} = 'linear' % colormap scale
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'2d', '3d'})} = '2d' % display type
        kwargs.docked (1,1) logical = false % docked figure
        kwargs.colormap (1,:) char = 'turbo' % colormap of color axis
        kwargs.title (:,:) char = [] % figure title
        kwargs.filename (1,:) char = [] % filename to save figure
        kwargs.extension (1,:) char = '.png' % extension of saved figure
        kwargs.unit (1,:) char {mustBeMember(kwargs.unit, {'none', 'mm'})} = 'mm' % label axis unit
    end

    raw = []; xcorr = []; xraw = []; yraw = []; xc = []; yc = [];

    if isempty(kwargs.x) && isempty(kwargs.y)
        disptype = 'node'; 
        [x, y] = meshgrid(1:size(data, 2), 1:size(data, 1));
    else
        disptype = 'spatial';
        x = kwargs.x; y = kwargs.y;
    end

    % define funtion handle to probe data
    switch disptype
        case 'node'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', permute = [2, 1]);
            selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', permute = [2, 1]);
            selecty = @(roiobj) guigetdata(roiobj, y, shape = 'cut',permute = [2, 1]);
        case 'spatial'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', x = x, z = y);
            selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', x = x, z = y);
            selecty = @(roiobj) guigetdata(roiobj, y, shape = 'cut', x = x, z = y);
    end

    function event(~, ~)
        % extract data
        frame = select(rois{1}); raw = frame;
        xraw = selectx(rois{1}); yraw = selecty(rois{1});
        % centering data
        switch kwargs.center
            case 'poly11'
                sz = size(frame);
                [xc, yc] = meshgrid(1:sz(2), 1:sz(1));
                [xcp, ycp, framep] = prepareSurfaceData(xc, yc, frame);
                frameft = fit([xcp, ycp], framep, 'poly11');
                frame = frame - frameft(xc, yc); 
            case 'mean'
                frame = frame - mean(frame, [1, 2]);
        end
        % process auto-correlation
        if kwargs.norm; frame = normxcorr2(frame, frame); else; frame = xcorr2(frame); end; xcorr = frame;
        % build grid
        sz = size(xcorr);
        [xc, yc] = meshgrid(1:sz(2), 1:sz(1));
        switch disptype
            case 'node'
                dx = 1; dy = 1;
            case 'spatial'
                xu = unique(kwargs.x); yu = unique(kwargs.y);
                dx = xu(2)-xu(1);  dy = yu(2)-yu(1);
        end
        xc = (xc-xc(:,floor(sz(2)/2)+1))*dx; yc = (yc-yc(floor(sz(1)/2)+1,:))*dy;
        % display
        cla(ax); 
        switch kwargs.display
            case '2d'
                contourf(ax, xc, yc, frame, 100, 'LineStyle', 'None'); 
                % contourf(ax, frame, 100, 'LineStyle', 'None'); 
            case '3d'
                surf(ax, xc, yc, frame, 'LineStyle', 'None');
                % surf(ax, frame, 'LineStyle', 'None');
        end
        size(xcorr)
        switch disptype
            case 'node'
                xlabel(ax, 'x_{n}'); ylabel(ax, 'y_{n}');
            case 'spatial'
                switch kwargs.unit
                    case 'none'
                        xlabel(ax, 'x'); ylabel(ax, 'y');
                    case 'mm'
                        xlabel(ax, 'x, mm'); ylabel(ax, 'y, mm');
                end
        end
        colorbar(ax); colormap(ax, kwargs.colormap);
        set(ax, 'ColorScale', kwargs.cscale); 
        if ~isempty(kwargs.climspec); clim(ax, kwargs.climspec); end
        axis(ax, kwargs.aspect);
    end

    function result = getdatafunc()
        result = struct('raw', raw, 'x', xraw, 'y', yraw, 'xcorr', xcorr, 'xc', xc, 'yc', yc);
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); axroi = nexttile;
    switch disptype
        case 'node'
            imagesc(axroi, data); axis(axroi, 'image');
        case 'spatial'
            contourf(axroi, x, y, data, 100, 'LineStyle', 'None'); 
            axis(axroi, kwargs.aspect);
    end
    switch disptype
        case 'node'
            xlabel(axroi, 'x_{n}'); ylabel(axroi, 'y_{n}');
        case 'spatial'
            switch kwargs.unit
                case 'none'
                    xlabel(axroi, 'x'); ylabel(axroi, 'y');
                case 'mm'
                    xlabel(axroi, 'x, mm'); ylabel(axroi, 'y, mm');
            end
    end
    colormap(axroi, kwargs.colormap);
    if ~isempty(kwargs.clim); clim(axroi, kwargs.clim); end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, moved = @event, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 1);

    event();

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

    getdata = @getdatafunc;

end