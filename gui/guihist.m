function varargout = guihist(data, named)
%% Visualize data statistics by means manually region selection.
%% The function takes following arguments:
%   data:           [n×m... double]                 - multidimensional data
%   x:              [n×m double]                    - spatial coordinate
%   z:              [n×m double]                    - spatial coordinate
%   range:          [1×2 double]                    - range to exclude data
%   norm:           [char array]                    - type of statistics normalization
%   binedge:        [1×q double]                    - bins count or edge grid
%   normalize:      [char array]                    - data normalization
%   getdata:        [char array]                    - data extraction method

%   shape:          [char array]                    - type of region selection
%   mask:           [1×2 or 1×4 t×2 double]         - edge size to rectangle selection or n-row verxex to polygon selection 
%   interaction:    [char array]                    - region selection behaviour: 'translate', 'all'   
%   number:         [1×1 int]                       - count of selection regions
%   legend:         [1×1 logical]                   - show legend
%   xlim:           [1×2 double]                    - x axis limit
%   ylim:           [1×2 double]                    - y axis limit
%   clim:           [1×2 double]                    - color axis limit
%   colormap:       [char array]                    - colormap of 2D field
%   markersize:     [double]                        - masker size
%   cdf:            [1×1 logical]                   - plot cdf of statistics
%   docked:         [1×1 logical]                   - docked figure
%   aspect:         [char array]                    - axis ratio

%   distname:       [char array]                    - type of statistics fit
%   objnorm:        [1×1 double]                    - norm order at calculation objective function
%   Aineq:          [p×l double]                    - linear optimization inequality constrain matrix
%   bineq:          [l×1 double]                    - linear optimization inequality constrain right side
%   Aeq:            [m×k double]                    - linear optimization equality constrain matrix
%   beq:            [k×1 double]                    - linear optimization equality constrain right side
%   nonlcon:        [funtion_handle]                - non-linear optimization constrain function
%   x0:             [1×k doule]                     - inital approximation
%   lb:             [1×k doule]                     - lower bound of parameters
%   ub:             [1×k doule]                     - upper bpund of parameters
%   mb:             [1×2 doule]                     - scale range of auto constrains
%   disp:           [1×1 logical]                   - display of optimization result 

%   quantile:       [1×1 double]                    - quantile threshold

%% The function returns following results:
%   getdata:        [function_handle]               - return cells stored raw or distribution
%% Examples:
%% show histogram by specific realization with default parameters
% guihist(data.dwdlf(:,:,1));
%% show histogram by all realization with default parameters (ndim(data.dwdlf) = 3)
% guihist(data.dwdlf);
%% show histograms by all realization by two selection regions
% guihist(gca, data.dwdlf, number = 2);
%% get raw data selected by gui
% gd = guihist(data.dwdlf);
% probe = gd();
%% get raw data selected by two regions
% gd = guihist(gca, data.dwdlf, number = 2);
% probes = gd();
% probe{1} = probes{1};
% probe{2} = probes{2};
%% show histogram by all realization with custom parameters, pdf is fitted by 'beta1' distribution, by solver fmincon with l2 norm and lower and upper constrains
% guihist(data.dwdlf, mask = [25, 220, 25, 25], ...
%     distname = 'beta1', objnorm = 2, lb = [1, 0, 0, 1, 1], ...
%     ub = [1, 1e2, 0, 2e1, 1e4], norm = 'pdf', xlim = [0, 0.01], disp = true, cdf = true);
%% show histogram by all realization with custom parameters, pdf is fitted by 'beta2' distribution, by solver fmincon with l2 norm and lower, upper and non-linear constrains
% % description of 'beta2':
% % f1 = @(a, x) a(1)*betapdf(x, a(2), a(3)); f1 = @(a, x) f1(a(1:3), x);
% % f2 = @(a, x) a(1)*betapdf(x, a(2), a(3)); f2 = @(a, x) f2(a(4:end), x);
% % fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
%
% % constrain function
% nonlcon = @(x) nonlcon_statmode(x,distname='beta2',rmode1=[1e-4,6e-4],rvar1=[1e-8,1e-7],rmode2=[7e-4,5e-3],rvar2=[1e-7,1e-5]);
% % boundary constrains
% lb = [0, 1e-3, 0, 7.8, 6416, 1e-3, 1e-2, 0, 0, 0];
% ub = [2, 2e1, 1e-2, 7.8, 6416, 10, 2e1, 1e-2, 1e3, 1e4];
% % gui
% guihist(data.dwdlf, mask = [250, 50, 25, 25], ...
%     distname = 'beta2', objnorm = 2, lb = lb, ub = ub, nonlcon = nonlcon, ...
%     norm = 'pdf', xlim = [0, 0.01], disp = true, cdf = true);

    arguments
        %% data parameters
        data double
        named.x double = []
        named.z double = []
        named.range double = []
        named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'cdf', 'cumcount', 'probability', 'percentage', 'countdensity'})} = 'count'
        named.binedge double = []
        named.normalize (1,:) char {mustBeMember(named.normalize, {'none', 'zscore', 'norm', 'center'})} = 'none'
        named.getdata (1,:) char {mustBeMember(named.getdata, {'raw', 'dist'})} = 'raw'
        %% roi and axis parameters
        named.shape (1,:) char {mustBeMember(named.shape, {'rect', 'poly'})} = 'rect'
        named.mask double = []
        named.interaction (1,:) char {mustBeMember(named.interaction, {'all', 'none', 'translate'})} = 'all'
        named.number int8 = 1
        named.legend logical = false
        named.xlim double = []
        named.ylim double = []
        named.clim double = []
        named.colormap (1,:) char = 'turbo'
        named.markersize double = 3
        named.cdf logical = false
        named.docked logical = false
        named.aspect (1,:) char {mustBeMember(named.aspect, {'equal', 'auto'})} = 'equal'
        %% optimization parameters
        named.distname (1,:) char {mustBeMember(named.distname, {'none', 'chi21', 'beta1', 'beta1l', 'beta2', 'beta2l', 'gamma1', 'gamma2', 'gumbel1', 'gumbel2'})} = 'none'
        named.objnorm double = 2
        named.Aineq double = []
        named.bineq double = []
        named.Aeq double = []
        named.beq double = []
        named.nonlcon = []
        named.x0 double = []
        named.lb double = []
        named.ub double = []
        named.mb double = [0, 10]
        named.disp logical = false
        %% other parameters
        named.quantile double = 0.1
    end

    % define variables
    mode_markers = {'-o', '-s', '-x', '-<', '->', '-^'};

    % define dispalying type
    if isempty(named.x) && isempty(named.z)
        disp_type = 'node';
    else
        disp_type = 'spatial';
    end

    % define funtion handle to probe data
    switch disp_type
        case 'node'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'flatten');
        case 'spatial'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'flatten', ...
                type = 'spatial', x = named.x, z = named.z);
    end

    function result = roisgetdata()
        %% extract data from selectors
        result = cell(1, numel(rois));
        switch named.getdata
            case 'raw'
                for i = 1:length(rois)       
                    result{i} = select(rois{i});
                end
            case 'dist'
                for i = 1:length(rois)       
                    [~, ~, ~, ~, edges_raw, counts_raw] = fithist(data = select(rois{i}), ...
                        distname = 'none', range = named.range, normalize = named.normalize);
                    result{i} = [edges_raw, counts_raw];
                end
        end
    end

    function plot_raw_hist()
        %% show statistic of raw data
        cla(ax{1}); hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on');
        xlabel(ax{1}, 'edges'); ylabel(ax{1}, named.norm);
        for i = 1:length(rois)
            if isempty(named.binedge)
                [counts, edges] = histcounts(select(rois{i}), 'Normalization', named.norm);
            else
                [counts, edges] = histcounts(select(rois{i}), named.binedge, 'Normalization', named.norm);
            end

            edges = edges(2:end);

            if ~isempty(named.range)
                index = excludedata(edges, counts, 'range', named.range);
                edges = edges(index); counts = counts(index); clear index;
            end

            switch named.norm
                case 'cdf'
                    plot(ax{1}, edges, 1-counts, 'Color', rois{i}.UserData.color, ...
                        'DisplayName', strcat("raw ", num2str(i)))
                otherwise
                    plot(ax{1}, edges, counts, 'Color', rois{i}.UserData.color, ...
                        'DisplayName', strcat("raw ", num2str(i)))
            end

        end
    end

    function plot_fit_hist()
        %% show statistic of fitted data
        cla(ax{1}); hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on');
        xlabel(ax{1}, 'edges'); ylabel(ax{1}, named.norm);

        if named.cdf
            cla(ax{2}); hold(ax{2}, 'on'); box(ax{2}, 'on'); grid(ax{2}, 'on');
            xlabel(ax{2}, 'edges'); ylabel(ax{2}, 'cdf');
            ylim(ax{2}, [-0.1, 1.1])
        end

        for i = 1:length(rois)       
            [~, modes, edges_fit, ~, edges_raw, counts_raw] = fithist(data = select(rois{i}), ...
                distname = named.distname, ...
                objnorm = named.objnorm, ...
                nonlcon = named.nonlcon, ...
                lb = named.lb, ...
                x0 = named.x0, ...
                ub = named.ub, ...
                mb = named.mb, ...
                range = named.range, ...
                normalize = named.normalize, ...
                disp = named.disp);

            plot(ax{1}, edges_raw, counts_raw, 'Color', rois{i}.UserData.color, ...
                    'DisplayName', strcat("raw ", num2str(i)))
            for j = 1:size(modes, 2)
                if named.number == 1
                    plot(ax{1}, edges_fit, modes(:, j), ...
                        'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                else
                    plot(ax{1}, edges_fit, modes(:, j), mode_markers{j}, 'Color', rois{i}.UserData.color, ...
                        'MarkerSize', named.markersize, ...
                        'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                end
            end

            if named.number == 1
                plot(ax{1}, edges_fit, sum(modes, 2), ...
                    'DisplayName', strcat("sum mode", num2str(i)))
            else
                plot(ax{1}, edges_fit, sum(modes, 2), '.-', 'Color', rois{i}.UserData.color, ...
                    'DisplayName', strcat("sum mode", num2str(i)))
            end

            if named.cdf
                cdf = cumsum(modes, 1); cdf = cdf ./ max(cdf, [], 1);
                if size(cdf, 2) == 2
                    cdf(:, 2) = 1 - cdf(:, 2);

                    if named.disp
                        [~, indcdfint] = min(abs(diff(cdf, 1, 2)));
                        [~, indqntl] = min(abs(cdf(:, 1)-named.quantile));
                        tab = [edges_fit(indcdfint); edges_fit(indqntl)];
                        tab = array2table(tab, 'VariableNames', {'value'}, 'RowName', {'cdf intersection', char(strcat("quantile ", num2str(named.quantile)))});
                        disp(tab);
                    end
                end
                for j = 1:size(cdf, 2)
                    if named.number == 1
                        plot(ax{2}, edges_fit, cdf(:, j), ...
                            'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                    else
                        plot(ax{2}, edges_fit, cdf(:, j), mode_markers{j}, 'Color', rois{i}.UserData.color, ...
                            'MarkerSize', named.markersize, ...
                            'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                    end
                end
            end
        end
    end

    function customize_appearance()
        %% change figure appearance
        if ~isempty(named.xlim)
            for i = 1:length(ax)
                xlim(ax{i}, named.xlim)
            end
        end

        if ~isempty(named.ylim)
            for i = 1:length(ax)
                ylim(ax{i}, named.ylim)
            end
        end

        if named.legend
            for i = 1:length(ax)
                legend(ax{i}, 'Location', 'Best')
            end
        end
    end

    function event(~, ~)
        %% callback at moved event
        switch named.distname
            case 'none'
                plot_raw_hist();
            otherwise
                plot_fit_hist();
        end
        customize_appearance();
    end

    if named.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout(2, 2);
    nexttile; axroi = gca; 
    switch disp_type
        case 'node'
            imagesc(axroi, data(:,:,1)); xlabel('x_{n}'); ylabel('z_{n}');
        case 'spatial'
            contourf(axroi, named.x, named.z, data(:,:,1), 100, 'LineStyle', 'None'); 
            xlabel('x, mm'); ylabel('z, mm');
    end
    colorbar(axroi); colormap(axroi, named.colormap);
    if ~isempty(named.clim)
        clim(axroi, named.clim);
    end
    axis(axroi, named.aspect)

    nexttile; ax{1} = gca;
    if named.cdf
        nexttile; ax{2} = gca;
    end
    rois = guiselectregion(axroi, @event, shape = named.shape, ...
        mask = named.mask, interaction = named.interaction, number = named.number);

    event();

    varargout{1} = @() roisgetdata();

end