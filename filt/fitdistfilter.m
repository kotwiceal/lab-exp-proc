function y = fitdistfilter(x, kwargs)
%% Window filtering of statistical data: perform two mode histogram approximation 
% by given distribution, process criteria of statistical mode separation - ratio of distribution integrals
%% The function takes following arguments:
%   x:              [n×m double]        - multidimensional data
%   norm:           [char array]        - type of statistics normalization
%   binedge:        [double]            - bins count or edge grid 
%   distname:       [char array]        - name of approximation family distribution
%   method:         [char array]        - method of intermittency processing
%   quantile:       [1×1 double]        - quantile threshold
%   root:           [char array]        - method to find root of two cdf intersection
%   objnorm:        [1×1 double]        - norm order of objective function
%   x0:             [1×k doule]         - inital parameters
%   lb:             [1×k doule]         - lower bound of parameters
%   ub:             [1×k doule]         - upper bpund of parameters
%   nonlcon:        [funtion_handle]    - non-linear optimization constrain function
%% The function returns following results:
%   y:              [double]            - filter step result

    arguments
        x double
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge double = []
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gauss2', 'beta2', 'beta2l', 'gamma2', 'gumbel2'})} = 'gumbel2'
        %% algorithm parameters
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio', 'fitdistcoef'})} = 'integral-ratio'
        kwargs.quantile double = 0.2
        kwargs.root (1,:) char {mustBeMember(kwargs.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
        %% optimization parameters
        kwargs.objnorm double = 2
        kwargs.x0 double = []
        kwargs.lb double = []
        kwargs.ub double = []
        kwargs.nonlcon = []
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
        modes_cs = cumsum(modes, 1);
        y = 1-modes_cs(end,1)/sum(modes_cs(end,:), 'omitmissing');
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