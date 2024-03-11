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
        if isvector(varargin{i})
            varargin{i} = varargin{i}(:);
        end        
        sz{i} = size(varargin{i});
    end

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
            kernel = kwargs.kernel;
            kwargs.kernel = cell(1, numel(varargin));
            for i = 1:numel(varargin)
                kwargs.kernel{i} = kernel;
            end
            for i = 1:numel(varargin)
                if ndims(varargin{i}) < size(kwargs.kernel{i}, 2)
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
        for i = 1:numel(kwargs.kernel)
            kwargs.stride{i} = ones(size(kwargs.kernel{i}));
        end
    else
        if isa(kwargs.stride, 'double')
            stride = kwargs.stride;
            kwargs.stride = cell(1, numel(varargin));
            for i = 1:numel(varargin)
                kwargs.stride{i} = stride;
            end
            for i = 1:numel(kwargs.kernel)
                if size(kwargs.kernel{i}, 2) ~= size(kwargs.stride{i}, 2)
                    error('kernel and stride dimensions must be equal')
                    return;
                end
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
        for i = 1:numel(kwargs.kernel)
            kwargs.offset{i} = zeros(size(kwargs.kernel{i}));
        end
    else
        if isa(kwargs.offset, 'double')
            offset = kwargs.offset;
            kwargs.offset = cell(1, numel(varargin));
            for i = 1:numel(varargin)
                kwargs.offset{i} = offset;
            end
            for i = 1:numel(kwargs.kernel)
                if size(kwargs.kernel{i}, 2) ~= size(kwargs.offset{i}, 2)
                    error('kernel and offset dimensions must be equal')
                    return;
                end
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

    % todo: append permute to choose filtering direction

    % padding
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

    % window intex
    for i = 1:numel(kwargs.kernel)
        for j = 1:size(kwargs.kernel{i}, 2)
            xr{i, j} = ndgrid(0:kwargs.kernel{i}(j)-1)+kwargs.offset{i}(j);
        end
    end

    % sliding index
    maxel = zeros(1, numel(sz));
    for i = 1:numel(sz)
        maxel(i) = size(sz{i}, 2);
    end
    x = cell(numel(kwargs.kernel), max(maxel(:)));
    for i = 1:numel(kwargs.kernel)
        switch size(kwargs.kernel{i}, 2)
            case 1
                x{i, 1} = ndgrid(1:sz{i}(1));
                x{i, 1} = x{1}(1:kwargs.stride{i}(1):end);
            case 2
                [x{i, 1}, x{i, 2}] = ndgrid(1:sz{i}(1), 1:sz{i}(2));
                x{i, 1} = x{i, 1}(1:kwargs.stride{i}(1):end, 1:kwargs.stride{i}(2):end);
                x{i, 2} = x{i, 2}(1:kwargs.stride{i}(1):end, 1:kwargs.stride{i}(2):end);
            case 3
                [x{i, 1}, x{i, 2}, x{i, 3}] = ndgrid(1:sz{i}(1), 1:sz{i}(2), 1:sz{i}(3));
                x{i, 1} = x{i, 1}(1:kwargs.stride{i}(1):end, 1:kwargs.stride{i}(2):end, 1:kwargs.stride{i}(3):end);
                x{i, 2} = x{i, 2}(1:kwargs.stride{i}(1):end, 1:kwargs.stride{i}(2):end, 1:kwargs.stride{i}(3):end);
                x{i, 3} = x{i, 3}(1:kwargs.stride{i}(1):end, 1:kwargs.stride{i}(2):end, 1:kwargs.stride{i}(3):end);
        end
        sz1{i} = size(x{i, 1}); nel{i} = numel(x{i, 1});
    end

    %% redefine kernel method

    maskbool = @(x) [isscalar(x), isvector(x), ismatrix(x)];

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
            mask = [maskbool(varargin{1}); maskbool(varargin{2})];

            % 1D filter of 1D data + 1D data 
            if isvector(varargin{1}) && ~ismatrix(varargin{1}) && isvector(varargin{2}) && ~ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1, 1}(index)+xr{1, 1}), varargin{2}(x{2, 1}(index)+xr{2, 1}));
            end
        
            % 2D filter of 2D data + 1D data
            if ismatrix(varargin{1}) && ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1, 1}(index)+xr{1, 1}, x{1, 2}(index)+xr{1, 2}), ...
                    varargin{2}(x{2, 1}(index)+xr{2, 1}));
            end

            % 2D filter of 2D data + 2D data
            if ismatrix(varargin{1}) && ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1, 1}(index)+xr{1, 1}, x{1, 2}(index)+xr{1, 2}), ...
                    varargin{2}(x{2, 1}(index)+xr{2, 1}, x{2, 2}(index)+xr{2, 2}));
            end
        
            % 2D filter of ND data + 2D data
            if ~ismatrix(varargin{1}) && ismatrix(varargin{2})
                method = @(index) kwargs.method(varargin{1}(x{1, 1}(index)+xr{1, 1}, x{1, 2}(index)+xr{1, 2}, x{1, 3}(index)+xr{1, 3}), ...
                    varargin{2}(x{2, 1}(index)+xr{2, 1}, x{2, 2}(index)+xr{2, 2}));
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

    result = zeros(numel(x{1, 1}), numel(temporary));
    result(1, :) = temporary(:); 
    

    for i = 2:nel{1}
        result(i, :) = reshape(method(i), [], 1); 
    end

    result = squeeze(reshape(result, [sz1{1}, szout]));

    varargout{1} = result;
end