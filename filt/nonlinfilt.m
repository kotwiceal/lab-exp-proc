function varargout = nonlinfilt(varargin, kwargs)
    %% Sliding window non-linear filter

    arguments (Repeating)
        varargin double % data
    end

    arguments
        kwargs.method function_handle % non-linear kernel function
        kwargs.kernel (1,:) {mustBeA(kwargs.kernel, {'double', 'cell'})} = [] % window size
        kwargs.stride (1,:) {mustBeA(kwargs.stride, {'double', 'cell'})} = [] % window stride
        kwargs.offset (1,:) {mustBeA(kwargs.offset, {'double', 'cell'})} = [] % window offset
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string'})} = nan % padding value
        kwargs.verbose (1,1) logical = true % logger
    end

    sz = cell(1, numel(varargin));
    for i = 1:numel(varargin)
        % flat vector data
        if isvector(varargin{i})
            varargin{i} = varargin{i}(:); 
            sz{i} = numel(varargin{i});
        else
            sz{i} = size(varargin{i});
        end        
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

    timer = tic;

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

    % evaluate a size of filtered data
    szf = cell(1, numel(sz));
    for i = 1:numel(sz)
        if isvector(kwargs.stride{i})
            for j = 1:numel(sz{i})
                szf{i}(j) = numel(1:kwargs.stride{i}(j):sz{i}(j));
            end
        else
            szf{i} = size(kwargs.stride{i}, ndims(kwargs.stride{i}));
        end
    end
    
    % check a consistency of filtered data size
    szfnumel = zeros(1, numel(szf));
    for i = 1:numel(szf); szfnumel(i) = numel(szf{i}); end
    if numel(unique(szfnumel)) ~= 1; error(strcat("inconsistent dimensions of filter strides: ", jsonencode(szfnumel))); end
    szfval = zeros(numel(szf), szfnumel(1));
    for i = 1:numel(szf); szfval(i,:) = szf{i}; end
    if ~isvector(unique(szfval, 'row')); error(strcat("inconsistent grid of filter strides: ", jsonencode(szfval))); end
    szf = szf{1};

    % padding
    for j = 1:numel(varargin)
        % avoid over padding at filtering with total slice along specified dimensionals
        mask = sz{j} == kwargs.kernel{j} & sz{j} == kwargs.stride{j};
        padsize = floor(kwargs.kernel{j}/2); padsize(mask) = 0;
        
        varargin{j} = padarray(varargin{j}, padsize, kwargs.padval);
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
        
    % evaluate non-linear kernel function result
    ind = 1;
    dataslice = cell(1, numel(sz));
    for i = 1:numel(sz)
        subind = cell(1, numel(szf) + 1); subind{numel(szf) + 1} = 1:numel(szf);
        [subind{1:end-1}] = ind2sub(szf, ind);

        kernel = kwargs.kernel{i};
        stride = kwargs.stride{i};
        offset = kwargs.offset{i};

        temporary = cell(1, numel(sz{i}));
        for j = 1:numel(sz{i})
            temporary{j} = stride(j)*(subind{j}-1)+1 + (0:kernel(j)-1) + offset(j);
        end
        dataslice{i} = varargin{i}(temporary{:});
    end
    
    temporary = kwargs.method(dataslice{:});

    szout = size(temporary);
    if isscalar(temporary) || isvector(temporary)
        szout = prod(szout);
    end

    result = zeros(prod(szf), numel(temporary));
    result(1, :) = temporary(:); 
    
    % main loop
    nel = size(result, 1);
    parfor k = 2:nel
        dataslice = cell(1, numel(sz));
        for i = 1:numel(sz)
            subind = cell(1, numel(szf) + 1); subind{numel(szf) + 1} = 1:numel(szf);
            [subind{1:end-1}] = ind2sub(szf, k);
    
            kernel = kwargs.kernel{i};
            stride = kwargs.stride{i};
            offset = kwargs.offset{i};

            temporary = cell(1, numel(sz{i}));
            for j = 1:numel(sz{i})
                temporary{j} = stride(j)*(subind{j}-1)+1 + (0:kernel(j)-1) + offset(j);
            end
            dataslice{i} = varargin{i}(temporary{:});
        end
        result(k, :) = reshape(kwargs.method(dataslice{:}), [], 1); 
    end

    result = squeeze(reshape(result, [szf, szout]));

    if kwargs.verbose; disp(strcat("nonlinfilt: elapsed time is ", num2str(toc(timer)), " seconds")); end

    varargout{1} = result;
end