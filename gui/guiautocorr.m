function rois = guiautocorr(axroi, data, named)
%% Visualalize auto-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
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
        axroi matlab.graphics.axis.Axes
        data double
        %% roi and axis parameters
        named.mask double = []
        named.interaction char = 'translate'
        named.aspect char = 'equal'
        named.clim double = []
        named.cscale char = 'linear'
        named.display char = 'imagesc'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)
        value = select(rois{1}); % extract data by gui
        frame = xcorr2(value); % process

        % display
        cla(ax); 
        switch named.display
            case 'imagesc'
                imagesc(ax, frame); 
            case 'surf'
                surf(ax, frame);
        end
        colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', named.cscale); 
        if ~isempty(named.clim)
            clim(ax, named.clim);
        end
        axis(ax, named.aspect)
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 1);

    event();

end