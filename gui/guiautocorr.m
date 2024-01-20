function rois = guiautocorr(data, named)
%% Visualalize auto-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   data:           [n×m double]                    - matrix data
%   mask:           [1×2 double]                    - size of rectangle selection
%   interaction:    [char array]                    - region selection behaviour: 'translate', 'all' (see ROI object) 
%   aspect:         [char array]                    - axis aspect ratio: 'equal', 'auto' 
%   clim:           [1×2 double]                    - color axis limit
%   cscale:         [char array]                    - colormap scale
%   display:        [char array]                    - display type: 'imagesc', 'surf' 
%% The function returns following results:
%   rois:           [object]                        - ROI cell objects
%% Examples
%% show auto-correlation of signal with default parameters
% data = rand(270, 320);
% clf; tiledlayout(1, 2);
% nexttile; imagesc(data);
% guiautocorr(gca, data);
%
%% show auto-correlation of signal with custom parameters
% data = rand(270, 320);
% clf; tiledlayout(1, 2);
% nexttile; imagesc(data);
% guiautocorr(gca, data, mask = [100, 150, 25, 25], display = 'surf', clim = [0, 1], aspect = 'auto');
    
    arguments
        data double
        named.x double = []
        named.y double = []
        %% roi and axis parameters
        named.mask (:,:) double = []
        named.interaction (1,:) char {mustBeMember(named.interaction, {'all', 'none', 'translate'})} = 'all'
        named.aspect (1,:) char {mustBeMember(named.aspect, {'equal', 'auto'})} = 'equal'
        named.clim double = []
        named.cscale (1,:) char {mustBeMember(named.cscale, {'linear', 'log'})} = 'linear'
        named.display (1,:) char {mustBeMember(named.display, {'imagesc', 'surf'})} = 'imagesc'
        named.docked logical = false
    end

    if isempty(named.x) && isempty(named.y)
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
                type = 'spatial', x = named.x, z = named.y);
    end

    function event(~, ~)
        value = select(rois{1}); % extract data by gui
        frame = xcorr2(value); % process

        % display
        cla(ax); 
        switch disp_type
            case 'node'
                switch named.display
                    case 'imagesc'
                        imagesc(ax, frame); 
                    case 'surf'
                        surf(ax, frame, 'LineStyle', 'None');
                end
            case 'spatial'
                % x = selectx(rois{1}); y = selecty(rois{1});
                switch named.display
                    case 'imagesc'
                        % contourf(ax, x, y, frame, 'LineStyle', 'None'); 
                        contourf(ax, frame, 'LineStyle', 'None'); 
                    case 'surf'
                        % surf(ax, x, y, frame, 'LineStyle', 'None');
                        surf(ax, frame, 'LineStyle', 'None');
                end
        end

        colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', named.cscale); 
        if ~isempty(named.clim)
            clim(ax, named.clim);
        end
        axis(ax, named.aspect)
    end

    if named.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout(1, 2);
    nexttile; axroi = gca; 
    switch disp_type
        case 'node'
            imagesc(axroi, data);
        case 'spatial'
            contourf(axroi, named.x, named.y, data, 'LineStyle', 'None'); 
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 1);

    event();

end