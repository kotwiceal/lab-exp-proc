function y = cdfintfilter(x, norm, binedge, type, objnorm, x0, lb, ub, nonlcon)
%% Window filtering of statistical data: perform two mode histogram approximation 
% by given distribution, process criteria of statistical mode separation - intersection of cumulative distributions
%% The function takes following arguments:
%   x:              [n×m double]        - multidimensional data
%   type:           [char array]        - name of approximation family distribution
%   objnorm:        [1×1 double]        - norm order of objective function
%   x0:             [1×k doule]         - inital parameters
%   lb:             [1×k doule]         - lower bound of parameters
%   ub:             [1×k doule]         - upper bpund of parameters
%   nonlcon:        [funtion_handle]    - non-linear optimization constrain function
%% The function returns following results:
%   y:              [double]            - filter step result

    arguments
        x double
        norm (1,:) char {mustBeMember(norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        binedge double = []
        type (1,:) char {mustBeMember(type, {'gauss2', 'beta2', 'gamma2', 'gumbel2'})} = 'gumbel2'
        objnorm double = 2
        x0 double = []
        lb double = []
        ub double = []
        nonlcon = []
    end

    try
        [~, ~, ~, modes, edges, ~] = fithist(data = x(:), norm = norm, binedge = binedge, type = type, solver = 'opt', ...
            objnorm = objnorm, x0 = x0, lb = lb, ub = ub, nonlcon = nonlcon);
            modes_cs = cumsum(modes, 1); modes_cs = modes_cs ./ max(modes_cs, [], 1);
            modes_cs(:, 2) = 1 - modes_cs(:, 2);
            [~, index] = min(abs(diff(modes_cs, 1, 2)));
            y = edges(index);
    catch
        y = nan;
    end
end