function result = cnlpfilter(data, kernel_size, kernel_stride, method)
%% Apply custom method to sliding window data specified size and stride. 
%   User defined method must take nd array and return scalar.
%% The function takes following arguments:
%   data:               [n×m... double]     - multidimensional data
%   kernel_size:        [k×1 double]        - kernel size, wthen k<=ndims(data)
%   kernel_stride:      [k×1 double]        - kernel stride
%
%% The function returns following results:
%   result:     [n1×m1... double]   - filtered data

    sz = size(data);

    rows = 0:(kernel_size(1)-1);
    cols = 0:(kernel_size(2)-1);
    data = padarray(data, floor(kernel_size/2));

    [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
    X1 = X1(1:kernel_stride(1):end, 1:kernel_stride(2):end);
    X2 = X2(1:kernel_stride(1):end, 1:kernel_stride(2):end);
    sz1 = size(X1);
    X1 = X1(:); X2 = X2(:);
    result = zeros(1, numel(X1));

    [Y1, Y2] = ndgrid(1:prod(sz1), 1:prod(sz1));
    Y1 = Y1(:); Y2 = Y2(:);
    parfor k = 1:prod(sz1)*prod(sz1)
        i = Y1(k);
        j = Y2(k);
        temp = method(data(X1(i)+rows, X2(i)+cols, :), data(X1(j)+rows, X2(j)+cols, :));
        result(k) = temp;
    end

    result = reshape(result, sz1(1), sz1(2), sz1(1), sz1(2));
end