function rois = guicrosscorr(axroi, data, named)
%% Visualalize cross-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - matrix data
%   mask:           [1×2 double]                    - size of rectangle selection
%   clim:           [1×2 double]                    - color axis limit
%   cscale:         [char array]                    - colormap scale
%   type:           [char array]                    - type of displayed value
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.mask double = [10, 10]
        named.interaction char = 'translate'
        named.clim double = []
        named.cscale char = 'linear'
        named.type char = 'mul'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)

        value = [];

        for i = 1:length(rois)
            value(:, :, i) = select(rois{i});
        end

        switch named.type
            case 'xcorr'
                frame = xcorr2(value(:, :, 1), value(:, :, 2));
            case 'mul'
                frame = value(:, :, 1) .* value(:, :, 2);
        end

        cla(ax); imagesc(ax, frame); colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', named.cscale); 
        if ~isempty(named.clim)
            clim(ax, named.clim);
        end
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 2);

end