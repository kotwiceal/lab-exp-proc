function varargout = nonlinfiltdev(varargin, kwargs)
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
        if isvector(varargin{i}); varargin{i} = varargin{i}(:); end        
        sz{i} = size(varargin{i});
    end

    timer = tic;

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
        if isvector(kwargs.kernel{i}) && isvector(kwargs.stride{i}) && isvector(kwargs.offset{i})
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
    end
    for i = 1:numel(kwargs.offset)
        temporary = kwargs.offset{i};
        temporary(temporary<0) = 0;
        kwargs.offset{i} = temporary;
    end
        
    % convert cell to ndarray
    for i = 1:numel(sz)
        if isvector(kwargs.kernel{i}); kwargs.kernel{i} = repmat(shiftdim(kwargs.kernel{i}, 1 - numel(szf)), szf); end
        if isvector(kwargs.stride{i}); kwargs.stride{i} = repmat(shiftdim(kwargs.stride{i}, 1 - numel(szf)), szf); end
        if isvector(kwargs.offset{i}); kwargs.offset{i} = repmat(shiftdim(kwargs.offset{i}, 1 - numel(szf)), szf); end
    end  

    % evaluate non-linear kernel function result
    ind = 1;
    dataslice = cell(1, numel(sz));
    for i = 1:numel(sz)

        subind = cell(1, numel(szf) + 1); subind{numel(szf) + 1} = 1:numel(szf);
        [subind{1:end-1}] = ind2sub(szf, ind);

        kernel = kwargs.kernel{i}(subind{:});
        stride = kwargs.stride{i}(subind{:});
        offset = kwargs.offset{i}(subind{:});

        temporary = cell(1, numel(sz{i}));
        for j = 1:numel(sz{i})
            temporary{j} = stride(j)*(subind{j}-1)+1 + (0:kernel(j)) + offset(j) - floor(kernel(j)/2);
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
    for k = 2:nel
        dataslice = cell(1, numel(sz));
        for i = 1:numel(sz)

            subind = cell(1, numel(szf) + 1); subind{numel(szf) + 1} = 1:numel(szf);
            [subind{1:end-1}] = ind2sub(szf, k);
    
            kernel = kwargs.kernel{i}(subind{:});
            stride = kwargs.stride{i}(subind{:});
            offset = kwargs.offset{i}(subind{:});

            temporary = cell(1, numel(sz{i}));
            for j = 1:numel(sz{i})
                temporary{j} = stride(j)*(subind{j}-1)+1 + (0:kernel(j)) + offset(j);
            end
            dataslice{i} = varargin{i}(temporary{:});
        end
        result(k, :) = reshape(kwargs.method(dataslice{:}), [], 1); 
    end

    result = squeeze(reshape(result, [szf, szout]));

    if kwargs.verbose; disp(strcat("nonlinfilt: elapsed time is ", num2str(toc(timer)), " seconds")); end

    varargout{1} = result;
end