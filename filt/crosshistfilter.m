function result = crosshistfilter(x, y)
%% Apply intersection criteria of two statistics.
%% The function takes following arguments:
%   x:  [n×m... double]     - multidimensional dataset of first statistic
%   y:  [n×m... double]     - multidimensional dataset of second statistic
%
%% The function returns following results:
%   result:     [n1×m1... double]   - criteria value

    [counts1, edges1] = histcounts(x(:));
    edges1 = edges1(2:end);
    [counts2, edges2] = histcounts(y(:));
    edges2 = edges2(2:end);

    [edges1, counts1, edges2, counts2, edgesgl, f1s, f2s, f12s] = histsimilarfactor(edges1, counts1, edges2, counts2);

    result = max(f12s);
end