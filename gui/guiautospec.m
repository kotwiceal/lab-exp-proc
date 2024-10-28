function getdata = guiautospec(data, kwargs)
    %% Visualize auto-spectrum function of selected by rectangle ROI data.

    %% The function returns following results:
    %   getdata: [function handle] - function returning the last spectrum processing

    %% Examples
    %% 1. Show auto-spectra of signal with default parameters:
    % guiautospec(data);
    %% 2. Show auto-spectra of signal with custom parameters:
    % guiautospec(data, mask = [100, 150, 25, 25], display = '2d', clim = [0, 1], aspect = 'auto', center = 'none');
        
    arguments
        data (:,:) double % matrix data
        kwargs.x (:,:) double = [] % longitudinal spatial coordinate
        kwargs.y (:,:) double = [] % transversal spatial coordinate
        %% spectra processing parameters
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'none', 'psd'})} = 'psd' % norm auto-spectra
        kwargs.center (1,:) char {mustBeMember( kwargs.center, {'none', 'poly11', 'mean'})} = 'poly11' % center data
        kwargs.winfun char {mustBeMember(kwargs.winfun, {'none', 'hann', 'hamming', 'tukey'})} = 'hann' % window funtion at Fourier transform
        %% roi and axis parameters
        kwargs.mask (:,:) double = [] % location and size of rectangle selection
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal' % axis aspect ratio
        kwargs.clim (1,:) double = [] % color axis limit
        kwargs.climspec (1,:) double = []
        kwargs.clabel (1,:) char = []
        kwargs.cscale (1,:) char {mustBeMember(kwargs.cscale, {'linear', 'log'})} = 'log' % colormap scale
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'2d', '3d'})} = '2d' % display type
        kwargs.docked (1,1) logical = false % docked figure
        kwargs.colormap (1,:) char = 'turbo' % colormap of color axis
        kwargs.title (:,:) char = [] % figure title
        kwargs.filename (1, :) char = [] % filename to save figure
        kwargs.extension (1, :) char = '.png' % extension of saved figure
        kwargs.unit (1,:) char {mustBeMember(kwargs.unit, {'none', 'mm'})} = 'mm' % label axis unit
    end

    raw = []; spec = []; xraw = []; yraw = []; fx = []; fy = [];

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
        frame = select(rois{1}); raw = frame; sz = size(frame);
        xraw = selectx(rois{1}); yraw = selecty(rois{1});
        % build frequency grid
        switch disptype
            case 'node'
                [fx, fy] = meshgrid(1:sz(2), 1:sz(1));
                dfdx = 1; dfdy = 1;
            case 'spatial'
                xu = unique(kwargs.x); yu = unique(kwargs.y);
                dx = xu(2)-xu(1);  dy = yu(2)-yu(1);
                fdx = 1/dx; fdy = 1/dy;
                dfdx = fdx/sz(2);
                dfdy = fdy/sz(1);
                fx = -fdx/2+dfdx/2:dfdx:fdx/2-dfdx/2;
                fy = -fdy/2+dfdy/2:dfdy:fdy/2-dfdy/2;
                [fx, fy] = meshgrid(fx, fy);
        end
        % centering data
        switch kwargs.center
            case 'poly11'
                [fxp, fyp, framep] = prepareSurfaceData(fx, fy, frame);
                frameft = fit([fxp, fyp], framep, 'poly11');
                frame = frame - frameft(fx, fy); 
            case 'mean'
                frame = frame - mean(frame, [1, 2]);
        end
        switch kwargs.winfun
            case 'hann'
                win = hann(sz(1)).*hann(sz(2))';
            case 'tukey'
                win = tukeywin(sz(1), 1).*tukeywin(sz(2), 1)';
            case 'humming'
                win = humming(sz(1)).*humming(sz(2))';
            otherwise
                win = ones(sz);
        end
        acf = 1/mean(win(:));
        frame = frame.*win;
        % process fft
        frame = fftshift(fftshift(abs(fft2(frame)),1),2)*acf;
        % norm spectrum
        switch kwargs.norm
            case 'psd'
                frame = frame/dfdx/dfdy;
        end
        spec = frame;
        % display
        cla(ax); 
        switch kwargs.display
            case '2d'
                contourf(ax, fx, fy, frame, 100, 'LineStyle', 'None'); 
            case '3d'
                surf(ax, fx, fy, frame, 'LineStyle', 'None');
        end
        switch disptype
            case 'node'
                xlabel(ax, 'f_{xn}'); ylabel(ax, 'f_{yn}');
            case 'spatial'
                switch kwargs.unit
                    case 'none'
                        xlabel(ax, 'f_{x}'); ylabel(ax, 'f_{y}');
                    case 'mm'
                        xlabel(ax, 'f_{x}, mm^{-1}'); ylabel(ax, 'f_{y}, mm^{-1}');
                end
        end
        c = colorbar(ax); colormap(ax, kwargs.colormap);
        if ~isempty(kwargs.clabel); ylabel(c, kwargs.clabel); end
        set(ax, 'ColorScale', kwargs.cscale); 
        if ~isempty(kwargs.climspec); clim(ax, kwargs.climspec); end
        axis(ax, kwargs.aspect)
    end

    function result = getdatafunc()
        result = struct('raw', raw, 'x', xraw, 'y', yraw, 'spec', spec, ...
            'fx', fx, 'fy', fy, 'mask', rois{1}.Position);
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); axroi = nexttile;
    switch disptype
        case 'node'
            imagesc(axroi, data);
        case 'spatial'
            contourf(axroi, x, y, data, 100, 'LineStyle', 'None'); 
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
    axis(axroi, kwargs.aspect);
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