function result = nlpfilter(x, kernel_size, method, kwargs)
%% Apply custom method to data selected by sliding window with specified size and stride.
%   User defined method must take nd array and return scalar.
%% The function takes following arguments:
%   data:               [n×m... double]     - multidimensional data
%   kernel_size:        [1×2 double]        - kernel size, when k<=ndims(data)
%   strides:            [1×2 double]        - kernel stride
%   type:               [char array]        - type filtering
%   resize:             [1×1 logical]       - resize filtered data to initial shape
%   padval:             [1×1 double]        - to fill pad
%% The function returns following results:
%   result:             [n1×m1... double]   - filtered data

    arguments
        x double
        kernel_size double
        method function_handle
        kwargs.y double = []
        kwargs.strides double = [1, 1]
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'slice', 'slice-cross', 'deep', 'deep-cross'})} = 'slice'
        kwargs.resize logical = false
        kwargs.padval double = nan
    end

    if ismatrix(x)
        switch kwargs.type
            case 'slice'
                sz = size(x);
            
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                x = padarray(x, floor(kernel_size/2), kwargs.padval);
            
                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);
                result = zeros(1, numel(X1));
                parfor i = 1:numel(X1)
                    temp = method(x(X1(i)+rows, X2(i)+cols));
                    result(i) = temp;
                end
            
                result = reshape(result, sz1);
            case 'slice-cross'
                sz0 = size(x);
                x = reshape(x, sz0(1), sz0(2), []);
        
                sz = size(x);
            
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                x = padarray(x, floor(kernel_size/2), kwargs.padval);
                y = padarray(kwargs.y, floor(kernel_size/2), kwargs.padval);
            
                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);
                result = zeros(1, numel(X1));

                parfor i = 1:numel(X1)
                    temp = method(x(X1(i)+rows, X2(i)+cols), y(X1(i)+rows, X2(i)+cols));
                    result(i) = temp;
                end
                result = reshape(result, sz1);
        end
    else
        switch kwargs.type
            case 'slice'
                sz0 = size(x);
                x = reshape(x, sz0(1), sz0(2), []);
        
                sz = size(x);
            
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                x = padarray(x, floor(kernel_size/2), kwargs.padval);
            
                [X1, X2, X3] = ndgrid(1:sz(1), 1:sz(2), 1:sz(3));
                X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                X3 = X3(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:); X3(:);
                result = zeros(1, numel(X1));
                parfor i = 1:numel(X1)
                    temp = method(x(X1(i)+rows, X2(i)+cols, X3(i)));
                    result(i) = temp;
                end
            
                result = reshape(result, [sz1(1:2), sz0(3:end)]);
            case 'slice-cross'
                sz0 = size(x);
                x = reshape(x, sz0(1), sz0(2), []);
        
                sz = size(x); szy = size(kwargs.y);
            
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                x = padarray(x, floor(kernel_size/2), kwargs.padval);
                y = padarray(kwargs.y, floor(kernel_size/2), kwargs.padval);
            
                [X1, X2, X3] = ndgrid(1:sz(1), 1:sz(2), 1:sz(3));
                X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                X3 = X3(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:); X3(:);
                result = zeros(1, numel(X1));

                if ismatrix(y)
                    parfor i = 1:numel(X1)
                        temp = method(x(X1(i)+rows, X2(i)+cols, X3(i)), y(X1(i)+rows, X2(i)+cols));
                        result(i) = temp;
                    end
                else
                    if sz == szy
                        parfor i = 1:numel(X1)
                            temp = method(x(X1(i)+rows, X2(i)+cols, X3(i)), y(X1(i)+rows, X2(i)+cols, X3(i)));
                            result(i) = temp;
                        end
                    end
                end
                result = reshape(result, [sz1(1:2), sz0(3:end)]);
            case 'deep'
                sz = size(x);
    
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                x = padarray(x, floor(kernel_size/2), kwargs.padval);
            
                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);

                % calculate output array size
                temporary = method(x(X1(1)+rows, X2(1)+cols, :)); szout = size(temporary);
                result = zeros(numel(X1), numel(temporary));
                result(1, :) = temporary; clear temporary;

                % process
                parfor i = 2:numel(X1)
                    result(i, :) = method(x(X1(i)+rows, X2(i)+cols, :));
                end
                result = squeeze(reshape(result, [sz1, szout]));
            case 'deep-cross'
                sz = size(x);
    
                rows = 0:(kernel_size(1)-1);
                cols = 0:(kernel_size(2)-1);
                x = padarray(x, floor(kernel_size/2), kwargs.padval);
                y = padarray(kwargs.y, floor(kernel_size/2), kwargs.padval);

                [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                sz1 = size(X1);
                X1 = X1(:); X2 = X2(:);

                % calculate output array size
                temporary = method(x(X1(1)+rows, X2(1)+cols, :), y(X1(1)+rows, X2(1)+cols, :)); 
                szout = size(temporary);
                result = zeros(numel(X1), numel(temporary));
                result(1, :) = temporary; clear temporary;

                % process
                parfor i = 2:numel(X1)
                    result(i, :) = method(x(X1(i)+rows, X2(i)+cols, :), y(X1(i)+rows, X2(i)+cols, :));
                end
                result = squeeze(reshape(result, [sz1, szout]));
        end
    end

    if kwargs.resize
        sz2 = size(result); temporary = zeros([sz(1:2), prod(sz2(3:end))]);
        for i = 1:prod(sz2(3:end))
            temporary(:, :, i) = imresize(result(:, :, i), sz(1:2));
        end
        result = reshape(temporary, [sz(1:2), sz2(3:end)]); clear temporary;
    end

end