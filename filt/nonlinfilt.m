function varargout = nonlinfilt(varargin, kwargs)
    %% Sliding window non-linear filter.
    
    %% Filter the single 1D signal by sliding window with length 5 and stride 1.
    % x = rand(1,20);
    % y = testnonlinfilt(x, method = @rms, kernel = 5);

    %% Filter the two 1D signals by sliding window with length 5 and stride 2.
    % x1 = rand(1,20);
    % x2 = rand(1,20);
    % y12 = testnonlinfilt(x1, x2, method = @(x1,x2) rms(x1.*x2), kernel = 5, stride = 2);

    %% Filter the single 1D signal by sliding window with length 5, stride 1 and kernel function with two outputs.
    % x = rand(1,20);
    % y = testnonlinfilt(x, method = @(x) [rms(x), mean(x)], kernel = 5);

    %% Filter the single 2D signal by sliding window with size [5, 2] and strides [1, 2].
    % x = rand(20);
    % y = testnonlinfilt(x, method = @rms, kernel = [5, 2], stride = [1, 2]);

    %% Filter the two 2D signals by sliding window with size [5, 2], strides [1, 2] and kernel function with two outputs.
    % x1 = rand(20);
    % x2 = rand(20,20);
    % y12 = testnonlinfilt(x1, x2, method = @(x1,x2) [rms(x1.*x2), mean(x1.*x2)], kernel = [5, 2], stride = [1, 2]);

    %% Filter the single 3D signal by sliding window with size [5, 2, 1] and strides [1, 1, 1].
    % x = rand(20,20,2);
    % y = testnonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 2]);

    %% Filter the single 3D signal by sliding window with size [5, 2, 2] and strides [1, 1, 2].
    % x = rand(20,20,2);
    % y = testnonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, nan], stride = [1, 1, nan]);

    %% Filter the two 3D signals by sliding windows with sizes [5, 2, 2], [10, 10, 2] and strides [1, 1, 2], [1, 1, 2] for first and second signals consequently.
    % x1 = rand(20,20,2);
    % x2 = rand(20,20,2);
    % y = testnonlinfilt(x1, x2, method = @(x1,x2)rms(x1(:)).*rms(x2(:)), kernel = {[5, 5, nan], [10, 10, nan]}, stride = [1, 1, nan]);

    arguments (Repeating, Input)
        varargin % data
    end

    arguments (Input)
        kwargs.method function_handle %% non-linear kernel function
        kwargs.kernel {mustBeA(kwargs.kernel, {'double', 'cell'})} = [] % window size
        kwargs.stride {mustBeA(kwargs.stride, {'double', 'cell'})} = [] % window stride
        kwargs.offset {mustBeA(kwargs.offset, {'double', 'cell'})} = [] % window offset
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string'})} = nan % padding value
        kwargs.shape (1,:) {mustBeMember(kwargs.shape, {'same', 'valid'})} = 'same' % subsection of the sliding window
        kwargs.verbose (1,1) logical = true % logger
    end

    arguments (Repeating, Output)
        varargout
    end

    timer = tic;
    kernelisvector = false(1, numel(varargin));
    strideisvector = false(1, numel(varargin));
    offsetisvector = false(1, numel(varargin));

    % evaluate size of input data, flat vector data
    sz = cell(1, numel(varargin));
    for i = 1:numel(varargin)
        if isvector(varargin{i}); varargin{i} = varargin{i}(:); end
        sz{i} = size(varargin{i});
    end
    
    % kernel validation
    if isempty(kwargs.kernel); kwargs.kernel = sz; end
    if isa(kwargs.kernel, 'double')
        % kwargs.kernel = int32(kwargs.kernel);
        if isvector(kwargs.kernel)
            kwargs.kernel = repmat({kwargs.kernel}, 1, numel(varargin));
        else
            kwargs.kernel = {kwargs.kernel};
        end
    end
    if numel(varargin) ~= numel(kwargs.kernel); error('number of filter kernel must be equal one or correspond to number of filtering array'); end

    % stride validation
    if isempty(kwargs.stride)
        for i = 1:numel(kwargs.kernel)
            kwargs.stride{i} = ones(size(kwargs.kernel{i}));
        end
    end
    if isa(kwargs.stride, 'double')
        % kwargs.stride = int32(kwargs.stride);
        if isvector(kwargs.stride)
            kwargs.stride = repmat({kwargs.stride}, 1, numel(varargin));
        else
            kwargs.stride = {kwargs.stride};
        end
    end
    if numel(varargin) ~= numel(kwargs.stride); error('kernel and stride dimensions must be equal'); end

    % offset validation
    if isempty(kwargs.offset)
        for i = 1:numel(kwargs.kernel)
            kwargs.offset{i} = zeros(size(kwargs.kernel{i}));
        end
    end
    if isa(kwargs.offset, 'double')
        % kwargs.offset = int32(kwargs.offset);
        if isvector(kwargs.offset)
            kwargs.offset = repmat({kwargs.offset}, 1, numel(varargin));
        else
            kwargs.offset = {kwargs.offset};
        end
    end
    if numel(varargin) ~= numel(kwargs.offset); error('kernel and offset dimensions must be equal'); end

    % adjust filter parameters
    tempfunc = @(x) x*(x > 0);
    for i = 1:numel(varargin)
        if isvector(kwargs.kernel{i})
            kernelisvector(i) = true;
            kwargs.kernel{i} = padarray(kwargs.kernel{i}, [0, tempfunc(ndims(varargin{i})-numel(kwargs.kernel{i}))], 1, 'post');
        end
        if isvector(kwargs.stride{i})
            strideisvector(i) = true;
            kwargs.stride{i} = padarray(kwargs.stride{i}, [0, tempfunc(ndims(varargin{i})-numel(kwargs.stride{i}))], 1, 'post');
        end
        if isvector(kwargs.offset{i})
            offsetisvector(i) = true;
            kwargs.offset{i} = padarray(kwargs.offset{i}, [0, tempfunc(ndims(varargin{i})-numel(kwargs.offset{i}))], 0, 'post');
        end
    end

    % evaluate a size of filtered data
    szf = cell(1, numel(sz));
    for i = 1:numel(sz)
        if isvector(kwargs.stride{i})
            if prod([kernelisvector, strideisvector, offsetisvector]) && kwargs.shape == "valid"
                temporary = floor(kwargs.kernel{i}/2);
                kwargs.offset{i} = temporary;
            end
            for j = 1:numel(sz{i})
                if kwargs.shape == "valid"
                    szf{i}(j) = numel(temporary(j):kwargs.stride{i}(j):sz{i}(j)-temporary(j)-1);
                else
                    szf{i}(j) = numel(1:kwargs.stride{i}(j):sz{i}(j));
                end
            end
            szf{i}(szf{i} == 0) = 1;
        else
            szf{i} = size(kwargs.stride{i}, 1:ndims(kwargs.stride{i})-1);
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

    % repeat vector elements according to size of filtered data 
    for i = 1:numel(varargin)
        if isvector(kwargs.kernel{i})
            kwargs.kernel{i}(isnan(kwargs.kernel{i})) = sz{i}(isnan(kwargs.kernel{i}));
            arg = cat(2, {shiftdim(kwargs.kernel{i}, -numel(kwargs.kernel{i}))}, num2cell(szf));
            kwargs.kernel{i} = repmat(arg{:});
        end
        if isvector(kwargs.stride{i})
            % kwargs.stride{i}(isnan(kwargs.stride{i})) = sz{i}(isnan(kwargs.stride{i}));
            arg = cat(2, {shiftdim(kwargs.stride{i}, -numel(kwargs.stride{i}))}, num2cell(szf));
            kwargs.stride{i} = repmat(arg{:});
        end
        if isvector(kwargs.offset{i})
            arg = cat(2, {shiftdim(kwargs.offset{i}, -numel(kwargs.offset{i}))}, num2cell(szf));
            kwargs.offset{i} = repmat(arg{:});
        end
    end

    % shift dimensition
    for i = 1:numel(varargin)
        kwargs.kernel{i} = shiftdim(kwargs.kernel{i}, ndims(kwargs.kernel{i}) - 1);
        kwargs.stride{i} = shiftdim(kwargs.stride{i}, ndims(kwargs.stride{i}) - 1);
        kwargs.offset{i} = shiftdim(kwargs.offset{i}, ndims(kwargs.offset{i}) - 1);
    end

    % size validation
    for i = 1:numel(varargin)
        if ndims(varargin{i}) < size(kwargs.kernel{i}, 1); error('kernel dimension number must not exceed data dimension number'); end
        if size(kwargs.kernel{i}) ~= size(kwargs.stride{i}); error('kernel and stride dimensions must be equal'); end
        if size(kwargs.kernel{i}) ~= size(kwargs.offset{i}); error('kernel and offset dimensions must be equal'); end
    end

    % cumulate strides
    for i = 1:numel(varargin)
        if strideisvector(i)
            for j = 1:size(kwargs.stride{i}, 1)
                kwargs.stride{i}(j,:) = reshape(cumsum(reshape(kwargs.stride{i}(j,:), szf), j), [], 1)-kwargs.stride{i}(j,1)+1;
            end
        else
            for j = 1:size(kwargs.stride{i}, 1)
                kwargs.stride{i}(j,:) = reshape(cumsum(reshape(kwargs.stride{i}(j,:), szf), j), [], 1);
            end
        end
    end

    % evaluate outbound index slices
    outboundind = cell(1, numel(varargin));
    nel = prod(szf);
    for k = 1:nel
        for i = 1:numel(sz)
            kernel = kwargs.kernel{i}(:,k);
            stride = kwargs.stride{i}(:,k);
            offset = kwargs.offset{i}(:,k);

            temporary = cell(1, numel(sz{i}));
            for j = 1:numel(sz{i})
                temporary{j} = stride(j) + (-floor((kernel(j)-1)/2):floor(kernel(j)/2)) + offset(j);
                [minval, maxval] = bounds(temporary{j});
                outboundind{i}(k,j,:) = [minval, maxval];
            end
        end
    end
 
    % evaluate paddings
    for i = 1:numel(outboundind)
        [minval, maxval] = bounds(outboundind{i}, [1, 3]);
        outboundind{i} = cat(1, squeeze(minval), squeeze(maxval))';

        for j = 1:size(outboundind{i}, 1)
            if outboundind{i}(j, 1) <= 0
                outboundind{i}(j, 1) = abs(outboundind{i}(j, 1)) + 1;
            else
                outboundind{i}(j, 1) = 0;
            end

            if outboundind{i}(j, 2) > sz{i}(j)
                outboundind{i}(j, 2) = outboundind{i}(j, 2) - sz{i}(j);
            else
                outboundind{i}(j, 2) = 0;
            end
        end
    end

    % correct origin indexes
    for i = 1:numel(varargin)
        kwargs.stride{i} = kwargs.stride{i} + kwargs.offset{i} + outboundind{i}(:,1);
    end

    % full index slice along axis
    for i = 1:numel(varargin)
        if strideisvector(i)
            kwargs.stride{i}(isnan(kwargs.stride{i})) = floor((kwargs.kernel{i}(isnan(kwargs.stride{i}))+1)/2);
        end
    end

    % padding of input data
    for i = 1:numel(varargin)
        for j = 1:size(outboundind{i}, 1)
            padsize = zeros(1, size(outboundind{i}, 1));
            padsize(j) = outboundind{i}(j,1);
            varargin{i} = padarray(varargin{i}, padsize, kwargs.padval, 'pre');

            padsize = zeros(1, size(outboundind{i}, 1));
            padsize(j) = outboundind{i}(j,2);
            varargin{i} = padarray(varargin{i}, padsize, kwargs.padval, 'post');
        end
    end

    % evaluate non-linear kernel function result
    k = 1;
    dataslice = cell(1, numel(sz));
    for i = 1:numel(sz)
        kernel = kwargs.kernel{i}(:,k);
        stride = kwargs.stride{i}(:,k);
        
        temporary = cell(1, numel(sz{i}));
        for j = 1:numel(sz{i})
            temporary{j} = stride(j) + (-floor((kernel(j)-1)/2):floor(kernel(j)/2));
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
            kernel = kwargs.kernel{i}(:,k);
            stride = kwargs.stride{i}(:,k);

            temporary = cell(1, numel(sz{i}));
            for j = 1:numel(sz{i})
                temporary{j} = stride(j) + (-floor((kernel(j)-1)/2):floor(kernel(j)/2));
            end

            dataslice{i} = varargin{i}(temporary{:});
        end
        result(k, :) = reshape(kwargs.method(dataslice{:}), [], 1); 
    end

    result = squeeze(reshape(result, [szf, szout]));

    if kwargs.verbose; disp(strcat("nonlinfilt: elapsed time is ", num2str(toc(timer)), " seconds")); end

    varargout{1} = result;

end