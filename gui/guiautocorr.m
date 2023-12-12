function rois = guiautocorr(axroi, data, named)
%% Visualalize auto-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - matrix data
%   mask:           [1×2 double]                    - size of rectangle selection
%   clim:           [1×2 double]                    - color axis limit
%   interaction:    [char]                          - region selection behaviour
%   cscale:         [char array]                    - colormap scale
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.mask double = [10, 10]
        named.interaction char = 'translate'
        named.clim double = []
        named.cscale char = 'log'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)

        value = select(rois{1});

        cla(ax); imagesc(ax, xcorr2(value)); colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', named.cscale); 
        if ~isempty(named.clim)
            clim(ax, named.clim);
        end
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 1);

end