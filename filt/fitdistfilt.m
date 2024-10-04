function y = fitdistfilt(x, kwargs)
    %% Window filtering of statistical data: perform two mode histogram approximation 
    % by given distribution, process criteria of statistical mode separation - ratio of distribution integrals

    arguments
        x double % multidimensional data
        % type of statistics normalization
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge double = [] % bins count or edge grid
        % name of approximation family distribution
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gauss2', 'beta2', 'beta2l', 'gamma2', 'gumbel2'})} = 'gumbel2'
        %% algorithm parameters
        % method of intermittency processing
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio', 'fitdistcoef'})} = 'integral-ratio'
        kwargs.quantile (1,1) double = 0.9 % quantile threshold
        % method to find root of two cdf intersection
        kwargs.root (1,:) char {mustBeMember(kwargs.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
        %% optimization parameters
        kwargs.objnorm (1,1) double = 2 % norm order of objective function
        kwargs.x0 (1,:) double = [] % inital parameters
        kwargs.lb (1,:) double = [] % lower bound of parameters
        kwargs.ub (1,:) double = [] % upper bpund of parameters
        kwargs.nonlcon = [] % non-linear optimization constrain function
    end

    function y = quantilethreshold(edges, modes, root, quantile)
        cdf = cumsum(modes, 1); cdf = cdf ./ max(cdf, [], 1);
        cdf(:, 2) = 1 - cdf(:, 2);
        switch root
            case 'diff'
                [~, index] = min(abs(cdf(:, 1)-quantile)); y = edges(index);
            case 'fsolve'
                [~, index] = min(abs(cdf(:, 1)-quantile)); y = edges(index);
                [edges0, cdf10] = prepareCurveData(edges, cdf(:,1)); fcdf10 = fit(edges0, cdf10, 'linearinterp'); % fit cdf of mode 1
                problem = struct('objective', @(x) norm(fcdf10(x)-quantile, 2), 'options', ...
                    optimoptions('fsolve', 'Algorithm', 'trust-region', ...
                        'MaxFunctionEvaluations', 1e4, 'MaxIterations', 3e3, 'DiffMaxChange', 1e-4, 'Display', 'Off'), ...
                        'x0', y, 'lb', min(edges), 'ub', max(edges), 'solver', 'fsolve'); 
                y = fsolve(problem);
            case 'fminbnd'
                [edges0, cdf10] = prepareCurveData(edges, cdf(:,1)); fcdf10 = fit(edges0, cdf10, 'linearinterp'); % fit cdf of mode 1
                y = fminbnd(@(x) norm(fcdf10(x)-quantile, 2), min(edges), max(edges));
        end
    end

    function y = cdfintersection(edges, modes, root)
        cdf = cumsum(modes, 1); cdf = cdf ./ max(cdf, [], 1);
        cdf(:, 2) = 1 - cdf(:, 2);
        switch root
            case 'diff'
                [~, index] = min(abs(diff(cdf, 1, 2))); y = edges(index); return;
            case 'fsolve'
                [~, index] = min(abs(diff(cdf, 1, 2))); y = edges(index);
                [edges0, cdf10] = prepareCurveData(edges, cdf(:,1)); fcdf10 = fit(edges0, cdf10, 'linearinterp'); % fit cdf of mode 1
                [edges0, cdf20] = prepareCurveData(edges, cdf(:,2)); fcdf20 = fit(edges0, cdf20, 'linearinterp'); % fit cdf of mode 2           
                problem = struct('objective', @(x) norm(fcdf10(x)-fcdf20(x), 2), 'options', ...
                    optimoptions('fsolve', 'Algorithm', 'trust-region', ...
                        'MaxFunctionEvaluations', 1e4, 'MaxIterations', 3e3, 'DiffMaxChange', 1e-4, 'Display', 'Off'), ...
                        'x0', y, 'lb', min(edges), 'ub', max(edges), 'solver', 'fsolve'); 
                y = fsolve(problem);
                return;
            case 'fminbnd'
                [edges0, cdf10] = prepareCurveData(edges, cdf(:,1)); fcdf10 = fit(edges0, cdf10, 'linearinterp'); % fit cdf of mode 1
                [edges0, cdf20] = prepareCurveData(edges, cdf(:,2)); fcdf20 = fit(edges0, cdf20, 'linearinterp'); % fit cdf of mode 2           
                y = fminbnd(@(x) norm(fcdf10(x)-fcdf20(x), 2), min(edges), max(edges));
                return;
        end
    end

    function y = integralratio(modes)
        y = sum(modes(:,2), 'omitmissing')./sum(modes(:), 'omitmissing');
    end

    try
        [~, modes, edges, coef, ~, ~] = fithist(data = x(:), norm = kwargs.norm, binedge = kwargs.binedge, distname = kwargs.distname, ...
            objnorm = kwargs.objnorm, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
        switch kwargs.method
            case 'quantile-threshold'
                y = quantilethreshold(edges, modes, kwargs.root, kwargs.quantile);
            case 'cdf-intersection'
                y = cdfintersection(edges, modes, kwargs.root);
            case 'integral-ratio'
                y = integralratio(modes);
            case 'fitdistcoef'
                y = coef;
        end
    catch
        y = nan;
    end
end