function varargout = nonlinfilt(varargin, kwargs)
    arguments (Repeating)
        varargin double
    end

    arguments
        kwargs.method function_handle
        kwargs.kernel (1,:) {mustBeA(kwargs.kernel, {'double', 'cell'})} = []
        kwargs.stride (1,:) {mustBeA(kwargs.stride, {'double', 'cell'})} = []
        kwargs.offset (1,:) {mustBeA(kwargs.offset, {'double', 'cell'})} = []
        kwargs.padval = nan
    end

    %% build grid

    for i = 1:numel(varargin)
        if isvector(varargin{1})
            varargin{1} = varargin{1}(:);
        end        
        sz(i, :) = size(varargin{1});
    end

    if round(mean(sz, 1)) ~= sz(1, :)
        error('filtering array must have same size')
        return
    end
    sz = sz(1, :);

    % validation kernel, stride, offset type
    if ~((isa(kwargs.kernel, 'double') && isa(kwargs.stride, 'double') && isa(kwargs.offset, 'double')) || ...
            (isa(kwargs.kernel, 'cell') && isa(kwargs.stride, 'cell') && isa(kwargs.offset, 'cell')))
        error('kernel, stride and offset must be same type')
        return;
    end

    % validation kernel
    if isempty(kwargs.kernel)
        kwargs.kernel = sz;
    else
        if isa(kwargs.kernel, 'double')
            for i = 1:numel(varargin)
                if ndims(varargin{i}) < size(kwargs.kernel, 2)
                    error('kernel size isn`t correct: kernel dimension number must not exceed data dimension number')
                    return;
                end
            end
        else
            if numel(varargin) == numel(kwargs.kernel)
                for i = 1:numel(varargin)
                    if ndims(varargin{i}) < size(kwargs.kernel{i}, 2)
                        error('kernel size isn`t correct: kernel dimension number must not exceed data dimension number')
                        return;
                    end
                end
            else
                error('kernel size isn`t correct: number of filter kernel must be equal one or correspond to number of filtering array')
                return;
            end
        end
    end

    % validation stride
    if isempty(kwargs.stride)
        kwargs.stride = ones(size(kwargs.kernel));
    else
        if isa(kwargs.stride, 'double')
            if size(kwargs.kernel, 2) ~= size(kwargs.stride, 2)
                error('kernel and stride dimensions must be equal')
                return;
            end
        else
            if numel(kwargs.kernel) == numel(kwargs.stride)
                for i = 1:numel(kwargs.kernel)
                    if size(kwargs.kernel{i}, 2) ~= size(kwargs.stride{i}, 2)
                        error('kernel and stride dimensions must be equal')
                        return;
                    end
                end
            else
                error('kernel and stride dimensions must be equal')
                return
            end
        end
    end

    % validation offset
    if isempty(kwargs.offset)
        kwargs.offset = zeros(size(kwargs.kernel));
    else
        if isa(kwargs.offset, 'double')
            if size(kwargs.kernel, 2) ~= size(kwargs.offset, 2)
                error('kernel and offset dimensions must be equal')
                return;
            end
        else
            if numel(kwargs.kernel) == numel(kwargs.offset)
                for i = 1:numel(kwargs.kernel)
                    if size(kwargs.kernel{i}, 2) ~= size(kwargs.offset{i}, 2)
                        error('kernel and offset dimensions must be equal')
                        return;
                    end
                end
            else
                error('kernel and offset dimensions must be equal')
                return
            end
        end
    end

    % adjust kernel, stride an offset to data size
    if isa(kwargs.kernel, 'double')
        if ndims(varargin{1}) > size(kwargs.kernel, 2)
            temporary = ones(1, ndims(varargin{1}));
            temporary(1:numel(kwargs.kernel)) = kwargs.kernel;
            kwargs.kernel = temporary;
        
            temporary = ones(1, ndims(varargin{1}));
            temporary(1:numel(kwargs.stride)) = kwargs.stride;
            kwargs.stride = temporary;
        
            temporary = zeros(1, ndims(varargin{1}));
            temporary(1:numel(kwargs.offset)) = kwargs.offset;
            kwargs.offset = temporary;
        end
    else
        for i = 1:numel(varargin)
            if ndims(varargin{i}) > size(kwargs.kernel{i}, 2)
                temporary = ones(1, ndims(varargin{i}));
                temporary(1:numel(kwargs.kernel{i})) = kwargs.kernel{i};
                kwargs.kernel{i} = temporary;
            
                temporary = ones(1, ndims(varargin{i}));
                temporary(1:numel(kwargs.stride{i})) = kwargs.stride{i};
                kwargs.stride{i} = temporary;
            
                temporary = zeros(1, ndims(varargin{i}));
                temporary(1:numel(kwargs.offset{i})) = kwargs.offset{i};
                kwargs.offset{i} = temporary;
            end
        end
    end

    % append permute to choose filtering direction

    % padding
    if isa(kwargs.kernel, 'double')
        for j = 1:numel(varargin)
            varargin{j} = padarray(varargin{j}, floor(kwargs.kernel/2), kwargs.padval);
            for i = 1:size(kwargs.offset, 2)
                if kwargs.offset(i) ~= 0
                    padsize = zeros(1, size(kwargs.offset, 2));
                    padsize(i) = abs(kwargs.offset(i));
                    if kwargs.offset(i) > 0
                        direction = 'post'; 
                    else 
                        direction = 'pre'; 
                    end
                    varargin{j} = padarray(varargin{j}, padsize, kwargs.padval, direction);
                end
            end
        end
        kwargs.offset(kwargs.offset<0) = 0;
    else
        for j = 1:numel(varargin)
            varargin{j} = padarray(varargin{j}, floor(kwargs.kernel{j}/2), kwargs.padval);
            for i = 1:size(kwargs.offset{j}, 2)
                if kwargs.offset{j}(i) ~= 0
                    padsize = zeros(1, size(kwargs.offset{j}, 2));
                    padsize(i) = abs(kwargs.offset{j}(i));
                    if kwargs.offset{j}(i) > 0
                        direction = 'post'; 
                    else 
                        direction = 'pre'; 
                    end
                    varargin{j} = padarray(varargin{j}, padsize, kwargs.padval, direction);
                end
            end
        end
        for i = 1:numel(kwargs.offset)
            temporary = kwargs.offset{i};
            temporary(temporary<0) = 0;
            kwargs.offset{i} = temporary;
        end
    end

    % window intex
    for i = 1:size(kwargs.kernel, 2)
        xr{i} = ndgrid(0:kwargs.kernel(i)-1)+kwargs.offset(i);
    end

    % sliding index
    switch size(kwargs.kernel, 2)
        case 1
            x{1} = ndgrid(1:sz(1));
            x{1} = x{1}(1:kwargs.stride(1):end);
        case 2
            [x{1}, x{2}] = ndgrid(1:sz(1), 1:sz(2));
            x{1} = x{1}(1:kwargs.stride(1):end, 1:kwargs.stride(2):end);
            x{2} = x{2}(1:kwargs.stride(1):end, 1:kwargs.stride(2):end);
        case 3
            [x{1}, x{2}, x{3}] = ndgrid(1:sz(1), 1:sz(2), 1:sz(3));
            x{1} = x{1}(1:kwargs.stride(1):end, 1:kwargs.stride(2):end, 1:kwargs.stride(3):end);
            x{2} = x{2}(1:kwargs.stride(1):end, 1:kwargs.stride(2):end, 1:kwargs.stride(3):end);
            x{3} = x{3}(1:kwargs.stride(1):end, 1:kwargs.stride(2):end, 1:kwargs.stride(3):end);
    end
    sz1 = size(x{1}); nel = numel(x{1});

    %% redefine kernel method

    switch numel(varargin)
        case 1
            % 1D filter of 1D data
            if isvector(varargin{1})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}));
            end
        
            % 2D filter of 2D data
            if ismatrix(varargin{1})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}, x{2}(index)+xr{2}));
            end
        
            % 2D filter of ND data
            if ~ismatrix(varargin{1})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}, x{2}(index)+xr{2}, x{3}(index)+xr{3}));
            end
        case 2
            % 1D filter of 1D data + 1D data 
            if isvector(varargin{1}) && isvector(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}), varargin{2}(x{1}(index)+xr{1}));
            end
        
            % 2D filter of 2D data + 1D data
            if ismatrix(varargin{1}) && ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}, x{2}(index)+xr{2}), ...
                    varargin{2}(x{1}(index)+xr{1}));
            end

            % 2D filter of 2D data + 2D data
            if ismatrix(varargin{1}) && ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}, x{2}(index)+xr{2}), ...
                    varargin{2}(x{1}(index)+xr{1}, x{2}(index)+xr{2}));
            end
        
            % 2D filter of ND data + 2D data
            if ~ismatrix(varargin{1}) && ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}, x{2}(index)+xr{2}, x{3}(index)+xr{3}), ...
                    varargin{2}(x{1}(index)+xr{1}, x{2}(index)+xr{2}));
            end

            % 2D filter of ND data + ND data
            if ~ismatrix(varargin{1}) && ~ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1}(index)+xr{1}, x{2}(index)+xr{2}, x{3}(index)+xr{3}), ...
                    varargin{2}(x{1}(index)+xr{1}, x{2}(index)+xr{2}, x{3}(index)+xr{3}));
            end
    end

    %% filtering

    temporary = method(1); 
    szout = size(temporary);
    mask = [isscalar(temporary), isvector(temporary), ismatrix(temporary)];

    if isscalar(temporary) || isvector(temporary)
        szout = prod(szout);
    end

    result = zeros(numel(x{1}), numel(temporary));
    result(1, :) = temporary(:); 
    

    for i = 2:nel
        result(i, :) = reshape(method(i), [], 1); 
    end

    result = squeeze(reshape(result, [sz1, szout]));

    varargout{1} = result;
end