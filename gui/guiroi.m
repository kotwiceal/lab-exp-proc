function rois = guiroi(target, draw, kwargs)
    %% Interactive data selection.

    arguments (Input)
        target
        draw {mustBeMember(draw, {'none', 'drawpoint', 'drawline', 'drawrectangle', 'drawpolygon', 'drawpolyline', 'drawcuboid', 'drawxrange', 'drawyrange'})} % type of region selection
        kwargs.position = [] % two row vertex to line selection; edge size to rectangle selection; n-row verxex to polygon selection 
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.number (1,:) {mustBeInteger, mustBePositive} = 1 % count of selection regions
        kwargs.moving (1,:) {mustBeA(kwargs.moving, {'function_handle', 'cell'})} = @(~, ~) [] % callback at moving ROI
        kwargs.moved (1,:) {mustBeA(kwargs.moved, {'function_handle', 'cell'})} = @(~, ~) [] % callback at had moving ROI
        kwargs.StripeColor (1,:) = []
        kwargs.colororder (1,:) = []
        kwargs.label (1,:) {mustBeA(kwargs.label, {'char', 'cell'})} = ''
        kwargs.aplha (1,:) double = []
        kwargs.tag (1,:) {mustBeA(kwargs.tag, {'char', 'cell'})} = ''
    end
    arguments (Output)
        rois (1,:) cell
    end

    rois = cell(1, kwargs.number);

    % pass
    if draw == "none"; return; end
    if kwargs.number == 0; return; end

    if isa(target, 'matlab.graphics.axis.Axes')
        ax = target;
    else
        ax = target.Parent;
    end

    colors = colororder(ax);

    if isempty(kwargs.number); kwargs.number = 1; end

    % transform method to handle
    roimethod = str2func(draw);

    if isa(kwargs.position, 'double'); kwargs.position = {kwargs.position}; end
    if isscalar(kwargs.position); kwargs.position = repmat(kwargs.position, 1, kwargs.number); end

    % if isa(kwargs.position, 'double'); kwargs.position = repmat({kwargs.position}, 1, kwargs.number); end
    if isa(kwargs.label, 'char'); kwargs.label = repmat({kwargs.label}, 1, kwargs.number); end
    if isa(kwargs.tag, 'char'); kwargs.tag = repmat({kwargs.tag}, 1, kwargs.number); end
    if isa(kwargs.moving, 'function_handle'); kwargs.moving = repmat({kwargs.moving}, 1, kwargs.number); end
    if isa(kwargs.moved, 'function_handle'); kwargs.moved = repmat({kwargs.moved}, 1, kwargs.number); end
    if isempty(kwargs.aplha); kwargs.aplha = ones(1, kwargs.number); end
    if isscalar(kwargs.aplha); kwargs.aplha = repmat(kwargs.aplha, 1, kwargs.number); end

    for i = 1:kwargs.number
        % assembly arguments
        if size(colors, 1) > 1; color = circshift(colors, 1-i); color = color(1,:); else; color = colors(1,:); end
        arg = {ax, 'InteractionsAllowed', kwargs.interaction, 'Color', color};
        if ~isempty(kwargs.StripeColor); arg = cat(2, arg, {'StripeColor'}, {kwargs.StripeColor}); end
        if ~isempty(kwargs.position{i}); arg = cat(2, arg, {'Position'}, {kwargs.position{i}}); end
        if ~isempty(kwargs.label{i}); arg = cat(2, arg, {'Label'}, {kwargs.label{i}}, {'LabelAlpha'}, {kwargs.aplha(i)}); end
        rois{i} = roimethod(arg{:});

        % create contex menu to change color
        contexmenu = uicontextmenu;
        uimenu(contexmenu, Text = 'Set Color', MenuSelectedFcn = @(src, evt) setfield(rois{i}, 'Color', uisetcolor));
        rois{i}.ContextMenu = contexmenu;

        addlistener(rois{i}, 'MovingROI', kwargs.moving{i});
        addlistener(rois{i}, 'ROIMoved', kwargs.moved{i});
        addlistener(rois{i}, 'MovingROI', @(src, ~) roisnaphandler(src, target));
        roisnaphandler(rois{i}, target);
    end
    
end