function rois = guihist(axroi, data, named)
%% Visualize data statistics by means manually region selection.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m... double]                 - multidimensional data
%   shape:          [char]                          - type of region selection
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; 
%                                                       n-row verxex to polygon selection 
%   fit:            [char]                          - type of statistics fit
%   range:          [1×2 double]                    - range to cut data
%   norm:           [char]                          - type of statistics normalization
%   interaction:    [char]                          - region selection behaviour
%   number:         [int]                           - count of selection regions
%% The function returns following results:
%   rois:     [object]   - ROI cell objects

    arguments
        axroi matlab.graphics.axis.Axes
        data double
        named.shape char = 'rect'
        named.mask double = []
        named.fit char = 'none'
        named.range double = []
        named.norm char = 'count'
        named.interaction char = 'all'
        named.number int8 = 1
        named.legend char = 'off'
    end

    select = @(roiobj) guigetdata(roiobj, data, shape = 'flatten');

    function event(~, ~)
        switch named.fit
            case 'none'
                cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
                xlabel(ax, 'edges'); ylabel(ax, named.norm);
                for i = 1:length(rois)
                    [counts, edges] = histcounts(select(rois{i}), 'Normalization', named.norm);
                    edges = edges(2:end);
                    plot(ax, edges, counts, 'Color', rois{i}.UserData.color, ...
                        'DisplayName', strcat("raw ", num2str(i)))
                end
                if (named.legend == 'on')
                    legend(ax, 'Location', 'NorthOutSide')
                end
            otherwise
                cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
                xlabel(ax, 'edges'); ylabel(ax, named.norm);
                for i = 1:length(rois)
                    [counts, edges] = histcounts(select(rois{i}), 'Normalization', named.norm);
                    edges = edges(2:end);

                    if ~isempty(named.range)
                        [edges, counts] = histcutrange(edges, counts, named.range);
                    end

                    [f, modes] = fithist(counts, edges, type = named.fit);

                    disp(f)

                    plot(ax, edges, counts, 'Color', rois{i}.UserData.color, ...
                        'DisplayName', strcat("raw ", num2str(i)))
                        for j = 1:size(modes, 2)
                            if named.number == 1
                                plot(ax, edges, modes(:, j), ...
                                    'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                            else
                                plot(ax, edges, modes(:, j), '-o', 'Color', rois{i}.UserData.color, ...
                                    'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                            end
                        end
                            if named.number == 1
                               plot(ax, edges, sum(modes, 2), ...
                                   'DisplayName', strcat("sum mode", num2str(i)))
                            else
                                plot(ax, edges, sum(modes, 2), '.-', 'Color', rois{i}.UserData.color, ...
                                    'DisplayName', strcat("sum mode", num2str(i)))
                            end
                end
                if (named.legend == 'on')
                    legend(ax, 'Location', 'NorthOutSide')
                end
        end
    end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = named.shape, ...
        mask = named.mask, interaction = named.interaction, number = named.number);

end