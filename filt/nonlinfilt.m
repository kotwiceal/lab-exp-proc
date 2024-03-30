function varargout = nonlinfilt(varargin, kwargs)
    arguments (Repeating)
        varargin double
    end

    arguments
        kwargs.method function_handle
        kwargs.kernel (1,:) {mustBeA(kwargs.kernel, {'double', 'cell'})} = []
        kwargs.stride (1,:) {mustBeA(kwargs.stride, {'double', 'cell'})} = []
        kwargs.offset (1,:) {mustBeA(kwargs.offset, {'double', 'cell'})} = []
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string'})} = nan
    end

    sz = cell(1, numel(varargin));
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

    % window index
    xr = cell(1, numel(kwargs.kernel));
    for i = 1:numel(kwargs.kernel)
        temporary = cell(1, numel(kwargs.kernel{i}));
        for j = 1:size(kwargs.kernel{i}, 2)
            temporary{j} = ndgrid(0:kwargs.kernel{i}(j)-1)+kwargs.offset{i}(j);
        end
        xr{i} = temporary;
    end

    % subscript index
    x = cell(1, numel(sz));
    sz1 = cell(1, numel(sz));
    for i = 1:numel(sz)
        temporary = cell(1, numel(sz{i}));
        for j = 1:numel(sz{i})
            sz1{i}(j) = numel(1:kwargs.stride{i}(j):sz{i}(j));
            temporary{j} = 1:kwargs.stride{i}(j):sz{i}(j);
        end
        [temporary{:}] = ndgrid(temporary{:});
        x{i} = temporary;
    end
        
    % evaluate non-linear kernel function result
    ind = 1;
    dataslice = cell(1, numel(sz));
    for i = 1:numel(sz)
        temporary = cell(1, numel(sz{i}));
        for j = 1:numel(sz{i})
            temporary{j} = x{i}{j}(ind) + xr{i}{j};
        end
        dataslice{i} = varargin{i}(temporary{:});
    end
    
    temporary = kwargs.method(dataslice{:});

    szout = size(temporary);
    if isscalar(temporary) || isvector(temporary)
        szout = prod(szout);
    end

    result = zeros(numel(x{1}{1}), numel(temporary));
    result(1, :) = temporary(:); 
    
    % main loop
    nel = size(result, 1);
    parfor k = 2:nel
        dataslice = cell(1, numel(sz));
        for i = 1:numel(sz)
            temp = cell(1, numel(sz{i}));
            for j = 1:numel(sz{i})
                temp{j} = x{i}{j}(k) + xr{i}{j};
            end
            dataslice{i} = varargin{i}(temp{:});
        end
        result(k, :) = reshape(kwargs.method(dataslice{:}), [], 1); 
    end

    result = squeeze(reshape(result, [sz1{1}, szout]));

    varargout{1} = result;
end