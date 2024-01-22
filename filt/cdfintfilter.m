function y = cdfintfilter(x, named)
%% Window filtering of statistical data: perform two mode histogram approximation 
% by given distribution, process criteria of statistical mode separation - intersection of cumulative distributions
%% The function takes following arguments:
%   x:              [n×m double]        - multidimensional data
%   distname:       [char array]        - name of approximation family distribution
%   objnorm:        [1×1 double]        - norm order of objective function
%   x0:             [1×k doule]         - inital parameters
%   lb:             [1×k doule]         - lower bound of parameters
%   ub:             [1×k doule]         - upper bpund of parameters
%   nonlcon:        [funtion_handle]    - non-linear optimization constrain function
%   root:           [char array]        - method to find root of two cdf intersection
%% The function returns following results:
%   y:              [double]            - filter step result

    arguments
        x double
        named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        named.binedge double = []
        named.distname (1,:) char {mustBeMember(named.distname, {'gauss2', 'beta2', 'beta2l', 'gamma2', 'gumbel2'})} = 'gumbel2'
        named.objnorm double = 2
        named.x0 double = []
        named.lb double = []
        named.ub double = []
        named.nonlcon = []
        named.root (1,:) char {mustBeMember(named.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
    end

    try
        [~, modes, edges, ~, ~, ~] = fithist(data = x(:), norm = named.norm, binedge = named.binedge, distname = named.distname, ...
            objnorm = named.objnorm, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            cdf = cumsum(modes, 1); cdf = cdf ./ max(cdf, [], 1);
            cdf(:, 2) = 1 - cdf(:, 2);
            switch named.root
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
    catch
        y = nan;
    end
end