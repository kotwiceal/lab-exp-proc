function rois = guiautospec(axroi, data, kwargs)
%% Visualize auto-spectra of selected by rectangle ROI data.
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
% guiautospec(gca, data);
%
%% show auto-correlation of signal with custom parameters
% data = rand(270, 320);
% clf; tiledlayout(1, 2);
% nexttile; imagesc(data);
% guiautospec(gca, data, mask = [100, 150, 25, 25], display = 'surf', clim = [0, 1], aspect = 'auto', cscale = 'log');
    
    arguments
        axroi matlab.graphics.axis.Axes
        data double
        %% roi and axis parameters
        kwargs.mask double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'translate'
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal'
        kwargs.clim double = []
        kwargs.cscale (1,:) char {mustBeMember(kwargs.cscale, {'linear', 'log'})} = 'linear'
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'imagesc', 'surf'})} = 'imagesc'
    end

    warning off

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, ~)
        frame = select(rois{1});  % extract data by gui
        frame = fftshift(abs(fft2(frame))); % process

        % display
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
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 1);

    event();

end