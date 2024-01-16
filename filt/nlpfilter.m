function result = nlpfilter(data, kernel_size, method, named)
%% Apply custom method to data selected by sliding window with specified size and stride.
%   User defined method must take nd array and return scalar.
%% The function takes following arguments:
%   data:               [n×m... double]     - multidimensional data
%   kernel_size:        [k×1 double]        - kernel size, when k<=ndims(data)
%   strides:            [k×1 double]        - kernel stride
%   type:               [char array]        - `slice` filter window takes in 2d data; `deep` - 3d;
%
%% The function returns following results:
%   result:     [n1×m1... double]   - filtered data

    arguments
        data double
        kernel_size double
        method function_handle
        named.strides double = [1, 1]
        named.type (1,:) char {mustBeMember(type, {'slice', 'deep'})} = 'slice'
    end


    if ismatrix(data)

        sz = size(data);
    
        rows = 0:(kernel_size(1)-1);
        cols = 0:(kernel_size(2)-1);
        data = padarray(data, floor(kernel_size/2));
    
        [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
        X1 = X1(1:named.strides(1):end, 1:named.strides(2):end);
        X2 = X2(1:named.strides(1):end, 1:named.strides(2):end);
        sz1 = size(X1);
        X1 = X1(:); X2 = X2(:);
        result = zeros(1, numel(X1));
        parfor i = 1:numel(X1)
            temp = method(data(X1(i)+rows, X2(i)+cols));
            result(i) = temp;
        end
    
        result = reshape(result, sz1);

    else
        switch named.type
            case 'slice'
                sz0 = size(data);
                data = reshape(data, sz0(1), sz0(2), []);
        
                sz = size(data);
            
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                data = padarray(data, floor(kernel_size/2));
            
                [X1, X2, X3] = ndgrid(1:sz(1), 1:sz(2), 1:sz(3));
                X1 = X1(1:named.strides(1):end, 1:named.strides(2):end, :);
                X2 = X2(1:named.strides(1):end, 1:named.strides(2):end, :);
                X3 = X3(1:named.strides(1):end, 1:named.strides(2):end, :);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:); X3(:);
                result = zeros(1, numel(X1));
                parfor i = 1:numel(X1)
                    temp = method(data(X1(i)+rows, X2(i)+cols, X3(i)));
                    result(i) = temp;
                end
            
                result = reshape(result, [sz1(1:2), sz0(3:end)]);
            case 'deep'
                sz = size(data);
    
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                data = padarray(data, floor(kernel_size/2));
            
                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:named.strides(1):end, 1:named.strides(2):end);
                X2 = X2(1:named.strides(1):end, 1:named.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);
                result = zeros(1, numel(X1));
                parfor i = 1:numel(X1)
                    temp = method(data(X1(i)+rows, X2(i)+cols, :));
                    result(i) = temp;
                end
            
                result = reshape(result, sz1);
        end
    end
end