function result = nlpfilter(data, kernel_size, method, named)
%% Apply custom method to data selected by sliding window with specified size and stride.
%   User defined method must take nd array and return scalar.
%% The function takes following arguments:
%   data:               [n×m... double]     - multidimensional data
%   kernel_size:        [1×2 double]        - kernel size, when k<=ndims(data)
%   strides:            [1×2 double]        - kernel stride
%   type:               [char array]        - `slice` filter window takes in 2d data; `deep` - 3d;
%   resize:             [1×1 logical]       - resize filtered data to initial shape
%% The function returns following results:
%   result:     [n1×m1... double]   - filtered data

    arguments
        data double
        kernel_size double
        method function_handle
        named.B double = []
        named.strides double = [1, 1]
        named.type (1,:) char {mustBeMember(named.type, {'slice', 'deep', 'deep-A', 'deep-AB'})} = 'slice'
        named.resize logical = false
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
                for i = 1:numel(X1)
                    temp = method(data(X1(i)+rows, X2(i)+cols, :));
                    result(i) = temp;
                end
            
                result = reshape(result, sz1);
            case 'deep-A'
                sz = size(data);
    
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                data = padarray(data, floor(kernel_size/2));
            
                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:named.strides(1):end, 1:named.strides(2):end);
                X2 = X2(1:named.strides(1):end, 1:named.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);

                % calculate output array size
                temporary = method(data(X1(1)+rows, X2(1)+cols, :)); szout = size(temporary);
                result = zeros(numel(X1), numel(temporary));
                result(1, :) = temporary; clear temporary;

                % process
                parfor i = 2:numel(X1)
                    result(i, :) = method(data(X1(i)+rows, X2(i)+cols, :));
                end
                result = squeeze(reshape(result, [sz1, szout]));
            case 'deep-AB'
                sz = size(data);
    
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                data = padarray(data, floor(kernel_size/2));
                B = padarray(named.B, floor(kernel_size/2), nan);

                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:named.strides(1):end, 1:named.strides(2):end);
                X2 = X2(1:named.strides(1):end, 1:named.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);

                % calculate output array size
                temporary = method(data(X1(1)+rows, X2(1)+cols, :), B(X1(1)+rows, X2(1)+cols, :)); 
                szout = size(temporary);
                result = zeros(numel(X1), numel(temporary));
                result(1, :) = temporary; clear temporary;

                % process
                parfor i = 2:numel(X1)
                    result(i, :) = method(data(X1(i)+rows, X2(i)+cols, :), B(X1(i)+rows, X2(i)+cols, :));
                end
                result = squeeze(reshape(result, [sz1, szout]));
        end
    end

    if named.resize
        sz2 = size(result); temporary = zeros([sz(1:2), prod(sz2(3:end))]);
        for i = 1:prod(sz2(3:end))
            temporary(:, :, i) = imresize(result(:, :, i), sz(1:2));
        end
        result = reshape(temporary, [sz(1:2), sz2(3:end)]); clear temporary;
    end

end