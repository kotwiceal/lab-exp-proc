function rois = guiselectregion(axroi, event, named)
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
        named.shape (1,:) char {mustBeMember(named.shape, {'line', 'rect', 'poly'})} = 'rect'
        named.mask double = []
        named.interaction (1,:) char {mustBeMember(named.interaction, {'all', 'none', 'translate'})} = 'all'
        named.number int8 = 1
    end

    colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], ...
        [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

    roimethod = {}; position = [];
    switch named.shape
        case 'line'
            roimethod = @drawline;
            position = named.mask;
        case 'rect'
            roimethod = @drawrectangle;
            if numel(named.mask) == 2
                position = [1, 1, named.mask];
            else
                position = named.mask;
            end
        case 'poly'
            roimethod = @drawpolygon;
            position = named.mask;
    end

    roimethods = cell(1, named.number);
    rois = cell(1, named.number);

    for i = 1:named.number
        if isempty(named.mask)
            roimethods{i} = @(ax) roimethod(ax, 'Color', colors{i}, 'InteractionsAllowed', named.interaction);
        else
            roimethods{i} = @(ax) roimethod(ax, 'Color', colors{i}, 'InteractionsAllowed', named.interaction, 'Position', position);
        end
        rois{i} = roimethods{i}(axroi);
        rois{i}.UserData = struct('color', colors{i});
        addlistener(rois{i}, 'ROIMoved', event);
    end
    
end