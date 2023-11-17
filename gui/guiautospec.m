function rois = guiautospec(axroi, data, named)
%% Visualalize auto-spectra of selected by rectangle ROI data.
%% The function takes following arguments:
%   axroi:  [axes object]       - axis object of canvas that selection data events are being occured
%   data:   [n×m double]        - multidimensional data
%   shape:  [1×2 double]        - box selection size
%   crange: [1×2 double]        - color axis limit

%% Visualize statistics data by means manually region selection.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m double]                    - multidimensional data
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; 
%                                                       n-row verxex to polygon selection 
%   crange:         [1×2 double]                    - color axis limit
%   interaction:    [char]                          - region selection behaviour
%   number:         [int]                           - count of selection regions
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.mask double = []
        named.interaction char = 'all'
        named.crange double = []
    end

    select = @(roiobj) imcrop(data, roiobj.Position);

    function event(~, evt)
        frame = select(evt.Source);
        frame = fftshift(abs(fft2(frame)));

        cla(ax); imagesc(ax, frame); colorbar(ax); colormap(ax, 'turbo');
        set(ax, 'ColorScale', 'Log'); 
        if ~isempty(named.crange)
            clim(ax, named.crange);
        end
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'rect', ...
        mask = named.mask, interaction = named.interaction, number = 1);

end