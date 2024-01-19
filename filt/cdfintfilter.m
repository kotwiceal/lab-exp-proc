function y = cdfintfilter(x, named)
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
            named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
            named.binedge double = []
            named.type (1,:) char {mustBeMember(named.type, {'gauss2', 'beta2', 'gamma2', 'gumbel2'})} = 'gumbel2'
            named.objnorm double = 2
            named.x0 double = []
            named.lb double = []
            named.ub double = []
            named.nonlcon = []
        end
    
        try
            [~, ~, ~, modes, edges, ~] = fithist(data = x(:), norm = named.norm, binedge = named.binedge, type = named.type, solver = 'opt', ...
                objnorm = named.objnorm, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
                modes_cs = cumsum(modes, 1); modes_cs = modes_cs ./ max(modes_cs, [], 1);
                modes_cs(:, 2) = 1 - modes_cs(:, 2);
                [~, index] = min(abs(diff(modes_cs, 1, 2)));
                y = edges(index);
        catch
            y = nan;
        end
    end