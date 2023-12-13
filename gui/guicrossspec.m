function rois = guicrossspec(axroi, data, named)
%% Visualalize cross-spectra function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - matrix data
%   mask:           [1×2 double]                    - size of rectangle selection
%   clim:           [1×2 double]                    - color axis limit
%   cscale:         [char array]                    - colormap scale
%   type:           [char array]                    - type of displayed value
%   display:        [char array]                    - display type
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.mask double = [10, 10]
        named.interaction char = 'translate'
        named.clim double = []
        named.cscale char = 'log'
        named.norm logical = true
        named.type char = 'abs'
        named.display char = 'imagesc'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)

        value = [];
        for i = 1:length(rois)
            value(:, :, i) = select(rois{i});
            value(:, :, i) = fftshift(fft2(value(:, :, i)));
        end

        if named.norm
            frame = value(:,:,1).*conj(value(:,:,2))./sqrt(abs(value(:,:,1)).*abs(value(:,:,2)));
        else
            frame = value(:,:,1).*value(:,:,2);
        end

        switch named.type
            case 'abs'
                frame = abs(frame);
            case 'real'
                frame = real(frame);
            case 'imag'
                frame = imag(frame);
        end

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
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 2);

end