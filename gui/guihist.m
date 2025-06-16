function varargout = guihist(varargin, kwargs, opt)
    %% Visualize data statistics by means manually region selection.

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
    %% 6. Show histogram by all realization with custom parameters, pdf is fitted by 'beta1' distribution, by solver fmincon with l2 norm and lower and upper constrains:
    % guihist(data.dwdlf, mask = [25, 220, 25, 25], ...
    %     distname = 'beta1', objnorm = 2, lb = [1, 0, 0, 1, 1], ...
    %     ub = [1, 1e2, 0, 2e1, 1e4], norm = 'pdf', xlim = [0, 0.01], verbose = true, cdf = true);
    %% 7. Show histogram by all realization with custom parameters, pdf is fitted by 'beta2' distribution, by solver fmincon with l2 norm and lower, upper and non-linear constrains:
    % % description of 'beta2':
    % % f1 = @(a, x) a(1)*betapdf(x, a(2), a(3)); f1 = @(a, x) f1(a(1:3), x);
    % % f2 = @(a, x) a(1)*betapdf(x, a(2), a(3)); f2 = @(a, x) f2(a(4:end), x);
    % % fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
    %
    % % constrain function
    % nonlcon = @(x) nonlconfitdist(x,distname='beta2',mode1=[1e-4,6e-4],var1=[1e-8,1e-7],mode2=[7e-4,5e-3],var2=[1e-7,1e-5]);
    % % boundary constrains
    % lb = [0, 1e-3, 0, 7.8, 6416, 1e-3, 1e-2, 0, 0, 0];
    % ub = [2, 2e1, 1e-2, 7.8, 6416, 10, 2e1, 1e-2, 1e3, 1e4];
    % % gui
    % guihist(data.dwdlf, mask = [250, 50, 25, 25], ...
    %     distname = 'beta2', objnorm = 2, lb = lb, ub = ub, nonlcon = nonlcon, ...
    %     norm = 'pdf', xlim = [0, 0.01], verbose = true, cdf = true);

    arguments (Repeating)
        varargin double % vector or multidimensional data
    end

    arguments
        %% data parameters
        kwargs.x double = [] % spatial coordinate
        kwargs.z double = [] % spatial coordinate
        kwargs.range double = [] % range to exclude data
        %type of statistics normalization
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'cdf', 'cumcount', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        % bins count or edge grid
        kwargs.binedge = []
        % type of data normalization
        kwargs.normalize (1,:) char {mustBeMember(kwargs.normalize, {'none', 'zscore', 'norm', 'center', 'scale', 'range'})} = 'none'
        kwargs.pow (1,:) double = []
        kwargs.trackline (1,1) logical = false
        %% roi and axis parameters
        kwargs.arrangement (1,:) char {mustBeMember(kwargs.arrangement, {'flow', 'vertical', 'horizontal'})} = 'flow'
        % type of region selection
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'rect', 'polygon'})} = 'rect'
        % edge size to rectangle selection or n-row verxex to polygon selection 
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = []
        % region selection behaviour: 'translate', 'all'   
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.number (1,1) double {mustBeInteger} = 1 % number of selection regions
        kwargs.xlabel (1,:) char = [] % x-axis label of data subplot
        kwargs.ylabel (1,:) char = [] % y-axis label of data subplot
        kwargs.zlabel (1,:) char = [] % z-axis label of data subplot
        kwargs.clabel (1,:) {mustBeA(kwargs.clabel, {'char', 'cell'})} = {} % color-axis label of field subplot
        kwargs.legend logical = false % show legend
        kwargs.xlim double = [] % x-axis limit
        kwargs.ylim double = [] % y-axis limit
        kwargs.clim double = [] % color-axis limit
        kwargs.colormap (1,:) char = 'turbo' % colormap name
        kwargs.colorbarloc (1,:) char = 'eastoutside'
        kwargs.levels (1,:) double = 100;
        kwargs.markersize double = 3 % 
        kwargs.cdf logical = false % plot cdf of statistics
        kwargs.cumsum logical = false % plot cumulative sum of statistics
        kwargs.docked logical = false % docked figure
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto', 'image', 'square'})} = 'image'
        kwargs.aspecthist (1,:) char {mustBeMember(kwargs.aspecthist, {'equal', 'auto', 'image', 'square'})} = 'auto'
        kwargs.title (1,:) char = [] % to show global title
        kwargs.filename (1,:) char = [] % to store figure
        kwargs.extension (1,:) char = '.png' % image extension of stored figure
        kwargs.fontsize (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.fontsize, 1)} = 10 % axis font size
        kwargs.linewidth double = 1.25
        %% optimization parameters
        % type of statistics fit
        opt.distname (1,:) char {mustBeMember(opt.distname, {'none', 'chi21', 'beta1', 'beta1l', 'beta2', 'beta2l', 'gamma1', 'gamma2', 'gumbel1', 'gumbel2'})} = 'none'
        opt.objnorm double = 2 % norm order at calculation objective function
        opt.Aineq double = [] % linear optimization inequality constrain matrix
        opt.bineq double = [] % linear optimization inequality constrain right side
        opt.Aeq double = [] % linear optimization equality constrain matrix
        opt.beq double = [] % linear optimization equality constrain right side
        opt.nonlcon = [] % non-linear optimization constrain function
        opt.x0 double = [] % inital approximation
        opt.lb double = [] % lower bound of parameters
        opt.ub double = [] % upper bpund of parameters
        opt.mb double = [0, 10] % scale range of auto constrains
        opt.verbose logical = false % display of statistic parameters and optimization result 
        %% restriction parameters
        opt.mean1 double = [] % constraints of mean value the first mode
        opt.mode1 double = [] % constraints of mode value the first mode
        opt.var1 double = [] %  constraints of variance value the first mode
        opt.amp1 double = [] % constraints of amplitude value the first mode
        opt.mean2 double = [] % constraints of mean value the second mode
        opt.mode2 double = [] % constraints of mode value the second mode
        opt.var2 double = [] % constraints of variance value the second mode
        opt.amp2 double = [] % constraints of amplitude value the second mode
        %% other parameters
        opt.quantile double = 0.9
    end

    % define variables
    mode_markers = {'-o', '-s', '-x', '-<', '->', '-^'};

    isvect = isvector(varargin{1});

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.z)
        disptype = 'node';
    else
        disptype = 'spatial';
    end

    switch numel(varargin)
        case 1
            % define funtion handle to probe data
            switch disptype
                case 'node'
                    select = @(roiobj) guigetdata(roiobj, varargin{1}, shape = 'flatten');
                    select2d = @(roiobj) guigetdata(roiobj, varargin{1}, shape = 'cut');
                    selectraw = @(roiobj) guigetdata(roiobj, varargin{1}, shape = 'raw');
                case 'spatial'
                    select = @(roiobj) guigetdata(roiobj, varargin{1}, shape = 'flatten', ...
                        x = kwargs.x, z = kwargs.z);
                    selectraw = @(roiobj) guigetdata(roiobj, varargin{1}, shape = 'raw', ...
                        x = kwargs.x, z = kwargs.z);
            end
        case 2
            % define funtion handle to probe data
            switch disptype
                case 'node'
                    select = @(roiobj) cat(2, guigetdata(roiobj, varargin{1}, shape = 'flatten'), ...
                        guigetdata(roiobj, varargin{2}, shape = 'flatten'));
                case 'spatial'
                    select = @(roiobj) cat(2, guigetdata(roiobj, varargin{1}, shape = 'flatten', ...
                        x = kwargs.x, z = kwargs.z), guigetdata(roiobj, varargin{2}, shape = 'flatten', ...
                        x = kwargs.x, z = kwargs.z));
            end
    end

    % auto build non-linear constrain function
    temporary = isempty(cat(1, opt.mean1, opt.mode1, opt.var1, opt.amp1, opt.mean2, ...
        opt.mode2, opt.var2, opt.amp2));
    if isempty(opt.nonlcon) && ~temporary
        opt.nonlcon = @(x) nonlconfitdist(x, distname = opt.distname, mean1 = opt.mean1, mode1 = opt.mode1, ...
            var1 = opt.var1, amp1 = opt.amp1, mean2 = opt.mean2, mode2 = opt.mode2, var2 = opt.var2, amp2 = opt.amp2);
    end

    fithistfunc = @(roi) fithist(data = select(roi), ...
        distname = opt.distname, ...
        objnorm = opt.objnorm, ...
        nonlcon = opt.nonlcon, ...
        lb = opt.lb, ...
        x0 = opt.x0, ...
        ub = opt.ub, ...
        mb = opt.mb, ...
        range = kwargs.range, ...
        normalize = kwargs.normalize, ...
        binedge = kwargs.binedge, ...
        pow = kwargs.pow, ...
        verbose = opt.verbose);

    function result = getdatafunc()
        result = struct();
        % store mask of ROI
        for i = 1:length(rois)  
            result.mask{i} = rois{i}.Position; 
        end
        if isscalar(result.mask)
            result.mask = result.mask{1};
        end
        % normalization
        switch kwargs.normalize
            case 'none'
                for i = 1:length(rois)       
                    result.raw{i} = select(rois{i});
                end
            otherwise
                for i = 1:length(rois)     
                    result.raw{i} = normalize(select(rois{i}), kwargs.normalize);
                end
        end
        for i = 1:length(rois)       
            [~, counts_raw, edges_raw, coef, ~, ~] = fithistfunc(rois{i});
            if opt.distname ~= "none"
                result.param{i} = distparam(coef, distname = opt.distname, disp = false);
            end
            result.dist{i} = [edges_raw, counts_raw];
        end
        try
            temporary = cell(1, length(rois));
            for i = 1:length(rois)
                temporary{i} = selectraw(rois{i});
            end
            result.rawnd = temporary{i};
        catch
        end

        if ~isempty(kwargs.filename)
            savefig(gcf, strcat(kwargs.filename, '.fig'))
            exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
        end
    end

    function plot_raw_hist()
        %% show statistic of raw data
        cla(ax{1}); axis(ax{1}, kwargs.aspecthist); set(ax{1}, fontsize = kwargs.fontsize);
        for i = 1:length(rois)
            switch numel(varargin)
                case 1
                    % normalization
                    switch kwargs.normalize
                        case 'none'
                            temporary = select(rois{i});
                        otherwise
                            temporary = normalize(select(rois{i}), kwargs.normalize);
                    end
        
                    if ~isempty(kwargs.pow); temporary = temporary.^kwargs.pow; end
        
                    param.mean(:,i) = mean(temporary);
                    param.mode(:,i) = mode(temporary);
                    param.variance(:,i) = var(temporary);
                    param.skewness(:,i) = skewness(temporary);
                    param.kurtosis(:,i) = kurtosis(temporary);
        
                    if isempty(kwargs.binedge)
                        [counts, edges] = histcounts(temporary, 'Normalization', kwargs.norm);
                    else
                        [counts, edges] = histcounts(temporary, kwargs.binedge, 'Normalization', kwargs.norm);
                    end
        
                    edges = edges(2:end);
        
                    if ~isempty(kwargs.range)
                        index = excludedata(edges, counts, 'range', kwargs.range);
                        edges = edges(index); counts = counts(index); clear index;
                    end

                    plot(ax{1}, edges, counts, 'Color', rois{i}.Color, ...
                        'DisplayName', strcat("raw ", num2str(i)), 'LineWidth', kwargs.linewidth)
                    xlabel(ax{1}, kwargs.clabel); ylabel(ax{1}, upper(kwargs.norm));
                    hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on');
                case 2
                    temporary = select(rois{i});

                    % normalization
                    switch kwargs.normalize
                        case 'none'
                            temporary = select(rois{i});
                        otherwise
                            temporary = normalize(select(rois{i}), 2, kwargs.normalize);
                    end

                    param.mean(:,i) = mean(temporary);
                    param.mode(:,i) = mode(temporary);
                    param.variance(:,i) = var(temporary);
                    param.skewness(:,i) = skewness(temporary);
                    param.kurtosis(:,i) = kurtosis(temporary);

                    if isempty(kwargs.binedge)
                        [counts, Xedges, Yedges] = histcounts2(temporary(:,1), temporary(:,2), 'Normalization', kwargs.norm);
                    else
                        if ~iscell(kwargs.binedge)
                            [counts, Xedges, Yedges] = histcounts2(temporary(:,1), temporary(:,2), kwargs.binedge, kwargs.binedge, 'Normalization', kwargs.norm);
                        else
                            [counts, Xedges, Yedges] = histcounts2(temporary(:,1), temporary(:,2), kwargs.binedge{1}, kwargs.binedge{2}, 'Normalization', kwargs.norm);
                        end
                    end
                    [Xedges, Yedges] = meshgrid(Xedges(1:end-1), Yedges(1:end-1));
                    surf(ax{1}, Xedges, Yedges, counts', 'LineStyle', 'None'); clb = colorbar(ax{1}, kwargs.colorbarloc);
                    xlabel(ax{1}, 'edges_1'); ylabel(ax{1}, 'edges_2'); ylabel(clb, kwargs.norm);
                    box(ax{1}, 'on'); grid(ax{1}, 'on');
            end
        end
        if opt.verbose
            tab = reshape([param.mean; param.mode; param.variance; param.skewness; param.kurtosis], [], 5)';
            tab = array2table(tab, 'VariableNames', "raw"+split(num2str(1:size(temporary,2)))+" roi"+split(num2str(1:numel(rois)))', 'RowName', {'mean', 'mode', 'variance', 'skewness', 'kurtosis'});
            disp(tab);
        end
    end

    function plot_fit_hist()
        %% show statistic of fitted data
        cla(ax{1}); hold(ax{1}, 'on'); box(ax{1}, 'on'); grid(ax{1}, 'on');
        xlabel(ax{1}, kwargs.clabel); ylabel(ax{1}, upper(kwargs.norm));
        axis(ax{1}, kwargs.aspecthist); set(ax{1}, FontSize = kwargs.fontsize);

        if kwargs.cdf
            cla(ax{2}); hold(ax{2}, 'on'); box(ax{2}, 'on'); grid(ax{2}, 'on');
            set(ax{2}, FontSize = kwargs.fontsize);
            xlabel(ax{2}, kwargs.clabel); ylabel(ax{2}, 'cdf');
            ylim(ax{2}, [-0.1, 1.1])
        end

        for i = 1:length(rois)       
            [~, modes, edges_fit, ~, edges_raw, counts_raw] = fithistfunc(rois{i});

            if isscalar(rois)
                plot(ax{1}, edges_raw, counts_raw, 'Color', rois{i}.Color, ...
                    'DisplayName', 'raw')
            else
                plot(ax{1}, edges_raw, counts_raw, 'Color', rois{i}.Color, ...
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
                if isscalar(rois)
                    plot(ax{1}, edges_fit, sum(modes, 2), ...
                        'DisplayName', 'lam.+turb.')
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

                    if opt.verbose
                        [~, indcdfint] = min(abs(diff(cdf, 1, 2)));
                        [~, indqntl] = min(abs(cdf(:, 1)-opt.quantile));
                        tab = [edges_fit(indcdfint); edges_fit(indqntl)];
                        tab = array2table(tab, 'VariableNames', {'value'}, 'RowName', {'cdf intersection', char(strcat("quantile ", num2str(opt.quantile)))});
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

    function adjustrectroi(~, ~)
        if isvect
            yl = get(axroi, 'YLim');
            for i = 1:length(rois)
                rois{i}.Position = [rois{i}.Position(1), yl(1), rois{i}.Position(3), yl(2)-yl(1)];
            end
        end


        if kwargs.trackline
            %% event to align rectangle selection box along line
            positions = [];
            for i = 1:numel(rois)
                positions = cat(1, positions, rois{i}.Position);
            end
            positions(:,1) = linspace(positions(1,1), positions(end,1), kwargs.number);
            positions(:,2) = linspace(positions(1,2), positions(end,2), kwargs.number);
            try
                positions(:,3:4) = repmat(evt.CurrentPosition(:,3:4), kwargs.number, 1);
            catch
            end
            for i = 1:numel(rois)
                rois{i}.Position = positions(i, :);
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
        switch opt.distname
            case 'none'
                plot_raw_hist();
            otherwise
                plot_fit_hist();
        end
        if kwargs.cumsum
            switch numel(varargin)
                case 1
                plot_cumsum();
            end
        end
        customize_appearance();
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout(kwargs.arrangement);
    axroi = nexttile;
    if isvect
        hold(axroi, 'on'); grid(axroi, 'on'); box(axroi, 'on');
        switch disptype
            case 'node'
                plot(axroi, varargin{1});
            case 'spatial'
                plot(axroi, kwargs.x, varargin{1});
        end
    else
        switch disptype
            case 'node'
                imagesc(axroi, varargin{1}(:,:,1)); 
                if kwargs.aspect ~= "auto"; axis(axroi, kwargs.aspect); end
            case 'spatial'
                % hold(axroi, 'off'); grid(axroi, 'on'); box(axroi, 'on');
                contourf(axroi, kwargs.x, kwargs.z, varargin{1}(:,:,1), kwargs.levels, 'LineStyle', 'None'); 
                grid(axroi, 'on'); box(axroi, 'on');
                xlim([min(kwargs.x(:)), max(kwargs.x(:))]);
                ylim([min(kwargs.z(:)), max(kwargs.z(:))]);
                axis(axroi, kwargs.aspect);
        end
        clb = colorbar(axroi, kwargs.colorbarloc); colormap(axroi, kwargs.colormap);
        if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel); end
        if ~isempty(kwargs.clim)
            clim(axroi, kwargs.clim);
        end
    end
    set(gca, FontSize = kwargs.fontsize);
    if ~isempty(kwargs.xlabel); xlabel(axroi, kwargs.xlabel); end
    if ~isempty(kwargs.ylabel); ylabel(axroi, kwargs.ylabel); end

    if isvect && ~isempty(kwargs.mask)
        yl = get(axroi, 'YLim');
        kwargs.mask = [kwargs.mask(1), yl(1), kwargs.mask(2)-kwargs.mask(1), yl(2)-yl(1)];
    end

    nexttile; ax{1} = gca; hold(ax{1}, 'on'); grid(ax{1}, 'on'); box(ax{1}, 'on');
    if kwargs.cdf; nexttile; ax{2} = gca; hold(ax{2}, 'on'); grid(ax{2}, 'on'); box(ax{2}, 'on'); end
    if kwargs.cumsum; nexttile; ax{3} = gca; hold(ax{3}, 'on'); grid(ax{3}, 'on'); box(ax{3}, 'on'); end
    rois = guiselectregion(axroi, moving = @adjustrectroi,moved = @event, shape = kwargs.shape, ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    event();

    varargout{1} = @() getdatafunc();

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end