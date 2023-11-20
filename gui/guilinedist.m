function rois = guilinedist(axroi, data, named)
%% Visualize data distribution along specified lines.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m... double]                 - multidimensional data
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; 
%                                                       n-row verxex to polygon selection 
%   interaction:    [char]                          - region selection behaviour
%   number:         [int]                           - count of selection regions
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.mask double = []
        named.interaction char = 'all'
        named.number int8 = 1
    end

    temp = data;
    [I, J] = ndgrid(1:size(temp, 1), 1:size(temp, 2));
    index = isnan(temp);
    temp = temp(~index);
    I = I(~index);
    J = J(~index);
    data_fit = fit([J, I], temp, 'linearinterp');

    function event(~, ~)
    
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
        xlabel(ax, 'horizon'); xlabel(ax, 'value');
        for i = 1:length(rois)
            I = linspace(rois{i}.Position(1,1), rois{i}.Position(2,1));
            J = linspace(rois{i}.Position(1,2), rois{i}.Position(2,2));
            plot(ax, I, data_fit(I, J), 'Color', rois{i}.UserData.color)
        end
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'line', ...
        mask = named.mask, interaction = named.interaction, number = named.number);

end