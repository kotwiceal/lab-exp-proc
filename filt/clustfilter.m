function y = clustfilter(x, kwargs)
%% Window filtering of statistical data: perform two mode histogram approximation 
% by given distribution, process criteria of statistical mode separation - quantile threshold of cumulative distribution
%% The function takes following arguments:
%   x:              [n×m double]        - multidimensional data
%   k:              [1×1 double]        - number of clusters
%   distance:       [char array]        - cluster method metric
%% The function returns following results:
%   y:              [double]            - filter step result

    arguments
        x double
        kwargs.k double = 2
        kwargs.distance (1,:) char {mustBeMember(kwargs.distance, {'sqeuclidean', 'cityblock', 'cosine', 'correlation', 'hamming'})} = 'sqeuclidean'
    end

    try
        [binarized, center] = kmeans(x(:), kwargs.k, 'Distance', kwargs.distance);
        [~, index] = max(center);
        switch index
            case 1
                binarized = -(binarized - 2);
            case 2
                binarized = binarized - 1;
        end
        y = mean(binarized, 'all', 'omitmissing');
    catch
        y = nan;
    end
end