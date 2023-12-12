function [f, modes] = fithist(counts, edges, named)
%% Analytical approximation of one-dimensional statistical distribution.
%% The function takes following arguments:
%   counts:     [n×1 double]    - statistical counts
%   edges:      [n×1 double]    - statistical edges
%   type:       [char array]    - approximation type
%   range:      [1×2 double]    - specified range to cut data
%   init:       [char array]    - initialize histogram approximation
%% The function returns following results:
%   f:          [1×1 cfit]      - fit object
%   modes:      [n×k double]  - approximate distribution modes assembled to column vector mapped by specific edges grid

    arguments
        counts double
        edges double
        named.type char = 'gauss1'
        named.range double = []
        named.init char = 'gauss1'
        named.regul double = []
    end

    if ~iscolumn(counts)
        counts = counts';
    end
    if ~iscolumn(edges)
        edges = edges';
    end

    if ~isempty(named.range)
        [edges, counts] = histcutrange(edges, counts, named.range);
    end

    switch named.type
        case 'gauss1'
            f = fit(edges, counts, 'gauss1');
            modes(:, 1) = f.a1*exp(-((edges-f.b1)/f.c1).^2); 
        case 'gauss1s'

            fa = @(a, b, c, d, x) a*exp(-((x-b)/c).^2).*(1+erf(d*(x-b)/c));            
            % get parameters to initial appoximation
            fe = fit(edges, counts, 'gauss1');

            % adjust solver configuration
            ft = fittype(fa, 'independent', 'x', 'coefficients', ["a", "b", "c", "d"]);
            opts = fitoptions('Method', 'NonlinearLeastSquares');
            opts.Algorithm = 'Trust-Region';
            opts.Display = 'Off';
            opts.Lower = zeros(1, 4);
            opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(counts)];
            opts.Upper = 5*opts.StartPoint;

            f = fit(edges, counts, ft, opts);
            modes(:, 1) = f.a*exp(-((edges-f.b)/f.c).^2).*(1+erf(f.d*(edges-f.b)/f.c));

        case 'gauss2'
            % fit function: two normal distributions
            f = fit(edges, counts, 'gauss2');
            modes(:, 1) = f.a1*exp(-((edges-f.b1)/f.c1).^2); 
            modes(:, 2) = f.a2*exp(-((edges-f.b2)/f.c2).^2);
        case 'gauss2s'
            % fit function: normal + skew normal distributions
            fa = @(a, b, c, d, e, f, g, x) a*exp(-((x-b)/c).^2).*(1+erf(d*(x-b)/c))+e*exp(-((x-f)/g).^2);            

            % adjust solver configuration
            ft = fittype(fa, 'independent', 'x', 'coefficients', ["a", "b", "c", "d", "e", "f", "g"]);
            opts = fitoptions('Method', 'NonlinearLeastSquares');
            opts.Algorithm = 'Trust-Region';
            opts.Display = 'Off';
            opts.Lower = zeros(1, 7);
            opts.Upper = 10*opts.StartPoint;

            % get parameters to initial appoximation
            try
                fe = fit(edges, counts, named.init);
            catch
                fe = fit(edges, counts, 'gauss1');
            end

            switch named.init
                case 'gauss1'
                    opts.StartPoint = [fe.a1, abs(fe.b1), fe.c1, skewness(counts), fe.a1, abs(fe.b1), fe.c1];
                case 'gauss2'
                    if isempty(named.regul)
                        opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(counts), fe.a2, fe.b2, fe.c2];
                    else
                        opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(counts), fe.a2, named.regul(1), named.regul(2)];
                    end
            end
            
            f = fit(edges, counts, ft, opts);
            modes(:, 1) = f.e*exp(-((edges-f.f)/f.g).^2);
            modes(:, 2) = f.a*exp(-((edges-f.b)/f.c).^2).*(1+erf(f.d*(edges-f.b)/f.c));
        case 'gauss2s2'
            % fit function: normal + skew normal distributions
            fa = @(a, b, c, d, e, f, g, x) a*exp(-((x-b)/c).^2).*(1+erf(d*(x-b)/c))+e*exp(-((x-f)/g).^2).*(1+erf(h*(x-f)/g));            

            % adjust solver configuration
            ft = fittype(fa, 'independent', 'x', 'coefficients', ["a", "b", "c", "d", "e", "f", "g", "h"]);
            opts = fitoptions('Method', 'NonlinearLeastSquares');
            opts.Algorithm = 'Trust-Region';
            opts.Display = 'Off';
            opts.Lower = zeros(1, 8);
            opts.Upper = 10*opts.StartPoint;

            % get parameters to initial appoximation
            try
                fe = fit(edges, counts, named.init);
            catch
                fe = fit(edges, counts, 'gauss1');
            end

            switch named.init
                case 'gauss1'
                    opts.StartPoint = [fe.a1, abs(fe.b1), fe.c1, skewness(counts), fe.a1, abs(fe.b1), fe.c1];
                case 'gauss2'
                    if isempty(named.regul)
                        opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(counts), fe.a2, fe.b2, fe.c2, skewness(counts)];
                    else
                        opts.StartPoint = [fe.a1, fe.b1, fe.c1, skewness(counts), fe.a2, named.regul(1), named.regul(2), named.regul(3)];
                    end
            end
            
            f = fit(edges, counts, ft, opts);
            modes(:, 1) = f.e*exp(-((edges-f.f)/f.g).^2).*(1+erf(f.h*(edges-f.f)/f.g));
            modes(:, 2) = f.a*exp(-((edges-f.b)/f.c).^2).*(1+erf(f.d*(edges-f.b)/f.c));
    end
end