function y = intrelfilter(x, named)
%% Window filtering of statistical data: perform two mode histogram approximation 
% by given distribution, process criteria of statistical mode separation - ratio of distribution integrals
%% The function takes following arguments:
%   x:              [n×m double]        - multidimensional data
%   norm:           [char array]        - type of statistics normalization
%   binedge:        [double]            - bins count or edge grid 
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
        named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        named.binedge double = []
        named.distname (1,:) char {mustBeMember(named.distname, {'gauss2', 'beta2', 'beta2l', 'gamma2', 'gumbel2'})} = 'gumbel2'
        %% optimization parameters
        named.objnorm double = 2
        named.x0 double = []
        named.lb double = []
        named.ub double = []
        named.nonlcon = []
    end

    try
        [~, modes, ~, ~, ~, ~] = fithist(data = x(:), norm = named.norm, binedge = named.binedge, distname = named.distname, ...
            objnorm = named.objnorm, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
        modes_cs = cumsum(modes, 1);
        y = 1-modes_cs(end,1)/sum(modes_cs(end,:));
    catch
        y = nan;
    end
end