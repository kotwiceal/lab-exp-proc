function rois = guiselectregion(axroi, kwargs)
    %% Interactive data selection.

    arguments (Input)
        axroi matlab.graphics.axis.Axes % axis object of canvas that selection data events are being occured
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'point', 'line', 'rect', 'polygon', 'cube', 'polyline'})} = 'rect' % type of region selection
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = [] % two row vertex to line selection; edge size to rectangle selection; n-row verxex to polygon selection 
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.number (1,1) double {mustBeInteger} = 1 % count of selection regions
        kwargs.moving (1,:) {mustBeA(kwargs.moving, {'function_handle', 'cell'})} = @(~, ~) [] % callback at moving ROI
        kwargs.moved (1,:) {mustBeA(kwargs.moved, {'function_handle', 'cell'})} = @(~, ~) [] % callback at had moving ROI
        kwargs.StripeColor (1,:) = []
        kwargs.colororder (1,:) = []
        kwargs.label (1,:) {mustBeA(kwargs.label, {'char', 'cell'})} = ''
        kwargs.aplha (1,:) double = []
    end

    arguments (Output)
        rois (1,:) cell
    end

    if isempty(kwargs.colororder)
        if isMATLABReleaseOlderThan("R2023b")
            kwargs.colororder = {'blue'}; 
        else
            kwargs.colororder = 'gem'; 
        end
    end
    colors = colororder(axroi, kwargs.colororder);

    roimethod = {};
    switch kwargs.shape
        case 'point'
            roimethod = @drawpoint;
        case 'line'
            roimethod = @drawline;
        case 'rect'
            roimethod = @drawrectangle;
        case 'polygon'
            roimethod = @drawpolygon;
        case 'cube'
            roimethod = @drawcuboid;
        case 'polyline'
            roimethod = @drawpolyline;
    end

    rois = cell(1, kwargs.number);

    if isa(kwargs.mask, 'double'); kwargs.mask = repmat({kwargs.mask}, 1, kwargs.number); end
    if isa(kwargs.label, 'char'); kwargs.label = repmat({kwargs.label}, 1, kwargs.number); end
    if isa(kwargs.moving, 'function_handle'); kwargs.moving = repmat({kwargs.moving}, 1, kwargs.number); end
    if isa(kwargs.moved, 'function_handle'); kwargs.moved = repmat({kwargs.moved}, 1, kwargs.number); end
    if isempty(kwargs.aplha); kwargs.aplha = ones(1, kwargs.number); end
    if isscalar(kwargs.aplha); kwargs.aplha = repmat(kwargs.aplha, 1, kwargs.number); end

    for i = 1:kwargs.number
        if size(colors, 1) > 1; color = circshift(colors, 1-i); color = color(1,:); else; color = colors(1,:); end
        arg = {axroi, 'InteractionsAllowed', kwargs.interaction, 'Color', color};
        if ~isempty(kwargs.StripeColor); arg = cat(2, arg, {'StripeColor'}, {kwargs.StripeColor}); end
        if ~isempty(kwargs.mask{i}); arg = cat(2, arg, {'Position'}, {kwargs.mask{i}}); end
        if ~isempty(kwargs.label{i}); arg = cat(2, arg, {'Label'}, {kwargs.label{i}}, {'LabelAlpha'}, {kwargs.aplha(i)}); end
        rois{i} = roimethod(arg{:});
        addlistener(rois{i}, 'MovingROI', kwargs.moving{i});
        addlistener(rois{i}, 'ROIMoved', kwargs.moved{i});
    end
    
end