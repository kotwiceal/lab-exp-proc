function rois = guiroi(target, kwargs)
    %% Interactive data selection.

    arguments (Input)
        target
        kwargs.draw {mustBeMember(kwargs.draw, {'none', 'drawpoint', 'drawline', 'drawrectangle', 'drawpolygon', 'drawpolyline', 'drawcuboid'})} = 'drawpoint' % type of region selection
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
    if kwargs.draw == "none"; return; end
    if kwargs.number == 0; return; end

    if ~isa(target, 'matlab.graphics.axis.Axes')
        snap = target;
        target = target.Parent;
    else
        snap = [];
    end

    colors = colororder(target);

    if isempty(kwargs.number); kwargs.number = 1; end

    % transform method to handle
    roimethod = str2func(kwargs.draw);

    % snap to plot
    switch class(snap)
        case 'matlab.graphics.chart.primitive.Line'
            snapfunc = @(src) snaphandler(src, [snap.XData; snap.YData]');
        case 'matlab.graphics.primitive.Image'
            sz = flip(size(snap.CData));
            points = cell(1, numel(sz));
            sz = cellfun(@(x) 1:x, num2cell(sz, 1), UniformOutput = false);
            [points{:}] = ndgrid(sz{:});
            points = cellfun(@(x) x(:), points, UniformOutput = false);
            points = cell2mat(points);
            snapfunc = @(src) snaphandler(src, points, sz = size(snap.CData));
        case 'matlab.graphics.chart.primitive.Contour'
            snapfunc = @(src) snaphandler(src, [snap.XData(:), snap.YData(:)], sz = size(snap.XData));
        otherwise
            snapfunc = @(x) [];
    end

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
        arg = {target, 'InteractionsAllowed', kwargs.interaction, 'Color', color};
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
        addlistener(rois{i}, 'MovingROI', @(src, ~) snapfunc(src));
        snapfunc(rois{i});
    end
    
end

function snaphandler(src, pos, kwargs)
    arguments
        src
        pos
        kwargs.sz (1,:) double = []
    end
    switch class(src)
        case 'images.roi.Rectangle'
            curpos = src.Position;
            vertexes = [curpos(1), curpos(2); curpos(1)+curpos(3), curpos(2); ...
                curpos(1)+curpos(3), curpos(2)+curpos(4); curpos(1), curpos(2)+curpos(4)];
            k = dsearchn(pos, vertexes);
            src.UserData.linind = k;
            actvertexes = pos(k,:);
            actvertexes = sort(actvertexes, 1);
            actpos = [actvertexes(1,1), actvertexes(1,2), ...
                actvertexes(4,1)-actvertexes(1,1), actvertexes(4,2)-actvertexes(1,2)];
            src.Position = actpos;
        otherwise
            k = dsearchn(pos, src.Position);
            src.Position = pos(k,:);
            src.UserData.linind = k;
    end
    if ~isempty(kwargs.sz)
        src.UserData.subind = cell(numel(kwargs.sz), 1);
        [src.UserData.subind{:}] = ind2sub(kwargs.sz, src.UserData.linind);
    end
end