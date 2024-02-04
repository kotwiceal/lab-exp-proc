function rois = guiselectregion(axroi, event, kwargs)
%% Interactive data selection.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m... double]                 - multidimensional data
%   shape:          [char]                          - type of region selection
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; 
%                                                       n-row verxex to polygon selection 
%   interaction:    [char]                          - region selection behaviour
%   number:         [int]                           - count of selection regions
%% The function returns following results:
%   rois:           [object]                        - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        event function_handle
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'line', 'rect', 'poly'})} = 'rect'
        kwargs.mask double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.number int8 = 1
    end

    colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], ...
        [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

    roimethod = {}; position = [];
    switch kwargs.shape
        case 'line'
            roimethod = @drawline;
            position = kwargs.mask;
        case 'rect'
            roimethod = @drawrectangle;
            if numel(kwargs.mask) == 2
                position = [1, 1, kwargs.mask];
            else
                position = kwargs.mask;
            end
        case 'poly'
            roimethod = @drawpolygon;
            position = kwargs.mask;
    end

    roimethods = cell(1, kwargs.number);
    rois = cell(1, kwargs.number);

    for i = 1:kwargs.number
        j = rem(i, numel(colors));
        if j == 0; j = 1; end
        if isempty(kwargs.mask)
            roimethods{i} = @(ax) roimethod(ax, 'Color', colors{j}, 'InteractionsAllowed', kwargs.interaction);
        else
            roimethods{i} = @(ax) roimethod(ax, 'Color', colors{j}, 'InteractionsAllowed', kwargs.interaction, 'Position', position);
        end
        rois{i} = roimethods{i}(axroi);
        rois{i}.UserData = struct('color', colors{j});
        addlistener(rois{i}, 'ROIMoved', event);
    end
    
end