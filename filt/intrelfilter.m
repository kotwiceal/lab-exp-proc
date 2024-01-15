function y = intrelfilter(x, type, objnorm, x0, lb, ub, nonlcon)
%% Window filter%% Window filtering of statistical data: perform two mode histogram approximation 
% by given distribution, process criteria of statistical mode separation - ratio of distribution integrals
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

    try
        [~, ~, ~, modes, ~, ~] = fithist(data = x(:), type = type, solver = 'opt', ...
            objnorm = objnorm, x0 = x0, lb = lb, ub = ub, nonlcon = nonlcon);
        modes_cs = cumsum(modes, 1);
        y = 1-modes_cs(end,1)/sum(modes_cs(end,:));
    catch
        y = nan;
    end
end