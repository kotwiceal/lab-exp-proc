function varargout = guihist(data, kwargs)
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
%   markersize:     [1×1 double]                    - masker size
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
%   mean1:          [1×2 double]                    - constraints of mean value the first mode
%   mode1:          [1×2 double]                    - constraints of mode value the first mode
%   var1:           [1×2 double]                    - constraints of variance value the first mode
%   amp1:           [1×2 double]                    - constraints of amplitude value the first mode
%   mean2:          [1×2 double]                    - constraints of mean value the second mode
%   mode2:          [1×2 double]                    - constraints of mode value the second mode
%   var2:           [1×2 double]                    - constraints of variance value the second mode
%   amp2:           [1×2 double]                    - constraints of amplitude value the second mode
%   quantile:       [1×1 double]                    - quantile threshold
%% The function returns following results:
%   getdata:        [function_handle]               - return cells stored raw or distribution
%% Examples:
%% 1. Show histogram by specific realization with default parameters:
% guihist(data.dwdlf(:,:,1));
%% 2. Show histogram by all realization with default parameters (ndim(data.dwdlf) = 3):
% guihist(data.dwdlf);
%% 3. Show histograms by all realization by two selection regions:
% guihist(gca, data.dwdlf, number = 2);
%% 4. Get raw data selected by gui:
% gd = guihist(data.dwdlf);
% probe = gd();
%% 5. Get raw data selected by two regions:
% gd = guihist(gca, data.dwdlf, number = 2);
% probes = gd();
% probe{1} = probes{1};
% probe{2} = probes{2};
%% 6. Show histogram by all realization with custom parameters, pdf is fitted by 'beta1' distribution, by solver fmincon with l2 norm and lower and upper constrains:
% guihist(data.dwdlf, mask = [25, 220, 25, 25], ...
%     distname = 'beta1', objnorm = 2, lb = [1, 0, 0, 1, 1], ...
%     ub = [1, 1e2, 0, 2e1, 1e4], norm = 'pdf', xlim = [0, 0.01], disp = true, cdf = true);
%% 7. Show histogram by all realization with custom parameters, pdf is fitted by 'beta2' distribution, by solver fmincon with l2 norm and lower, upper and non-linear constrains:
% % description of 'beta2':
% % f1 = @(a, x) a(1)*betapdf(x, a(2), a(3)); f1 = @(a, x) f1(a(1:3), x);
% % f2 = @(a, x) a(1)*betapdf(x, a(2), a(3)); f2 = @(a, x) f2(a(4:end), x);
% % fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
%
% % constrain function
% nonlcon = @(x) nonlconfitdist(x,distname='beta2',rmode1=[1e-4,6e-4],rvar1=[1e-8,1e-7],rmode2=[7e-4,5e-3],rvar2=[1e-7,1e-5]);
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
        kwargs.x double = []
        kwargs.z double = []
        kwargs.range double = []
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'cdf', 'cumcount', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge double = []
        kwargs.normalize (1,:) char {mustBeMember(kwargs.normalize, {'none', 'zscore', 'norm', 'center'})} = 'none'
        kwargs.getdata (1,:) char {mustBeMember(kwargs.getdata, {'raw', 'dist'})} = 'raw'
        %% roi and axis parameters
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'rect', 'poly'})} = 'rect'
        kwargs.mask double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.number int8 = 1
        kwargs.legend logical = false
        kwargs.xlim double = []
        kwargs.ylim double = []
        kwargs.clim double = []
        kwargs.colormap (1,:) char = 'turbo'
        kwargs.markersize double = 3
        kwargs.cdf logical = false
        kwargs.cumsum logical = false
        kwargs.docked logical = false
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal'
        kwargs.title (1,:) char = []
        kwargs.filename (1,:) char = []
        kwargs.extension (1,:) char = '.png'
        %% optimization parameters
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'none', 'chi21', 'beta1', 'beta1l', 'beta2', 'beta2l', 'gamma1', 'gamma2', 'gumbel1', 'gumbel2'})} = 'none'
        kwargs.objnorm double = 2
        kwargs.Aineq double = []
        kwargs.bineq double = []
        kwargs.Aeq double = []
        kwargs.beq double = []
        kwargs.nonlcon = []
        kwargs.x0 double = []
        kwargs.lb double = []
        kwargs.ub double = []
        kwargs.mb double = [0, 10]
        kwargs.disp logical = false
        %% restriction parameters
        kwargs.mean1 double = []
        kwargs.mode1 double = []
        kwargs.var1 double = []
        kwargs.amp1 double = []
        kwargs.mean2 double = []
        kwargs.mode2 double = []
        kwargs.var2 double = []
        kwargs.amp2 double = []
        %% other parameters
        kwargs.quantile double = 0.9
    end

    % define variables
    mode_markers = {'-o', '-s', '-x', '-<', '->', '-^'};

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.z)
        disp_type = 'node';
    else
        disp_type = 'spatial';
    end

    % define funtion handle to probe data
    switch disp_type
        case 'node'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'flatten');
            select2d = @(roiobj) guigetdata(roiobj, data, shape = 'cut');
        case 'spatial'
            select = @(roiobj) guigetdata(roiobj, data, shape = 'flatten', ...
                x = kwargs.x, z = kwargs.z);
            select2d = @(roiobj) guigetdata(roiobj, data, shape = 'cut', ...
                x = kwargs.x, z = kwargs.z);
    end

    % auto build non-linear constrain function
    temporary = isempty(cat(1, kwargs.mean1, kwargs.mode1, kwargs.var1, kwargs.amp1, kwargs.mean2, ...
        kwargs.mode2, kwargs.var2, kwargs.amp2));
    if isempty(kwargs.nonlcon) && ~temporary
        kwargs.nonlcon = @(x) nonlconfitdist(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    function result = roisgetdata()
        %% extract data from selectors
        result = cell(1, numel(rois));
        switch kwargs.getdata
            case 'raw'
                % normalization
                switch kwargs.normalize
                    case 'none'
                        for i = 1:length(rois)       
                            result{i} = select(rois{i});
                        end
                    otherwise
                        for i = 1:length(rois)     
                            result{i} = normalize(select(rois{i}), kwargs.normalize);
                        end
                end
            case 'dist'
                for i = 1:length(rois)       
                    [~, counts_raw, edges_raw, ~, ~, ~] = fithist(data = select(rois{i}), ...
                        distname = kwargs.distname, ...
                        objnorm = kwargs.objnorm, ...
                        nonlcon = kwargs.nonlcon, ...
                        lb = kwargs.lb, ...
                        x0 = kwargs.x0, ...
                        ub = kwargs.ub, ...
                        mb = kwargs.mb, ...
                        range = kwargs.range, ...
                        normalize = kwargs.normalize, ...
                        binedge = kwargs.binedge, ...
                        disp = kwargs.disp);
                    result{i} = [edges_raw, counts_raw];
                end
        end
    end

    function plot_raw_hist()
        %% show statistic of raw data
        cla(ax{1}); hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on');
        xlabel(ax{1}, 'edges'); ylabel(ax{1}, kwargs.norm);
        for i = 1:length(rois)
            if isempty(kwargs.binedge)
                [counts, edges] = histcounts(select(rois{i}), 'Normalization', kwargs.norm);
            else
                [counts, edges] = histcounts(select(rois{i}), kwargs.binedge, 'Normalization', kwargs.norm);
            end

            edges = edges(2:end);

            if ~isempty(kwargs.range)
                index = excludedata(edges, counts, 'range', kwargs.range);
                edges = edges(index); counts = counts(index); clear index;
            end

            plot(ax{1}, edges, counts, 'Color', rois{i}.UserData.color, ...
                'DisplayName', strcat("raw ", num2str(i)))
        end
    end

    function plot_fit_hist()
        %% show statistic of fitted data
        cla(ax{1}); hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on'); axis(ax{1}, 'square');
        xlabel(ax{1}, 'edges'); ylabel(ax{1}, kwargs.norm);

        if kwargs.cdf
            cla(ax{2}); hold(ax{2}, 'on'); box(ax{2}, 'on'); grid(ax{2}, 'on'); axis(ax{2}, 'square');
            xlabel(ax{2}, 'edges'); ylabel(ax{2}, 'cdf');
            ylim(ax{2}, [-0.1, 1.1])
        end

        for i = 1:length(rois)       
            [~, modes, edges_fit, ~, edges_raw, counts_raw] = fithist(data = select(rois{i}), ...
                distname = kwargs.distname, ...
                objnorm = kwargs.objnorm, ...
                nonlcon = kwargs.nonlcon, ...
                lb = kwargs.lb, ...
                x0 = kwargs.x0, ...
                ub = kwargs.ub, ...
                mb = kwargs.mb, ...
                range = kwargs.range, ...
                normalize = kwargs.normalize, ...
                binedge = kwargs.binedge, ...
                disp = kwargs.disp);

            if length(rois) == 1
                plot(ax{1}, edges_raw, counts_raw, 'Color', rois{i}.UserData.color, ...
                    'DisplayName', 'raw')
            else
                plot(ax{1}, edges_raw, counts_raw, 'Color', rois{i}.UserData.color, ...
                    'DisplayName', strcat("raw ", num2str(i)))
            end

            for j = 1:size(modes, 2)
                if kwargs.number == 1
                    switch j
                        case 1
                            label = 'lam.';
                        case 2
                            label = 'turb.';
                        otherwise
                            label = num2str(j);
                    end
                    plot(ax{1}, edges_fit, modes(:, j), 'DisplayName', label)
                else
                    plot(ax{1}, edges_fit, modes(:, j), mode_markers{j}, 'Color', rois{i}.UserData.color, ...
                        'MarkerSize', kwargs.markersize, ...
                        'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                end
            end

            if kwargs.number == 1
                if length(rois) == 1
                    plot(ax{1}, edges_fit, sum(modes, 2), ...
                        'DisplayName', 'sum modes')
                else
                    plot(ax{1}, edges_fit, sum(modes, 2), ...
                        'DisplayName', strcat("sum mode", num2str(i)))
                end
            else
                plot(ax{1}, edges_fit, sum(modes, 2), '.-', 'Color', rois{i}.UserData.color, ...
                    'DisplayName', strcat("sum mode", num2str(i)))
            end

            if kwargs.cdf
                cdf = cumsum(modes, 1); cdf = cdf ./ max(cdf, [], 1);
                if size(cdf, 2) == 2
                    cdf(:, 2) = 1 - cdf(:, 2);

                    if kwargs.disp
                        [~, indcdfint] = min(abs(diff(cdf, 1, 2)));
                        [~, indqntl] = min(abs(cdf(:, 1)-kwargs.quantile));
                        tab = [edges_fit(indcdfint); edges_fit(indqntl)];
                        tab = array2table(tab, 'VariableNames', {'value'}, 'RowName', {'cdf intersection', char(strcat("quantile ", num2str(kwargs.quantile)))});
                        disp(tab);
                    end
                end
                for j = 1:size(cdf, 2)
                    if kwargs.number == 1
                        switch j
                            case 1
                                label = 'lam.';
                            case 2
                                label = 'turb.';
                            otherwise
                                label = num2str(j);
                        end
                        plot(ax{2}, edges_fit, cdf(:, j), 'DisplayName', label)
                    else
                        plot(ax{2}, edges_fit, cdf(:, j), mode_markers{j}, 'Color', rois{i}.UserData.color, ...
                            'MarkerSize', kwargs.markersize, ...
                            'DisplayName', strcat("mode", num2str(j), " ", num2str(i)))
                    end
                end
            end
        end
    end

    function customize_appearance()
        %% change figure appearance
        if ~isempty(kwargs.xlim)
            for i = 1:length(ax)
                xlim(ax{i}, kwargs.xlim)
            end
        end

        if ~isempty(kwargs.ylim)
            for i = 1:length(ax)
                ylim(ax{i}, kwargs.ylim)
            end
        end

        if kwargs.legend
            for i = 1:length(ax)
                legend(ax{i}, 'Location', 'Best')
            end
        end
    end

    function plot_cumsum()
        cla(ax{3}); hold(ax{3}, 'on'); box(ax{3}, 'on'); grid(ax{3}, 'on'); axis(ax{3}, 'square');           
        for i = 1:length(rois)
            temporary = select2d(rois{i}); sz = numel(temporary);
            cnv = cumsum(squeeze(sum(temporary, [1, 2], 'omitmissing')))/sum(temporary(:));
            plot(ax{3}, cnv);
        end
    end

    function event(~, ~)
        %% callback at moved event
        switch kwargs.distname
            case 'none'
                plot_raw_hist();
            otherwise
                plot_fit_hist();
        end
        if kwargs.cumsum
            plot_cumsum();
        end
        customize_appearance();
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
    axroi = nexttile;
    switch disp_type
        case 'node'
            imagesc(axroi, data(:,:,1)); xlabel('x_{n}'); ylabel('z_{n}');
        case 'spatial'
            hold(axroi, 'on'); grid(axroi, 'on'); box(axroi, 'on');
            contourf(axroi, kwargs.x, kwargs.z, data(:,:,1), 100, 'LineStyle', 'None'); 
            xlabel('x, mm'); ylabel('z, mm');
            xlim([min(kwargs.x(:)), max(kwargs.x(:))]);
            ylim([min(kwargs.z(:)), max(kwargs.z(:))]);
    end
    colorbar(axroi); colormap(axroi, kwargs.colormap);
    if ~isempty(kwargs.clim)
        clim(axroi, kwargs.clim);
    end
    axis(axroi, kwargs.aspect)

    nexttile; ax{1} = gca;
    if kwargs.cdf; nexttile; ax{2} = gca; end
    if kwargs.cumsum; nexttile; ax{3} = gca; end
    rois = guiselectregion(axroi, moved = @event, shape = kwargs.shape, ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    event();

    varargout{1} = @() roisgetdata();

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end