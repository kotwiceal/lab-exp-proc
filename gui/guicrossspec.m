function rois = guicrossspec(axroi, data, named)
%% Visualalize cross-spectra function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - matrix data
%   type:           [char array]                    - type of displayed value: 'abs', 'real', 'imag'
%   norm:           [char array]                    - normalize result: true, false
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
% guicrossspec(gca, data);
%
%% show auto-correlation of signal with custom parameters
% data = rand(270, 320);
% clf; tiledlayout(1, 2);
% nexttile; imagesc(data);
% guicrossspec(gca, data, type = 'real', norm = false, mask = [100, 150, 25, 25], display = 'surf', clim = [0, 1], aspect = 'auto');


    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.type (1,:) char {mustBeMember(named.type, {'abs', 'real', 'imag'})} = 'abs'
        named.norm logical = true
        %% roi and axis parameters
        named.mask double = []
        named.interaction (1,:) char {mustBeMember(named.interaction, {'all', 'none', 'translate'})} = 'translate'
        named.aspect (1,:) char {mustBeMember(named.aspect, {'equal', 'auto'})} = 'equal'
        named.clim double = []
        named.cscale (1,:) char {mustBeMember(named.cscale, {'linear', 'log'})} = 'linear'
        named.display (1,:) char {mustBeMember(named.display, {'imagesc', 'surf'})} = 'imagesc'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)

        value = [];
        % extract data by gui & process
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
        axis(ax, named.aspect)
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 2);

    event();

end