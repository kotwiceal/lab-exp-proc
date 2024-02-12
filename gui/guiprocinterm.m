function guiprocinterm(data, kwargs)
%% Interactive intermittency processing.
%% The function takes following arguments:
%   data:           [n×m... double]     - multidimensional data
%   x:              [n×m double]        - spatial coordinate
%   z:              [n×m double]        - spatial coordinate
%   range:          [1×2 double]        - range to exculde statistical edges
%   norm:           [char]              - type of statistics normalization
%
%   fit:            [char]              - type of statistics fit
%   solver:         [char array]        - execute fit or optimization: 'fit', 'opt'
%   objnorm:        [1×l double]        - norm order at calculation objective function
%   Aineq:          [p×l double]        - linear optimization inequality constrain matrix
%   bineq:          [l×1 double]        - linear optimization inequality constrain right side
%   Aeq:            [m×k double]        - linear optimization equality constrain matrix
%   beq:            [k×1 double]        - linear optimization equality constrain right side
%   nonlcon:        [funtion_handle]    - non-linear optimization constrain function
%   x0:             [1×k doule]         - inital parameters
%   lb:             [1×k doule]         - lower bound of parameters
%   ub:             [1×k doule]         - upper bpund of parameters
%   show_param:     [logical]           - display optimization result 
%
%   shape:          [char]              - type of region selection
%   mask:           [double]            - edge size to rectangle selection; n-row verxex to polygon selection
%   interaction:    [char]              - region selection behaviour
%   legend:         [boolean]           - to show legend
%   clim:           [1×2 double]        - colorbar limit
%   xlim:           [1×2 double]        - x axis limit
%   ylim:           [1×2 double]        - y axis limit
%% Examples:
%% 1. Show statistics selected by gui, choose threshold and plot distribution along horizontal projection of drawn line, 2D fields is presented in node coordinates:
% guiprocinterm(data.dwdlf(:,:,:,1), fit = 'none')
%% 2. -//- 2D fields is presented in spatial coordinates:
% guiprocinterm(data.dwdlf(:,:,:,1), x = data.x(:,:,1), z = data.z(:,:,1), fit = 'none')
%% 3. -//- several measurement positions & approximation statisitc by two beta distributions:
% guiprocinterm(data.dwdlf(:,:,:,1:3), x = data.x(:,:,1:3), z = data.z(:,:,1:3), fit = 'beta2')
%% 4. -//- perform constrained optimization at histogram approximation:
% % constrain function
% nonlcon = @(x) nonlcon_beta2(x, rmean1 = [], rmode1 = [8e-4, 1.8e-3], rvar1 = [1e-7, 1e-6], ....
%         ramp1 = [], rmean2 = [], rmode2 = [3e-3, 4e-3], rvar2 = [1e-6, 1e-2]);
% % boundary constrains
% lb = [0, 1e-3, 0, 7.8, 6416, 1e-3, 1e-2, 0, 0, 0];
% ub = [2, 2e1, 1e-2, 7.8, 6416, 10, 2e1, 1e-2, 1e3, 1e4];
% % initial vector
% x0 = [1, 1, 1e-3, 5, 1e3, 1, 1, 3e-3, 10, 2e3];
%
% guiprocinterm(data.dwdlf(:,:,:,1:3), x = data.x(:,:,1:3), z = data.z(:,:,1:3), fit = 'beta2', ...
%   objnorm = 2, x0 = x0, lb = lb, ub = ub, nonlcon = nonlcon)

    arguments
        data double
        kwargs.x double = []
        kwargs.z double = []
        kwargs.range double = []
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'cdf', 'cumcount', 'probability', 'percentage', 'countdensity'})} = 'count'
        %% optimization parameters
        kwargs.fit (1,:) char {mustBeMember(kwargs.fit, {'none', 'gauss1', 'beta1', 'gamma1', 'gumbel1', 'gauss2', 'beta2', 'gamma2', 'gumbel2'})} = 'none'
        kwargs.solver (1,:) char {mustBeMember(kwargs.solver, {'fit', 'opt'})} = 'fit'
        kwargs.objnorm double = 2
        kwargs.Aineq double = []
        kwargs.bineq double = []
        kwargs.Aeq double = []
        kwargs.beq double = []
        kwargs.nonlcon = []
        kwargs.x0 double = []
        kwargs.lb double = []
        kwargs.ub double = []
        kwargs.show_param logical = true
        %% roi and axis parameters
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'rect', 'poly'})} = 'rect'
        kwargs.mask double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.legend logical = false
        kwargs.clim = [0, 0.3]
        kwargs.xlim double = []
        kwargs.ylim double = []
    end
    
    warning off

    % define variables
    iterm_fit = {}; % fit object of intermittency 2D distribution of different measurement position;
    roilines = cell(1, size(data, 4)); % to plot intermittency distribution along line;
    ax_iterm2d = cell(1, size(data, 4)); % to store axes for intermittency figures;
    roicrosshair = {}; % to select threshold by statistics;
    threshold = []; % threshold to binarize data;
    x_hist = []; % statistics edges;
    y_hist = []; % statistics counts;
    edges = []; % statistics edges of modes;
    rois = cell(1, size(data, 4)); % to select probe region of given data;
    selects = cell(1, size(data, 4)); % function handle to probe data;
    modes = []; % statistics modes;
    intermittency = []; % processed 2D intermittency distributions;
    crosshair_position = []; % to store user crosshair position;
    line_position = cell(1, size(data, 4)); % to store user line positions;

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.z)
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
                x = kwargs.x(:,:,i), z = kwargs.z(:,:,i));
            end
    end

    function proc_hist()
        %% accumulate data and process statistics
        temporary = [];
        for j = 1:length(rois)
            temporary = vertcat(temporary, selects{j}(rois{j}));
        end

        [x_hist, y_hist, ~, modes, edges, ~] = fithist(data = temporary, type = kwargs.fit, ...
            solver = kwargs.solver, objnorm = kwargs.objnorm, nonlcon = kwargs.nonlcon, x0 = kwargs.x0, ...
            lb = kwargs.lb, ub = kwargs.ub, show_param = kwargs.show_param);
    end

    function show_hist()
        %% show raw and fitted statistics
        cla(ax_hist);hold(ax_hist, 'on'); grid(ax_hist, 'on'); box(ax_hist, 'on'); 
        xlabel(ax_hist, 'edges'); ylabel(ax_hist, kwargs.norm)
        plot(ax_hist, x_hist, y_hist, 'DisplayName', 'full')
        plot(ax_hist, edges, modes(:, 1), 'DisplayName', 'mode 1')
        plot(ax_hist, edges, modes(:, 2), 'DisplayName', 'mode 2')
        plot(ax_hist, edges, sum(modes, 2), 'DisplayName', 'sum modes')

        if kwargs.legend; legend(ax_hist, 'Location', 'Best'); end
        if ~isempty(kwargs.xlim); xlim(ax_hist, kwargs.xlim); end
        if ~isempty(kwargs.ylim); ylim(ax_hist, kwargs.ylim); end
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
                    iterm_fit{j} = fit([zo, xo], io, 'linearinterp');
                end
            case 'spatial'
                for j = 1:size(data, 4)
                    [xo, zo, io] = prepareSurfaceData(kwargs.x(:,:,j), kwargs.z(:,:,j), intermittency(:,:,j)); 
                    iterm_fit{j} = fit([xo, zo], io, 'linearinterp');
                end
        end
    end

    function show_intermittency()
        %% show intermittency distributions
        switch disp_type
            case 'node'     
                for j = 1:length(ax_iterm2d)
                    cla(ax_iterm2d{j}); imagesc(ax_iterm2d{j}, intermittency(:,:,j)); clim(ax_iterm2d{j}, kwargs.clim);
                    axis(ax_iterm2d{1}, 'equal');
                    init_line(j);
                end
            case 'spatial'
                cla(ax_iterm2d{1}); hold(ax_iterm2d{1}, 'on'); box(ax_iterm2d{1}, 'on');
                grid(ax_iterm2d{1}, 'on'); axis(ax_iterm2d{1}, 'equal');
                for j = 1:size(data, 4)
                    contourf(ax_iterm2d{1}, kwargs.x(:,:,j), kwargs.z(:,:,j), intermittency(:,:,j), 50, 'LineStyle', 'None'); 
                    clim(ax_iterm2d{1}, kwargs.clim);
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
        try
            for j = 1:length(roilines)
                line_position{j} = roilines{j}.Position;
            end
        catch
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
                nexttile; imshow(data(:,:,1,i)); colormap turbo; axis on; clim(kwargs.clim)
                roitemp = guiselectregion(gca, @event_region, shape = kwargs.shape, ...
                    mask = kwargs.mask, interaction = kwargs.interaction, number = 1);
                rois{i} = roitemp{1};
            end
        case 'spatial'
            tiledlayout(2, 2);
            nexttile; hold on; box on; grid on; axis equal;
            for i = 1:size(data, 4)
                contourf(kwargs.x(:,:,i), kwargs.z(:,:,i), data(:,:,1,i), 50, 'LineStyle', 'None'); 

                roitemp = guiselectregion(gca, @event_region, shape = kwargs.shape, ...
                    mask = kwargs.mask, interaction = kwargs.interaction, number = 1);
                rois{i} = roitemp{1};
            end
            xlabel('x, mm'); ylabel('z, mm'); clim(kwargs.clim);
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