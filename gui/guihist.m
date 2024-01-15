function rois = guihist(axroi, data, named)
%% Visualize data statistics by means manually region selection.
%% The function takes following arguments:
%   axroi:          [matlab.graphics.axis.Axes]     - axis object of canvas that selection data events are being occured
%   data:           [n×m... double]                 - multidimensional data
%   x:              [n×m double]                    - spatial coordinate
%   z:              [n×m double]                    - spatial coordinate
%   range:          [1×2 double]                    - range to exclude data
%   norm:           [char array]                    - type of statistics normalization

%   shape:          [char array]                    - type of region selection
%   mask:           [double]                        - edge size to rectangle selection or n-row verxex to polygon selection 
%   interaction:    [char array]                    - region selection behaviour: 'translate', 'all'   
%   number:         [int]                           - count of selection regions
%   legend:         [logical]                       - show legend
%   xlim:           [1×2 double]                    - x axis limit
%   ylim:           [1×2 double]                    - y axis limit
%   markersize:     [double]                        - masker size
%   show_cdf:       [logical]                       - plot cdf of statistics

%   fit:            [char array]                    - type of statistics fit: 'none', 'beta1', 'beta2', 'gauss1', 'gauss1s', 'gauss2',
%       'gauss2s1', 'gauss2s2', 'gamma1', 'gamm2'
%   solver:         [char array]                    - execute fit or optimization: 'fit', 'opt'
%   objnorm:        [double]                        - norm order at calculation objective function
%   Aineq:          [p×l double]                    - linear optimization inequality constrain matrix
%   bineq:          [l×1 double]                    - linear optimization inequality constrain right side
%   Aeq:            [m×k double]                    - linear optimization equality constrain matrix
%   beq:            [k×1 double]                    - linear optimization equality constrain right side
%   nonlcon:        [funtion_handle]                - non-linear optimization constrain function
%   x0:             [1×k doule]                     - inital approximation
%   lb:             [1×k doule]                     - lower bound of parameters
%   ub:             [1×k doule]                     - upper bpund of parameters
%   show_param:     [logical]                       - display of optimization result 
%% The function returns following results:
%   rois:           [object]                        - ROI cell objects
%% Examples:
%% show histogram by specific realization with default parameters
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% guihist(gca, data.dwdlf(:,:,1));
%
%% show histogram by all realization with default parameters (ndim(data.dwdlf) = 3)
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% guihist(gca, data.dwdlf);
%
%% show histograms by all realization by two selection regions
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% guihist(gca, data.dwdlf, number = 2);
%% get raw data selected by gui
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% rois = guihist(gca, data.dwdlf);
% probe = guigetdata(rois{1}, data.dwdlf, shape = 'flatten');
%% get raw data selected by two regions
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% rois = guihist(gca, data.dwdlf, number = 2);
% probe{1} = guigetdata(rois{1}, data.dwdlf, shape = 'flatten');
% probe{2} = guigetdata(rois{2}, data.dwdlf, shape = 'flatten');
%% show histogram by all realization with custom parameters, pdf is fitted by 'beta1' distribution, by solver fmincon with l2 norm and lower and upper constrains
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% guihist(gca, data.dwdlf, mask = [25, 220, 25, 25], ...
%     fit = 'beta1', solver = 'opt', objnorm = 2, lb = [1, 0, 0, 1, 1], ...
%     ub = [1, 1e2, 0, 2e1, 1e4], norm = 'pdf', xlim = [0, 0.01], show_param = true, show_cdf = true);
%% show histogram by all realization with custom parameters, pdf is fitted by 'beta2' distribution, by solver fmincon with l2 norm and lower, upper and non-linear constrains
% % description of 'beta2':
% % f1 = @(a, x) a(1)*betapdf(a(2)*x-a(3), a(4), a(5)); f1 = @(a, x) f1(a(1:5), x);
% % f2 = @(a, x) a(1)*betapdf(a(2)*x-a(3), a(4), a(5)); f2 = @(a, x) f2(a(6:end), x);
% % fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
%
% % constrain function
% nonlcon = @(x) nonlcon_beta2(x, rmean1 = [], rmode1 = [8e-4, 1.8e-3], rvar1 = [1e-7, 1e-6], ....
%         ramp1 = [], rmean2 = [], rmode2 = [3e-3, 4e-3], rvar2 = [1e-6, 1e-2]);
% % boundary constrains
% lb = [0, 1e-3, 0, 7.8, 6416, 1e-3, 1e-2, 0, 0, 0];
% ub = [2, 2e1, 1e-2, 7.8, 6416, 10, 2e1, 1e-2, 1e3, 1e4];
% % gui
% clf; tiledlayout(2, 2);
% nexttile; imagesc(mean(data.dwdlf(:,:,1), 3)); axis equal; clim([0, 0.03])
% guihist(gca, data.dwdlf, mask = [250, 50, 25, 25], ...
%     fit = 'beta2', solver = 'opt', objnorm = 2, lb = lb, ub = ub, nonlcon = nonlcon, ...
%     norm = 'pdf', xlim = [0, 0.01], show_param = true, show_cdf = true);

    arguments
        axroi matlab.graphics.axis.Axes
        %% data parameters
        data double
        named.x double = []
        named.z double = []
        named.range double = []
        named.norm char = 'count'
        %% roi and axis parameters
        named.shape char = 'rect'
        named.mask double = []
        named.interaction char = 'all'
        named.number int8 = 1
        named.legend logical = false
        named.xlim double = []
        named.ylim double = []
        named.markersize double = 3
        named.show_cdf logical = false
        %% optimization parameters
        named.fit char = 'none'
        named.solver char = 'fit'
        named.objnorm double = 2
        named.Aineq double = []
        named.bineq double = []
        named.Aeq double = []
        named.beq double = []
        named.nonlcon = []
        named.x0 double = []
        named.lb double = []
        named.ub double = []
        named.show_param logical = false
        %% deprecated parameters
        named.init char = 'gauss1'
        named.regul double = []
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

    function plot_raw_hist()
        %% show statistic of raw data
        cla(ax{1}); hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on');
        xlabel(ax{1}, 'edges'); ylabel(ax{1}, named.norm);
        for i = 1:length(rois)
            [counts, edges] = histcounts(select(rois{i}), 'Normalization', named.norm);
            edges = edges(2:end);
            
            if ~isempty(named.range)
                [edges, counts] = histcutrange(edges, counts, named.range);
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

        if named.show_cdf
            cla(ax{2}); hold(ax{2}, 'on'); box(ax{2}, 'on'); grid(ax{2}, 'on');
            xlabel(ax{2}, 'edges'); ylabel(ax{2}, 'cdf');
            ylim(ax{2}, [-0.1, 1.1])
        end

        for i = 1:length(rois)       
            [edges, counts, f, modes, edges_fit, ~] = fithist(data = select(rois{i}), type = named.fit, ...
                solver = named.solver, ...
                objnorm = named.objnorm, ...
                nonlcon = named.nonlcon, ...
                lb = named.lb, ...
                x0 = named.x0, ...
                ub = named.ub, ...
                init = named.init, ...
                range = named.range, ...
                regul = named.regul, ...
                show_param = named.show_param);

            disp(f)

            plot(ax{1}, edges, counts, 'Color', rois{i}.UserData.color, ...
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

            if named.show_cdf
                cdf = cumsum(modes, 1); cdf = cdf ./ max(cdf, [], 1);
                if size(cdf, 2) == 2
                    cdf(:, 2) = 1 - cdf(:, 2);
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
        switch named.fit
            case 'none'
                plot_raw_hist();
            otherwise
                plot_fit_hist();
        end
        customize_appearance();
    end

    nexttile; ax{1} = gca;
    if named.show_cdf
        nexttile; ax{2} = gca;
    end
    rois = guiselectregion(axroi, @event, shape = named.shape, ...
        mask = named.mask, interaction = named.interaction, number = named.number);

    event();

end