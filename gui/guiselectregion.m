function rois = guiselectregion(axroi, kwargs)
%% Interactive data selection.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m... double]                 - multidimensional data
%   shape:          [1×l1 char]                     - type of region selection
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; n-row verxex to polygon selection 
%   interaction:    [1×l2 char]                     - region selection behaviour
%   number:         [1×1 int8]                      - count of selection regions
%   moving:         [function_handle]               - callback at moving ROI
%   moved:          [function_handle]               - callback at had moving ROI
%% The function returns following results:
%   rois:           [object]                        - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'line', 'rect', 'poly', 'cube'})} = 'rect'
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.number (1,1) int8 = 1
        kwargs.moving function_handle = @(~, ~) []
        kwargs.moved function_handle = @(~, ~) []
    end

    colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], ...
        [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

    roimethod = {};
    switch kwargs.shape
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