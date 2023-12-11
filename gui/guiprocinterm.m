function guiprocinterm(data, named)
%% Interactive intermittency processing.
%% The function takes following arguments:
%   data:           [n×m... double]                 - multidimensional data
%   shape:          [char]                          - type of region selection
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; 
%                                                       n-row verxex to polygon selection 
%   fit:            [char]                          - type of statistics fit
%   range:          [1×2 double]                    - range to cut data
%   norm:           [char]                          - type of statistics normalization
%   interaction:    [char]                          - region selection behaviour
%   number:         [int]                           - count of selection regions
%   legend:         [boolean]                       - to show legend
%   x:              [n×m double]                    - spatial coordinate
%   z:              [n×m double]                    - spatial coordinate
%   clim:           [1×2 double]                    - colorbar limit

    arguments
        data double
        named.shape char = 'poly'
        named.mask double = []
        named.norm char = 'pdf'
        named.fit char = 'gauss2s'
        named.interaction char = 'all'
        named.range double = []
        named.number double = 1
        named.legend logical = false
        named.x double = []
        named.z double = []
        named.clim = [0, 0.3]
    end
    
    warning off

    % define variables
    iterm_fit = {}; % fit object of intermittency 2D distribution of different measurement position;
    roilines = cell(1, size(data, 4)); % to plot intermittency distribution along line;
    ax_iterm2d = cell(1, size(data, 4)); % to store axes for intermittency figures;
    roicrosshair = {}; % to select threshold by statistics;
    threshold = []; % threshold to binarize data;
    edges = []; % statistics edges;
    counts = []; % statistics counts;
    rois = cell(1, size(data, 4)); % to select probe region of given data;
    selects = cell(1, size(data, 4)); % function handle to probe data;
    modes = []; % statistics modes;
    intermittency = []; % processed 2D intermittency distributions;
    crosshair_position = []; % to store user crosshair position;
    line_position = cell(1, size(data, 4)); % to store user line positions;

    % define dispalying type
    if isempty(named.x) && isempty(named.z)
        disp_type = 'node';
    else
        disp_type = 'spatial';
    end

    % define funtion handle to probe data
    switch disp_type
        case 'node'
            for i = 1:length(selects)
                selects{i} = @(roiobj) guigetdata(roiobj, data(:,:,:,i), shape = 'flatten');
            end
        case 'spatial'
            for i = 1:length(selects)
            selects{i} = @(roiobj) guigetdata(roiobj, data(:,:,:,i), shape = 'flatten', ...
                type = 'spatial', x = named.x(:,:,i), z = named.z(:,:,i));
            end
    end

    function proc_hist()
        %% accumulate data and process statistics
        temporary = [];
        for j = 1:length(rois)
            temporary = vertcat(temporary, selects{j}(rois{j}));
        end
        [counts, edges] = histcounts(temporary, 'Normalization', named.norm);
        edges = edges(2:end);

        if ~isempty(named.range)
            [edges, counts] = histcutrange(edges, counts, named.range);
        end
        try
            [~, modes] = fithist(counts, edges, type = named.fit);
        catch
            modes = zeros(length(counts), 2);
        end
    end

    function show_hist()
        %% show raw and fitted statistics
        cla(ax_hist);hold(ax_hist, 'on'); grid(ax_hist, 'on'); box(ax_hist, 'on'); 
        xlabel(ax_hist, 'edges'); ylabel(ax_hist, named.norm)
        plot(ax_hist, edges, counts, 'DisplayName', 'full')
        plot(ax_hist, edges, modes(:, 1), 'DisplayName', 'mode 1')
        plot(ax_hist, edges, modes(:, 2), 'DisplayName', 'mode 2')
        plot(ax_hist, edges, sum(modes, 2), 'DisplayName', 'sum modes')
        if (named.legend)
            legend(ax_hist, 'Location', 'Best');     
        end
    end

    function init_crosshair()
        % initialize crosshair
        if isempty(crosshair_position)
            roicrosshair = drawcrosshair(ax_hist);
        else
            roicrosshair = drawcrosshair(ax_hist, Position = crosshair_position);
        end
        addlistener(roicrosshair, 'ROIMoved', @event_crosshair);
        event_crosshair();
    end

    function init_line(j)
        %% initialize specified line selector
        switch disp_type
            case 'node'
                k = j;
            case 'spatial'
                k = 1;
        end
        if isempty(line_position{j})
            roitemp = guiselectregion(ax_iterm2d{k}, @event_line, shape = 'line');
        else
            roitemp = guiselectregion(ax_iterm2d{k}, @event_line, shape = 'line', mask = line_position{j});
        end
        roilines{j} = roitemp{1};
        line_position{j} = roilines{j}.Position;
        event_line();
    end

    function fit_intermittency()
        %% fit 2D intermittency distributions
        switch disp_type
            case 'node'  
                for j = 1:size(data, 4)
                    [xi, zi] = ndgrid(1:size(intermittency, 1), 1:size(intermittency, 2));
                    [xo, zo, io] = prepareSurfaceData(xi, zi, intermittency(:,:,j));
                    iterm_fit{j} = fit([xo, zo], io, 'linearinterp');
                end
            case 'spatial'
                for j = 1:size(data, 4)
                    [xo, zo, io] = prepareSurfaceData(named.x(:,:,j), named.z(:,:,j), intermittency(:,:,j)); 
                    iterm_fit{j} = fit([xo, zo], io, 'linearinterp');
                end
        end
    end

    function show_intermittency()
        %% show intermittency distributions
        switch disp_type
            case 'node'     
                for j = 1:length(ax_iterm2d)
                    cla(ax_iterm2d{j}); imagesc(ax_iterm2d{j}, intermittency(:,:,j)); clim(ax_iterm2d{j}, named.clim);
                    init_line(j);
                end
            case 'spatial'
                cla(ax_iterm2d{1}); hold(ax_iterm2d{1}, 'on'); box(ax_iterm2d{1}, 'on');
                grid(ax_iterm2d{1}, 'on'); axis(ax_iterm2d{1}, 'equal');
                for j = 1:size(data, 4)
                    contourf(ax_iterm2d{1}, named.x(:,:,j), named.z(:,:,j), intermittency(:,:,j), 50, 'LineStyle', 'None'); 
                    clim(ax_iterm2d{1}, named.clim);
                    init_line(j);
                end
                xlabel(ax_iterm2d{1}, 'x, mm'); ylabel(ax_iterm2d{1}, 'z, mm');
        end
    end

    function event_region(~, ~)
        %% callback at changing user region-probe
        try
            proc_hist();
            show_hist();
            init_crosshair();
        catch
        end
    end

    function event_line(~, ~)
        %% callback at changing user line-probe
        for j = 1:length(roilines)
            line_position{j} = roilines{j}.Position;
        end
        
        try
            cla(ax_iten1d); hold(ax_iten1d, 'on'); grid(ax_iten1d, 'on'); box(ax_iten1d, 'on'); 
            ylabel(ax_iten1d, 'intermittency');
            for j = 1:length(roilines)
                if ~isempty(line_position{j})
                    pos = line_position{j};
                    xi = linspace(pos(1,1), pos(2,1));
                    zi = linspace(pos(1,2), pos(2,2));
                    plot(ax_iten1d, xi, iterm_fit{j}(xi, zi))
                end
            end
            switch disp_type
                case 'node'
                    xlabel(ax_iten1d, 'horizon');
                case 'spatial'
                    xlabel(ax_iten1d, 'x, mm'); 
            end
        catch
        end
    end

    function event_crosshair(~, ~)
        %% callback at changing user threshold-probe
        try
            crosshair_position = roicrosshair.Position;
            threshold = crosshair_position(1);               
            intermittency = squeeze(mean(binarize(data, threshold), 3));
            fit_intermittency();
            show_intermittency();
        catch
        end
    end

    %% create figure and subplots
    figure('WindowStyle', 'docked');

    switch disp_type
        case 'node'
            tiledlayout(floor((size(data, 4)*2+2)/3) + 1, 3);
            for i = 1:length(rois)
                nexttile; imshow(data(:,:,1,i)); colormap turbo; axis on; clim(named.clim)
                roitemp = guiselectregion(gca, @event_region, shape = named.shape, ...
                    mask = named.mask, interaction = named.interaction, number = 1);
                rois{i} = roitemp{1};
            end
        case 'spatial'
            tiledlayout(2, 2);
            nexttile; hold on; box on; grid on; axis equal;
            for i = 1:size(data, 4)
                contourf(named.x(:,:,i), named.z(:,:,i), data(:,:,1,i), 50, 'LineStyle', 'None'); 

                roitemp = guiselectregion(gca, @event_region, shape = named.shape, ...
                    mask = named.mask, interaction = named.interaction, number = 1);
                rois{i} = roitemp{1};
            end
            xlabel('x, mm'); ylabel('z, mm'); clim(named.clim);
    end

    nexttile; ax_hist = gca;

    switch disp_type
        case 'node'
            for i = 1:length(rois)
                nexttile; ax_iterm2d{i} = gca;
            end
        case 'spatial'
            nexttile; ax_iterm2d{1} = gca;
    end

    nexttile; ax_iten1d = gca;

    event_region();
end