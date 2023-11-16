function result = binarize(data, threshold)
%% Multidimensional threshold global binarization.
%% The function takes following arguments:
%   data:       [l×n×... double]
%   threshold:  [double]
%% The function returns following results:
%   result: [l×n×... double]
    
        result = zeros(size(data));
        result(data >= threshold) = 1;
        result(isnan(data)) = nan;
    end