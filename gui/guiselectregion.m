function rois = guiselectregion(axroi, kwargs)
%% Interactive data selection.
%% The function returns following results:
%   rois:           [object]                        - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes % axis object of canvas that selection data events are being occured
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'point', 'line', 'rect', 'poly', 'cube'})} = 'rect' % type of region selection
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = [] % two row vertex to line selection; edge size to rectangle selection; n-row verxex to polygon selection 
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.number (1,1) double {mustBeInteger} = 1 % count of selection regions
        kwargs.moving function_handle = @(~, ~) [] % callback at moving ROI
        kwargs.moved function_handle = @(~, ~) [] % callback at had moving ROI
    end

    colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], ...
        [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

    roimethod = {};
    switch kwargs.shape
        case 'point'
            roimethod = @drawpoint;
        case 'line'
            roimethod = @drawline;
        case 'rect'
            roimethod = @drawrectangle;
        case 'poly'
            roimethod = @drawpolygon;
        case 'cube'
            roimethod = @drawcuboid;
    end

    roimethods = cell(1, kwargs.number);
    rois = cell(1, kwargs.number);

    for i = 1:kwargs.number
        j = rem(i, numel(colors));
        if j == 0; j = 1; end
        
        if isa(kwargs.mask, 'double')
            if isempty(kwargs.mask)
                roimethods{i} = @(ax) roimethod(ax, 'Color', colors{j}, 'InteractionsAllowed', kwargs.interaction);
            else
                roimethods{i} = @(ax) roimethod(ax, 'Color', colors{j}, 'InteractionsAllowed', kwargs.interaction, 'Position', kwargs.mask);
            end
        else
            if isempty(kwargs.mask{i})
                roimethods{i} = @(ax) roimethod(ax, 'Color', colors{j}, 'InteractionsAllowed', kwargs.interaction);
            else
                roimethods{i} = @(ax) roimethod(ax, 'Color', colors{j}, 'InteractionsAllowed', kwargs.interaction, 'Position', kwargs.mask{i});
            end
        end

        rois{i} = roimethods{i}(axroi);
        rois{i}.UserData = struct('color', colors{j});

        addlistener(rois{i}, 'MovingROI', kwargs.moving);
        addlistener(rois{i}, 'ROIMoved', kwargs.moved);
    end
    
end