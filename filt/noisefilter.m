function result = noisefilter(x)
%% Filter of data weighting by normal distribution noise.
%% The function takes following arguments:
%   x:  [n×m double]    - multidimensional data
%
%% The function returns following results:
%   result: [double]    - filter step result

    kernel = rand(size(x)); kernel = kernel ./ sum(kernel(:));
    result = kernel.*x;
    result = sum(result(:));
end