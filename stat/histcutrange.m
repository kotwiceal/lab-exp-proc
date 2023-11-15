function [edges, counts] = histcutrange(edges, counts, range)
%% Cut data by specified range.
%% The function takes following arguments:
% edges:    [n×1 double]
% counts:   [n×1 double]
% range:    [1×2 double]
%% The function returns following results:
% edges:    [k×1 double]
% counts:   [k×1 double]

    index = (edges > range(1)) & (edges < range(2));
    counts = counts(index); edges = edges(index);
end