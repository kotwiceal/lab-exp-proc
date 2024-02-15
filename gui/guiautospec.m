function rois = guiautospec(data, kwargs)
%% Visualize auto-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   data:           [n×m double]                    - matrix data
%   mask:           [1×2 double]                    - size of rectangle selection
%   interaction:    [char array]                    - region selection behaviour: 'translate', 'all' (see ROI object) 
%   aspect:         [char array]                    - axis aspect ratio: 'equal', 'auto' 
%   clim:           [1×2 double]                    - color axis limit
%   cscale:         [char array]                    - colormap scale
%   display:        [char array]                    - display type: 'imagesc', 'surf'
%   docked:         [1×1 logical]                   - docker figure
%   colormap:       [char array]                    - colormap
%% The function returns following results:
%   rois:           [object]                        - ROI cell objects
%% Examples
%% 1. Show auto-spectra of signal with default parameters:
% guiautospec(data);
%% 2. Show auto-correlation of signal with custom parameters:
% guiautospec(data, mask = [100, 150, 25, 25], display = 'surf', clim = [0, 1], aspect = 'auto');
        
    arguments
        data double
        kwargs.x double = []
        kwargs.y double = []
        %% roi and axis parameters
        kwargs.mask (:,:) double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal'
        kwargs.clim double = []
        kwargs.climspec double = []
        kwargs.cscale (1,:) char {mustBeMember(kwargs.cscale, {'linear', 'log'})} = 'log'
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'imagesc', 'surf'})} = 'imagesc'
        kwargs.docked logical = false
        kwargs.colormap (1,:) char = 'turbo'
        %% spectra processing parameters
        kwargs.submean logical = true
    end

    if isempty(kwargs.x) && isempty(kwargs.y)
        disp_type = 'node';
    else
        disp_type = 'spatial';
    end

    % define funtion handle to probe data
    switch disp_type
        case 'node'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'cut');
        case 'spatial'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', ...
                x = kwargs.x, z = kwargs.y);
    end

    function event(~, ~)

        frame = select(rois{1});  % extract data by gui
        if kwargs.submean
            frame = frame - mean(frame, [1, 2]);
        end
        frame = fftshift(abs(fft2(frame))); % process

        switch disp_type
            case 'node'
                [f1, f2] = ngrid(1:size(frame, 2), 1:size(frame, 1));
            case 'spatial'
                xu = unique(kwargs.x); yu = unique(kwargs.y);
                dx = xu(2)-xu(1);  dy = yu(2)-yu(1);
                fdx = 1/dx; fdy = 1/dy;
                
                dfdx = fdx/size(frame, 2);
                dfdy = fdy/size(frame, 1);
                
                f1 = -fdx/2+dfdx/2:dfdx:fdx/2-dfdx/2;
                f2 = -fdy/2+dfdy/2:dfdy:fdy/2-dfdy/2;
                
                [f1, f2] = meshgrid(f1, f2);
        end

        % display
        cla(ax); 
        switch disp_type
            case 'node'
                switch kwargs.display
                    case 'imagesc'
                        imagesc(ax, frame); 
                    case 'surf'
                        surf(ax, frame, 'LineStyle', 'None');
                end
            case 'spatial'
                switch kwargs.display
                    case 'contourf'
                        contourf(ax, f1, f2, frame, 100, 'LineStyle', 'None'); 
                    case 'surf'
                        surf(ax, f1, f2, frame, 'LineStyle', 'None');
                end
        end

        colorbar(ax); colormap(ax, kwargs.colormap);
        set(ax, 'ColorScale', kwargs.cscale); 
        if ~isempty(kwargs.climspec); clim(ax, kwargs.climspec); end
        % axis(ax, kwargs.aspect)
    end

    if kwargs.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout('flow');
    nexttile; axroi = gca; 
    switch disp_type
        case 'node'
            imagesc(axroi, data);
        case 'spatial'
            contourf(axroi, kwargs.x, kwargs.y, data, 100, 'LineStyle', 'None'); 
    end
    colormap(axroi, kwargs.colormap);
    axis(axroi, kwargs.aspect);
    if ~isempty(kwargs.clim); clim(axroi, kwargs.clim); end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, moved = @event, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 1);

    event();

end