function rois = guicrosscorr(axroi, data, kwargs)
%% Visualize cross-correlation function of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - matrix data
%   type:           [char array]                    - type of displayed value: 'xcorr', 'mul' 
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
% guicrosscorr(gca, data);
%
%% show auto-correlation of signal with custom parameters
% data = rand(270, 320);
% clf; tiledlayout(1, 2);
% nexttile; imagesc(data);
% guicrosscorr(gca, data, mask = [100, 150, 25, 25], display = 'surf', clim = [0, 1], aspect = 'auto');

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'xcorr', 'mul'})} = 'xcorr'
        %% roi and axis parameters
        kwargs.mask double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'translate'
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'manual'})} = 'equal'
        kwargs.clim double = []
        kwargs.cscale (1,:) char {mustBeMember(kwargs.cscale, {'linear', 'log'})} = 'linear'
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'imagesc', 'surf'})} = 'imagesc'
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)

        value = [];

        % extract data by gui
        for i = 1:length(rois)
            value(:, :, i) = select(rois{i});
        end

        % process
        switch kwargs.type
            case 'xcorr'
                frame = xcorr2(value(:, :, 1), value(:, :, 2));
            case 'mul'
                frame = value(:, :, 1) .* value(:, :, 2);
        end

        cla(ax); 
        switch kwargs.display
            case 'imagesc'
                imagesc(ax, frame); 
            case 'surf'
                surf(ax, frame);
        end
        colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', kwargs.cscale); 
        if ~isempty(kwargs.clim)
            clim(ax, kwargs.clim);
        end
        axis(ax, kwargs.aspect)
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, moved = @event, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 2);

    event();

end