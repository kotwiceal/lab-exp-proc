function result = nlpfilter(x, kernel, method, kwargs)
%% Apply custom method to data selected by sliding window with specified size and stride.
%   User defined method must take nd array and return scalar.
%% The function takes following arguments:
%   x:                  [n×m... double]     - vector or multidimensional data
%   kernel:             [1×2 double]        - kernel size, when k<=ndims(data)
%   strides:            [1×2 double]        - kernel stride
%   type:               [char array]        - type filtering
%   resize:             [1×1 logical]       - resize filtered data to initial shape
%   padval:             [1×1 double]        - to fill pad
%% The function returns following results:
%   result:             [n1×m1... double]   - filtered data

    arguments
        x double
        kernel (1,:) double
        method function_handle
        kwargs.y double = []
        kwargs.strides (1,:) double = [1, 1]
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'slice', 'slice-cross', 'deep', 'deep-cross'})} = 'slice'
        kwargs.resize logical = false
        kwargs.padval double = nan
    end

    switch kwargs.type
        case 'slice'
            if isvector(x)
                if numel(x) == kernel
                    result = method(x);
                else
                    sz = size(x);
                    rows = 0:(kernel(1)-1);
                    X1 = 1:numel(x); X1 = X1(1:kwargs.strides(1):end);  
                    sz1 = size(X1); X1 = X1(:);
                    x = padarray(x(:), floor(kernel(1)/2), kwargs.padval);
    
                    % calculate output array size
                    temporary = method(x(X1(1)+rows)); szout = size(temporary);
                    result = zeros(numel(X1), numel(temporary));
                    result(1, :) = temporary; clear temporary;
    
                    parfor i = 2:numel(X1)
                        result(i, :) = method(x(X1(i)+rows));
                    end
                    result = squeeze(reshape(result, [sz1, szout]));
                end
            else
                if ismatrix(x)
                    sz = size(x);
                
                    rows = 0:(kernel(1)-1);
                    cols = 0:(kernel(2)-1);
                    x = padarray(x, floor(kernel/2), kwargs.padval);
                
                    [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                    X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                    X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                    sz1 = size(X1);
                    X1 = X1(:); X2 = X2(:);

                    % calculate output array size
                    temporary = method(x(X1(1)+rows, X2(1)+cols)); szout = size(temporary);
                    result = zeros(numel(X1), numel(temporary));
                    result(1, :) = temporary; clear temporary;

                    parfor i = 2:numel(X1)
                        result(i, :) = method(x(X1(i)+rows, X2(i)+cols));
                    end
                    result = squeeze(reshape(result, [sz1, szout]));
                else
                    sz = size(x);
                    rows = 0:(kernel(1)-1);
                    cols = 0:(kernel(2)-1);
                    x = padarray(x(:,:,:), floor(kernel/2), kwargs.padval);  
                    [X1, X2, X3] = ndgrid(1:sz(1), 1:sz(2), 1:prod(sz(3:end)));
                    X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                    X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                    X3 = X3(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                    sz1 = size(X1);
                    X1 = X1(:); X2 = X2(:); X3(:);

                    % calculate output array size
                    temporary = method(x(X1(1)+rows, X2(1)+cols, X3(1))); szout = size(temporary);
                    result = zeros(numel(X1), numel(temporary));
                    result(1, :) = temporary; clear temporary;

                    parfor i = 2:numel(X1)
                        result(i, :) = method(x(X1(i)+rows, X2(i)+cols, X3(i)));
                    end

                    if szout == [1, 1]
                        result = squeeze(reshape(result, [sz1(1:2), sz(3:end)]));
                    else
                        result = squeeze(reshape(result, [sz1(1:2), sz(3:end), szout]));
                    end
                end
            end
        case 'slice-cross'
            if isvector(x)
                if numel(x) == kernel
                    result = method(x, kwargs.y);
                else
                    rows = 0:(kernel(1)-1);
                    X1 = 1:numel(x); X1 = X1(1:kwargs.strides(1):end);  X1 = X1(:);
                    x = padarray(x(:), floor(kernel(1)/2), kwargs.padval);
                    y = padarray(kwargs.y, floor(kernel(1)/2), kwargs.padval);
                    result = zeros(1, numel(X1));
                    parfor i = 1:numel(X1)
                        temp = method(x(X1(i)+rows), y(X1(i)+rows));
                        result(i) = temp;
                    end
                end
            else
                if ismatrix(x)          
                    sz = size(x);
                
                    rows = 0:(kernel(1)-1);
                    cols = 0:(kernel(2)-1);
                    x = padarray(x(:,:,:), floor(kernel/2), kwargs.padval);
                    y = padarray(kwargs.y, floor(kernel/2), kwargs.padval);
                
                    [X1, X2] = ndgrid(1:sz(1), 1:sz(2));
                    X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                    X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end);
                    sz1 = size(X1);
                    X1 = X1(:); X2 = X2(:);

                    % calculate output array size
                    temporary = method(x(X1(1)+rows, X2(1)+cols), y(X1(1)+rows, X2(1)+cols)); szout = size(temporary);
                    result = zeros(numel(X1), numel(temporary));
                    result(1, :) = temporary; clear temporary;
    
                    parfor i = 2:numel(X1)
                        result(i, :) = method(x(X1(i)+rows, X2(i)+cols), y(X1(i)+rows, X2(i)+cols));
                    end

                    result = squeeze(reshape(result, [sz1, szout]));
                else
            
                    sz = size(x); szy = size(kwargs.y);
                
                    rows = 0:(kernel(1)-1);
                    cols = 0:(kernel(2)-1);
                    x = padarray(x(:,:,:), floor(kernel/2), kwargs.padval);
                    y = padarray(kwargs.y, floor(kernel/2), kwargs.padval);
                
                    [X1, X2, X3] = ndgrid(1:sz(1), 1:sz(2), 1:sz(3));
                    X1 = X1(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                    X2 = X2(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                    X3 = X3(1:kwargs.strides(1):end, 1:kwargs.strides(2):end, :);
                    sz1 = size(X1);
                    X1 = X1(:); X2 = X2(:); X3(:);

                    % calculate output array size
                    if ismatrix(y)
                        temporary = method(x(X1(1)+rows, X2(1)+cols, X3(1)), y(X1(1)+rows, X2(1)+cols));
                    else
                        temporary = method(x(X1(1)+rows, X2(1)+cols, X3(1)), y(X1(1)+rows, X2(1)+cols, X3(1)));
                    end
                    szout = size(temporary);
                    result = zeros(numel(X1), numel(temporary));
                    result(1, :) = temporary; clear temporary;
    
                    if ismatrix(y)
                        parfor i = 2:numel(X1)
                            result(i, :) = method(x(X1(i)+rows, X2(i)+cols, X3(i)), y(X1(i)+rows, X2(i)+cols));
                        end
                    else
                        if sz == szy
                            parfor i = 2:numel(X1)
                                result(i, :) = method(x(X1(i)+rows, X2(i)+cols, X3(i)), y(X1(i)+rows, X2(i)+cols, X3(i)));
                            end
                        end
                    end
                    result = squeeze(reshape(result, [sz1, szout]));
                end
            end
        case 'deep'
            if ~ismatrix(x)
                sz = size(x);
    
                rows = 0:(kernel(1)-1);
                cols = 0:(kernel(2)-1);
                x = padarray(x, floor(kernel/2), kwargs.padval);
            
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
            end
        case 'deep-cross'
            if ~ismatrix(x)
                sz = size(x);
    
                rows = 0:(kernel(1)-1);
                cols = 0:(kernel(2)-1);
                x = padarray(x, floor(kernel/2), kwargs.padval);
                y = padarray(kwargs.y, floor(kernel/2), kwargs.padval);

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