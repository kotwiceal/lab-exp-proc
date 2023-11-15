function [edges1, counts1, edges2, counts2, edgesgl, f1s, f2s, f12s] = histsimilarfactor(edges1, counts1, edges2, counts2)
%% Apply silimarilty statistics criteria.
%% The function takes following arguments:
%   edges1:     [n×1 double]    - edges of first statistics
%   counts1:    [n×1 double]    - counts of first statistics
%   edges2:     [n×1 double]    - edges of second statistics
%   counts2:    [n×1 double]    - counts of second statistics
%
%% The function returns following results:
%   edges1:     [n×1 double]    - edges of first statistics
%   counts1:    [n×1 double]    - modified counts of first statistics
%   edges2:     [m×1 double]    - edges of second statistics
%   counts2:    [m×1 double]    - modified counts of second statistics
%   edgesgl:    [k×1 double]    - mapped edges of two statistics
%   f1s:        [k×1 double]    - gridded approximation of first statistics
%   f2s:        [k×1 double]    - gridded approximation of second statistics
%   f12s:       [k×1 double]    - gridded critea statistics

    if ~iscolumn(counts1)
        counts1 = counts1';
    end
    if ~iscolumn(edges1)
        edges1 = edges1';
    end

    if ~iscolumn(counts2)
        counts2 = counts2';
    end
    if ~iscolumn(edges2)
        edges2 = edges2';
    end

    edgesgl = linspace(min([edges1; edges2]), max([edges1; edges2]));
    try
        f1 = fit(edges1, counts1, 'gauss1');
        f2 = fit(edges2, counts2, 'gauss1');
        f1s = f1(edgesgl); f1s = f1s ./ f1.a1;
        f2s = f2(edgesgl); f2s = f2s ./ f2.a1;
    
        counts1 = counts1/f1.a1;
        counts2 = counts2/f2.a1;
        f12s = f1s.*f2s;
    catch
        f1s = zeros(size(edgesgl));
        f2s = zeros(size(edgesgl));
        f12s = zeros(size(edgesgl));
    end

end