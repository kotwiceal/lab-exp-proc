function rois = guiautocorr(axroi, data, named)
%% Visualalize auto-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - matrix data
%   mask:           [1×2 double]                    - size of rectangle selection
%   clim:           [1×2 double]                    - color axis limit
%   interaction:    [char]                          - region selection behaviour
%   cscale:         [char array]                    - colormap scale
%   display:        [char array]                    - display type
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.mask double = [10, 10]
        named.interaction char = 'translate'
        named.clim double = []
        named.cscale char = 'linear'
        named.display char = 'imagesc'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)

        value = select(rois{1});

        cla(ax); 
        switch named.display
            case 'imagesc'
                imagesc(ax, xcorr2(value)); 
            case 'surf'
                surf(ax, xcorr2(value));
        end
        colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', named.cscale); 
        if ~isempty(named.clim)
            clim(ax, named.clim);
        end
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 1);

end