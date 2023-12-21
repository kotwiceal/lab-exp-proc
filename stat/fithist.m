function varargout = fithist(named)
%% Analytical approximation of one-dimensional statistical distribution.
%% The function takes following arguments:
%   data:           [m×1 double]        - statistical data
%   x:              [n×1 double]        - statistical edges
%   y:              [n×1 double]        - statistical counts
%   norm:           [char array]        - type of statistics normalization
%   range:          [1×2 double]        - range to exclude data

%   type:           [char array]        - approximation type
%   solver:         [char array]        - execute fit or optimization: 'fit', 'opt'
%   objnorm:        [1×l double]        - norm order at calculation objective function
%   Aineq:          [p×l double]        - linear optimization inequality constrain matrix
%   bineq:          [l×1 double]        - linear optimization inequality constrain right side
%   Aeq:            [m×k double]        - linear optimization equality constrain matrix
%   beq:            [k×1 double]        - linear optimization equality constrain right side
%   nonlcon:        [funtion_handle]    - non-linear optimization constrain function
%   x0:             [1×k doule]         - inital parameters
%   lb:             [1×k doule]         - lower bound of parameters
%   ub:             [1×k doule]         - upper bpund of parameters
%   show_param:     [logical]           - display optimization result 
%% The function returns following results:
%   x:              [n×1 double]        - statistical edges
%   y:              [n×1 double]        - statistical counts
%   f:              [1×1 cfit]          - fit object
%   modes:          [n×k double]        - approximate distribution modes assembled to column vector mapped by specific edges grid
%   edges:          [n×1 double]        - mesh of modes
%   fval:           [1×l double]        - value of object function
%% Examples:
%% fit raw data by two beta distributions with lower, upper and non-linear constrains
% % gui
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% rois = guihist(gca, data.dwdlf);
% probe = guigetdata(rois{1}, data.dwdlf, shape = 'flatten'); % get raw data
%
% % constrain function
% nonlcon = @(x) nonlcon_beta2(x, rmean1 = [], rmode1 = [8e-4, 1.8e-3], rvar1 = [1e-7, 1e-6], ....
%         ramp1 = [], rmean2 = [], rmode2 = [3e-3, 4e-3], rvar2 = [1e-6, 1e-2]);
% % boundary constrains
% lb = [0, 1e-3, 0, 7.8, 6416, 1e-3, 1e-2, 0, 0, 0];
% ub = [2, 2e1, 1e-2, 7.8, 6416, 10, 2e1, 1e-2, 1e3, 1e4];
% % initial vector
% x0 = [1, 1, 1e-3, 5, 1e3, 1, 1, 3e-3, 10, 2e3];
% % fit
% [x, y, f, modes, edges, fval] = fithist(data = probe, type = 'beta2', ...
%     solver = 'opt', objnorm = 2, nonlcon = nonlcon, x0 = x0, lb = lb, ub = ub, show_param = true);
%% fit pdf curve by two skew normal distributions
% % gui
% clf; tiledlayout(2, 2);
% nexttile; imagesc(data.dwdlf(:,:,1));
% rois = guihist(gca, data.dwdlf);
% probe = guigetdata(rois{1}, data.dwdlf, shape = 'flatten'); % get raw data
% [y, x] = histcounts(probe, 'normalization', 'pdf');
% x = x(2:end);
%
% % fit
% [f, modes, edges] = fithist(x = x, y = y, type = 'gauss2s1', solver = 'fit');

    arguments
        %% data parameters
        named.data double = []
        named.x double = []
        named.y double = []
        named.norm char = 'pdf'
        named.range double = []
        %% optimization parameters
        named.type char = 'gauss1'
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

    x = []; y = []; modes = []; f = [];

    % prepare fitting data
    if isempty(named.data)
        if ~(isempty(named.x) && isempty(named.y))
            x = named.x; y = named.y;
        end
    else
        [y, x] = histcounts(named.data, 'Normalization', named.norm);
        x = x(2:end);
    end

    % exclude data
    if ~isempty(named.range)
        index = excludedata(x, y, 'range', named.range);
        x = x(index); y = y(index); clear index;
    end

    [x, y] = prepareCurveData(x, y);

    edges = linspace(0, max(x), 1e3);

    % initialize optimization problem
    options = optimoptions('fmincon', 'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations', 5000, 'MaxIterations', 1500, ...
        'DiffMaxChange', 0.001);
    problem = struct(options = options, solver = 'fmincon');

    if ~isempty(named.Aineq); problem.Aineq = named.Aineq; end
    if ~isempty(named.bineq); problem.bineq = named.bineq; end

    if ~isempty(named.nonlcon); problem.nonlcon = named.nonlcon; end

    if ~isempty(named.x0); problem.x0 = named.x0; end
    if ~isempty(named.lb); problem.lb = named.lb; end
    if ~isempty(named.ub); problem.ub = named.ub; end

    % selection fitting action
    switch named.type
        case 'gauss1'
            switch named.solver
                case 'fit'
                    f = fit(x, y, 'gauss1');
                    modes(:, 1) = f(edges); 
                case 'opt'
                    fa = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'normal'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;
        
                    coefi = [1, 1, 0, fi.mu, fi.sigma];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = fa(coef, edges);
            end
        case 'gauss1s'
            switch named.solver
                case 'fit'
                    fa = @(a, b, c, d, x) a*exp(-((x-b)/c).^2).*(1+erf(d*(x-b)/c));            
                    % get parameters to initial appoximation
                    fe = fit(x, y, 'gauss1');
        
                    % adjust solver configuration
                    ft = fittype(fa, 'independent', 'x', 'coefficients', ["a", "b", "c", "d"]);
                    opts = fitoptions('Method', 'NonlinearLeastSquares');
                    opts.Algorithm = 'Trust-Region';
                    opts.Display = 'Off';
                    opts.Lower = zeros(1, 4);
                    opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(y)];
                    opts.Upper = 5*opts.StartPoint;
        
                    f = fit(x, y, ft, opts);
                    modes(:, 1) = f.a*exp(-((edges-f.b)/f.c).^2).*(1+erf(f.d*(edges-f.b)/f.c));
                case 'opt'
                    fa = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)).*normcdf(a(6)*(x*a(2)-a(3)), a(4), a(5)); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'Normal'); % initial appriximation

                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;

                    coefi = [1, 1, 0, fi.mu, fi.sigma, skewness(named.data)];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end

                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = fa(coef, edges);
            end
        case 'gauss2'
            switch named.solver
                case 'fit'
                    % fit function: two normal distributions
                    f = fit(x, y, 'gauss2');
                    modes(:, 1) = f.a1*exp(-((edges-f.b1)/f.c1).^2); 
                    modes(:, 2) = f.a2*exp(-((edges-f.b2)/f.c2).^2);
                case 'opt'
                    f1 = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)); f1 = @(a, x) f1(a(1:5), x);
                    f2 = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)); f2 = @(a, x) f2(a(6:end), x);
                    fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'Normal'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;

                    coefi = [1, 1, 0, fi.mu, fi.sigma, skewness(named.data), 1, 1, 0, fi.mu, fi.sigma, skewness(named.data)];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = f1(coef, edges);
                    modes(:, 2) = f2(coef, edges);
            end
        case 'gauss2s1'
            switch named.solver
                case 'fit'
                    % fit function: normal + skew normal distributions
                    fa = @(a, b, c, d, e, f, g, x) a*exp(-((x-b)/c).^2).*(1+erf(d*(x-b)/c))+e*exp(-((x-f)/g).^2);            
        
                    % adjust solver configuration
                    ft = fittype(fa, 'independent', 'x', 'coefficients', ["a", "b", "c", "d", "e", "f", "g"]);
                    opts = fitoptions('Method', 'NonlinearLeastSquares');
                    opts.Algorithm = 'Trust-Region';
                    opts.Display = 'Off';
                    opts.Lower = zeros(1, 7);
                    % opts.Upper = 10*opts.StartPoint;
        
                    % get parameters to initial appoximation
                    try
                        fe = fit(x, y, named.init);
                    catch
                        fe = fit(x, y, 'gauss1');
                    end
        
                    switch named.init
                        case 'gauss1'
                            opts.StartPoint = [fe.a1, abs(fe.b1), fe.c1, skewness(y), fe.a1, abs(fe.b1), fe.c1];
                        case 'gauss2'
                            if isempty(named.regul)
                                opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(y), fe.a2, fe.b2, fe.c2];
                            else
                                opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(y), fe.a2, named.regul(1), named.regul(2)];
                            end
                    end
        
                    
                    if isempty(named.regul)
                        opts.Upper = 10*opts.StartPoint;
                    else
                        opts.Lower = [0, named.regul(3), named.regul(4), named.regul(5), 0, 0, 0];
                        % opts.Upper = [5*fe.a1, named.regul(3), named.regul(4), named.regul(5), named.regul(1), named.regul(2)];
                        opts.Upper = [10*opts.StartPoint(1:5), named.regul(1), named.regul(2)];
                    end
                    
                    f = fit(x, y, ft, opts);
                    modes(:, 1) = f.e*exp(-((edges-f.f)/f.g).^2);
                    modes(:, 2) = f.a*exp(-((edges-f.b)/f.c).^2).*(1+erf(f.d*(edges-f.b)/f.c));
                case 'opt'
                    f1 = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)); f1 = @(a, x) f1(a(1:5), x);
                    f2 = @(a, x) a(1)*normpdf(x*x(2)-a(3), a(4), a(5)).*normcdf(a(6)*(x*a(2)-a(3)), a(4), a(5)); f2 = @(a, x) f2(a(6:end), x);
                    fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'Normal'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;

                    coefi = [1, 1, 0, fi.mu, fi.sigma, 1, 1, 0, fi.mu, fi.sigma, skewness(named.data)];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = f1(coef, edges);
                    modes(:, 2) = f2(coef, edges);
            end
        case 'gauss2s2'
            switch named.solver
                case 'fit'
                    % fit function: 2 x skew normal distributions
                    fa = @(a, b, c, d, e, f, g, h, x) a*exp(-((x-b)/c).^2).*(1+erf(d*(x-b)/c))+e*exp(-((x-f)/g).^2).*(1+erf(h*(x-f)/g));            
        
                    % adjust solver configuration
                    ft = fittype(fa, 'independent', 'x', 'coefficients', ["a", "b", "c", "d", "e", "f", "g", "h"]);
                    opts = fitoptions('Method', 'NonlinearLeastSquares');
                    opts.Algorithm = 'Trust-Region';
                    opts.Display = 'Off';
                    opts.Lower = zeros(1, 8);
        
                    % get parameters to initial appoximation
                    try
                        fe = fit(x, y, named.init);
                    catch
                        fe = fit(x, y, 'gauss1');
                    end
        
                    switch named.init
                        case 'gauss1'
                            opts.StartPoint = [fe.a1, abs(fe.b1), fe.c1, skewness(y), fe.a1, abs(fe.b1), fe.c1, skewness(y)];
                        case 'gauss2'
                            if isempty(named.regul)
                                opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(y), fe.a2, fe.b2, fe.c2, skewness(y)];
                            else
                                opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(y), fe.a2, named.regul(1), named.regul(2), named.regul(3)];
                            end
                    end    
        
                    opts.Upper = 10*opts.StartPoint;

                    f = fit(x, y, ft, opts);
                    modes(:, 1) = f.e*exp(-((edges-f.f)/f.g).^2).*(1+erf(f.h*(edges-f.f)/f.g));
                    modes(:, 2) = f.a*exp(-((edges-f.b)/f.c).^2).*(1+erf(f.d*(edges-f.b)/f.c));
    
                case 'opt'
                    f1 = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)).*normcdf(a(6)*(x*a(4)-a(5)), a(4), a(5)); f1 = @(a, x) f1(a(1:6), x);
                    f2 = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)).*normcdf(a(6)*(x*a(4)-a(5)), a(4), a(5)); f2 = @(a, x) f2(a(7:end), x);
                    fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'Normal'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;

                    coefi = [1, 1, 0, fi.mu, fi.sigma, skewness(named.data), 1, 1, 0, fi.mu, fi.sigma, skewness(named.data)];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = f1(coef, edges);
                    modes(:, 2) = f2(coef, edges);
            end
        case 'beta1'
            switch named.solver
                case 'fit'
                    f = fitdist(named.data, 'beta');
                    modes(:, 1) = f.pdf(edges);
                case 'opt'
                    fa = @(a, x) a(1)*betapdf(x*a(2)-a(3), a(4), a(5)); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'beta'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;
        
                    coefi = [1, 1, mode(named.data), fi.a, fi.b];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = fa(coef, edges);
            end
        case 'beta2'
            switch named.solver
                case 'opt'
                    f1 = @(a, x) a(1)*betapdf(a(2)*x-a(3), a(4), a(5)); f1 = @(a, x) f1(a(1:5), x);
                    f2 = @(a, x) a(1)*betapdf(a(2)*x-a(3), a(4), a(5)); f2 = @(a, x) f2(a(6:end), x);
                    fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'beta'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;
        
                    coefi = [1, 1, mode(named.data), fi.a, fi.b, 1, 1, mode(named.data), fi.a, fi.b];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);

                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                        a = coef;
                        modess = [1/a(2)*((a(4)-1)/(a(4)+a(5)-2)+a(3)), ...
                            1/a(7)*((a(9)-1)/(a(9)+a(10)-2)+a(8))];
                        means = [1/a(2)*(a(4)/(a(4)+a(5))+a(3)), ...
                            1/a(7)*(a(9)/(a(9)+a(10))+a(8))];
                        vars = [a(4)*a(5)/(a(4)+a(5))^2/(a(4)+a(5)+1)/a(2)^2, ...
                            a(9)*a(10)/(a(9)+a(10))^2/(a(9)+a(10)+1)/a(7)^2];
                        amps = [a(1)*betapdf(a(2)*modess(1)-a(3), a(4), a(5)), ...
                            a(6)*betapdf(a(7)*modess(2)-a(8), a(9), a(10))]; 
                        disp(strcat("modes: ", num2str(modess)))
                        disp(strcat("means: ", num2str(means)))
                        disp(strcat("vars: ", num2str(vars)))
                        disp(strcat("amps: ", num2str(amps)))
                        [~, temp] = problem.nonlcon(coef);
                        disp(strcat("nonlcon(coef): ", num2str(temp)))
                    end

                    f = @(x) fa(coef, x);
                    modes(:, 1) = f1(coef, edges);
                    modes(:, 2) = f2(coef, edges);
            end
        case 'gamma1'
            switch named.solver
                case 'fit'
                    f = fitdist(named.data, 'gamma');
                    modes(:, 1) = f.pdf(edges);
                case 'opt'
                    fa = @(a, x) a(1)*gampdf(x*a(2)-a(3), a(4), a(5)); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'gamma'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;
        
                    coefi = [1, 1, mode(named.data), fi.a, fi.b];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = fa(coef, edges);
            end
        case 'gamma2'
            switch named.solver
                case 'opt'
                    f1 = @(a, x) a(1)*gampdf(x*a(2)-a(3), a(4), a(5)); f1 = @(a, x) f1(a(1:5), x);
                    f2 = @(a, x) a(1)*gampdf(x*a(2)-a(3), a(4), a(5)); f2 = @(a, x) f2(a(6:end), x);
                    fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = fitdist(named.data, 'gamma'); % initial appriximation
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;
        
                    coefi = [1, 1, mode(named.data), fi.a, fi.b, 1, 1, mode(named.data), fi.a, fi.b];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = f1(coef, edges);
                    modes(:, 2) = f2(coef, edges);
            end
        case 'gaussbeta'
            switch named.solver
                case 'fit'
                    edges = [];
                case 'opt'
                    f1 = @(a, x) a(1)*normpdf(x*a(2)-a(3), a(4), a(5)); f1 = @(a, x) f1(a(1:5), x);
                    f2 = @(a, x) a(1)*betapdf(x*a(2)-a(3), a(4), a(5)); f2 = @(a, x) f2(a(6:end), x);
                    fa = @(a, x) f1(a, x) + f2(a, x); % approximation function
                    fy = fit(x, y, 'linearinterp'); % linear interpolation of fitted curve
                    fi = cell(1, 2); % initial appriximation
                    fi{1} = fitdist(named.data, 'normal');
                    fi{2} = fitdist(named.data, 'beta');
        
                    fobj = @(a) norm(fa(a, x)-fy(x), named.objnorm); % objective function
                    problem.objective = fobj;
        
                    coefi = [1, 1, mode(named.data), fi{1}.mu, fi{1}.sigma, 1, 1, 0, fi{2}.a, fi{2}.b];
                    if isempty(named.x0); problem.x0 = coefi; end
                    if isempty(named.lb); problem.lb = 0.1*coefi; end
                    if isempty(named.ub); problem.ub = 10*coefi; end
        
                    [coef, fval] = fmincon(problem);
                    if named.show_param
                        disp(strcat("solution: ", num2str(coef)));
                        disp(strcat("fval: ", num2str(fval)))
                    end
                    f = @(x) fa(coef, x);
                    modes(:, 1) = f1(coef, edges);
                    modes(:, 2) = f2(coef, edges);
            end
    end

    % select outputs
    if isempty(named.x) && isempty(named.y)
        varargout{1} = x;
        varargout{2} = y;
        varargout{3} = f;
        varargout{4} = modes;
        varargout{5} = edges;
        switch named.solver
            case 'opt'
                varargout{6} = fval;        
        end
    else
        varargout{1} = f;
        varargout{2} = modes;
        varargout{3} = edges;
    end
end