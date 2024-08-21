function varargout = nonlinfilt(varargin, kwargs)
    %% Filter data by multi dimensional sliding window and multi argument nonlinear kernel.
    % `varargin` is a positional argument corresponding to the data.
    %
    % `kernel` takes vector or multidimensional matrix that elements correspond to a sliding 
    % window size along each dimension of passed data. At multidimensional matrix notation the 
    % first N dimensions correspond to size filtered data and last N+1 dimension equals to the 
    % count of passed data dimensions. At vector notation there are two configuration: 
    % `kernel=[k1, ..., 0, ... kn]` means to disable padding data along according dimension by `0` 
    % position and slice data occur according to by specified `stride`; 
    % `kernel=[k1, ..., nan, ... kn]` means the total slice data by dimension with `nan` position. 
    % 
    % `stride` takes vector or multidimensional matrix that elements correspond to a 
    % sliding window stride along each dimension of passed data. Notations are similar to `kernel`. 
    % Specifying `stride=[s1, ..., nan, ... sn]` means middle slicing data by dimension with `nan` position. 
    % In case `kernel(i)=nan` and `stride(i)=nan` total slicing data along i-dimension without padding is occured.
    % 
    % `offset` takes vector or multidimensional matrix that elements correspond to a 
    % sliding window offset along each dimension of passed data. Notations
    % are similar to `kernel`. Default is zero vector.
    %
    % `shape` correspond to two filtering mode: `shape='same'` size of filtered data
    % is equal to passed data, ie sliding window crosses over data boundary; 
    % `shape='valid' sliding window moves inside data boundary, ie without padding.

    %% Examples:

    %% Filter the single 1D signal by sliding window with length 5 and stride 1.
    % x = rand(1,20);
    % y = nonlinfilt(x, method = @rms, kernel = 5);

    %% Filter the two 1D signals by sliding window with length 5 and stride 2.
    % x1 = rand(1,20);
    % x2 = rand(1,20);
    % y12 = nonlinfilt(x1, x2, method = @(x1,x2) rms(x1.*x2), kernel = 5, stride = 2);

    %% Filter the single 1D signal by sliding window with length 5, stride 1 and kernel function with two outputs.
    % x = rand(1,20);
    % y = nonlinfilt(x, method = @(x) [rms(x), mean(x)], kernel = 5);

    %% Filter the single 2D signal by sliding window with size [5, 2] and strides [1, 2].
    % x = rand(20);
    % y = nonlinfilt(x, method = @rms, kernel = [5, 2], stride = [1, 2]);

    %% Filter the two 2D signals by sliding window with size [5, 2], strides [1, 2] and kernel function with two outputs.
    % x1 = rand(20);
    % x2 = rand(20,20);
    % y12 = nonlinfilt(x1, x2, method = @(x1,x2) [rms(x1.*x2), mean(x1.*x2)], kernel = [5, 2], stride = [1, 2]);

    %% Filter the single 3D signal by sliding window with size [5, 2, 1] and strides [1, 1, 1].
    % x = rand(20,20,2);
    % y = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 2]);

    %% Filter the single 3D signal by sliding window with size [5, 2, 2] and strides [1, 1, 2].
    % x = rand(20,20,2);
    % y = nonlinfilt(x, method = @(x)rms(x(:)), kernel = [5, 5, nan], stride = [1, 1, nan]);

    %% Filter the two 3D signals by sliding window with sizes [5, 2, 2], [10, 10, 2] and strides [1, 1, 2], [1, 1, 2] for first and second signals consequently.
    % x1 = rand(20,20,2);
    % x2 = rand(20,20,2);
    % y = nonlinfilt(x1, x2, method = @(x1,x2)rms(x1(:)).*rms(x2(:)), kernel = {[5, 5, nan], [10, 10, nan]}, stride = [1, 1, nan]);

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
        kwargs.verbose (1,1) logical = false % logger
        kwargs.cast (1,:) char {mustBeMember(kwargs.cast, {'int8', 'int16', 'int32', 'int64'})} = 'int16'
        kwargs.filtpass (1,1) logical = false;
    end

    arguments (Repeating, Output)
        varargout
    end

    timer = tic;
    strideisvector = false(1, nargin);
    kernelisnan = cell(1, nargin);
    strideisnan = cell(1, nargin);

    % evaluate size of input data, flat vector data
    sz = cell(1, nargin);
    for i = 1:nargin
        if isvector(varargin{i}); varargin{i} = varargin{i}(:); end
        sz{i} = size(varargin{i});
    end
    
    % kernel validation
    if isempty(kwargs.kernel); kwargs.kernel = sz; end
    if isa(kwargs.kernel, 'double')
        if isvector(kwargs.kernel)
            kwargs.kernel = repmat({kwargs.kernel}, 1, nargin);
        else
            kwargs.kernel = {kwargs.kernel};
        end
    end
    if nargin ~= numel(kwargs.kernel); error('number of filter kernel must be equal one or correspond to number of filtering array'); end
    for i = 1:nargin; if isvector(kwargs.kernel{i}); kernelisnan{i} = isnan(kwargs.kernel{i}); end; end
    for i = 1:nargin; kwargs.kernel{i} = cast(kwargs.kernel{i}, kwargs.cast); end

    % stride validation
    if isempty(kwargs.stride)
        for i = 1:nargin
            kwargs.stride{i} = ones(size(kwargs.kernel{i}));
        end
    end
    if isa(kwargs.stride, 'double')
        if isvector(kwargs.stride)
            kwargs.stride = repmat({kwargs.stride}, 1, nargin);
        else
            kwargs.stride = {kwargs.stride};
        end
    end
    if nargin ~= numel(kwargs.stride); error('kernel and stride dimensions must be equal'); end
    for i = 1:nargin; if isvector(kwargs.stride{i}); strideisnan{i} = isnan(kwargs.stride{i}); end; end
    for i = 1:nargin; kwargs.stride{i} = cast(kwargs.stride{i}, kwargs.cast); end

    % offset validation
    if isempty(kwargs.offset)
        for i = 1:nargin
            kwargs.offset{i} = zeros(size(kwargs.kernel{i}));
        end
    end
    if isa(kwargs.offset, 'double')
        if isvector(kwargs.offset)
            kwargs.offset = repmat({kwargs.offset}, 1, nargin);
        else
            kwargs.offset = {kwargs.offset};
        end
    end
    if nargin ~= numel(kwargs.offset); error('kernel and offset dimensions must be equal'); end
    for i = 1:nargin; kwargs.offset{i} = cast(kwargs.offset{i}, kwargs.cast); end

    % adjust filter parameters
    tempfunc = @(x) x*(x > 0);
    for i = 1:nargin
        if isvector(kwargs.kernel{i})
            kwargs.kernel{i} = padarray(kwargs.kernel{i}, [0, tempfunc(ndims(varargin{i})-numel(kwargs.kernel{i}))], 0, 'post');
        end
        if isvector(kwargs.stride{i})
            strideisvector(i) = true;
            kwargs.stride{i} = padarray(kwargs.stride{i}, [0, tempfunc(ndims(varargin{i})-numel(kwargs.stride{i}))], 1, 'post');
        end
        if isvector(kwargs.offset{i})
            kwargs.offset{i} = padarray(kwargs.offset{i}, [0, tempfunc(ndims(varargin{i})-numel(kwargs.offset{i}))], 0, 'post');
        end
    end

    % evaluate a size of filtered data
    szf = cell(1, nargin);
    for i = 1:nargin
        if isvector(kwargs.stride{i})
            for j = 1:numel(sz{i})
                if isvector(kwargs.kernel{i}) && kwargs.shape == "valid"
                    temp = kwargs.kernel{i}(j);
                    if temp ~= 0; temp = temp - 1; end
                    szf{i}(j) = numel(1:kwargs.stride{i}(j):sz{i}(j)-temp);
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
    for i = 1:nargin
        if isvector(kwargs.kernel{i})
            arg = cat(2, {shiftdim(kwargs.kernel{i}, -numel(kwargs.kernel{i}))}, num2cell(szf));
            kwargs.kernel{i} = repmat(arg{:});
        end
        if isvector(kwargs.stride{i})
            arg = cat(2, {shiftdim(kwargs.stride{i}, -numel(kwargs.stride{i}))}, num2cell(szf));
            kwargs.stride{i} = repmat(arg{:});
        end
        if isvector(kwargs.offset{i})
            arg = cat(2, {shiftdim(kwargs.offset{i}, -numel(kwargs.offset{i}))}, num2cell(szf));
            kwargs.offset{i} = repmat(arg{:});
        end
    end

    % shift dimensition
    for i = 1:nargin
        kwargs.kernel{i} = shiftdim(kwargs.kernel{i}, ndims(kwargs.kernel{i})-1);
        kwargs.stride{i} = shiftdim(kwargs.stride{i}, ndims(kwargs.stride{i})-1);
        kwargs.offset{i} = shiftdim(kwargs.offset{i}, ndims(kwargs.offset{i})-1);
    end

    % size validation
    for i = 1:nargin
        if ndims(varargin{i}) < size(kwargs.kernel{i}, 1); error('kernel dimension number must not exceed data dimension number'); end
        if size(kwargs.kernel{i}) ~= size(kwargs.stride{i}); error('kernel and stride dimensions must be equal'); end
        if size(kwargs.kernel{i}) ~= size(kwargs.offset{i}); error('kernel and offset dimensions must be equal'); end
    end

    % cumulate strides
    for i = 1:nargin
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

    for i = 1:nargin
        if ~isempty(kernelisnan{i}); kwargs.kernel{i}(kernelisnan{i},:) = sz{i}(kernelisnan{i}); end
        if ~isempty(strideisnan{i})
            temp = mod(sz{i}(strideisnan{i}), 2);
            if temp ~= 0; temp = 1; end
            kwargs.stride{i}(strideisnan{i},:) = fix(sz{i}(strideisnan{i})/2) + temp;
            if kwargs.shape == "valid"
                temp = fix(kwargs.kernel{i}/2);
                temp(temp~=0) = temp(temp~=0) - 1;
                kwargs.stride{i}(strideisnan{i},:) = kwargs.stride{i}(strideisnan{i},:) - temp(strideisnan{i},:);
            end
        end
    end

    % shift stride by half kernel
    if kwargs.shape == "same"
        for i = 1:nargin
            temp = fix(kwargs.kernel{i}/2);
            temp(temp~=0) = temp(temp~=0) - 1;
            kwargs.stride{i} = kwargs.stride{i} - temp;
        end
    end

    % substract unit from kernel
    for i = 1:nargin
        kwargs.kernel{i} = kwargs.kernel{i} - 1;
        kwargs.kernel{i}(kwargs.kernel{i}<0) = 0;
    end

    % evaluate outbound index slices
    outboundind = cell(1, nargin);
    for i = 1:nargin
        [minval, maxval] = bounds(reshape(cat(ndims(kwargs.kernel{i})+1, zeros(size(kwargs.kernel{i}),kwargs.cast), ...
            kwargs.kernel{i})+kwargs.stride{i}+kwargs.offset{i}, [numel(sz{i}), prod(szf), 2]), [2, 3]);
        outboundind{i} = [minval, maxval];

        % evaluate paddings
        for j = 1:size(outboundind{i}, 1)
            if outboundind{i}(j, 1) < 1
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

    % shift origin indexes according to padding
    for i = 1:nargin
        kwargs.stride{i} = kwargs.stride{i} + kwargs.offset{i} + outboundind{i}(:,1);
        kwargs.offset{i} = [];
    end

    % evaluate filter passing
    if kwargs.filtpass
        masks = cell(1, nargin);
        for i = 1:nargin; masks{i} = zeros(sz{i}, kwargs.cast); end
    end

    % padding of input data
    for i = 1:nargin
        for j = 1:size(outboundind{i}, 1)
            padsize = zeros(1, size(outboundind{i}, 1));
            padsize(j) = outboundind{i}(j,1);
            varargin{i} = padarray(varargin{i}, padsize, kwargs.padval, 'pre');

            if kwargs.filtpass; masks{i} = padarray(masks{i}, padsize, 1, 'pre'); end

            padsize = zeros(1, size(outboundind{i}, 1));
            padsize(j) = outboundind{i}(j,2);
            varargin{i} = padarray(varargin{i}, padsize, kwargs.padval, 'post');
   
            if kwargs.filtpass; masks{i} = padarray(masks{i}, padsize, 1, 'post'); end
        end
    end

    filtpass = cell(1, nargin);

    % evaluate non-linear kernel function result
    k = 1;
    dataslice = cell(1, numel(sz));
    for i = 1:numel(sz)
        kernel = kwargs.kernel{i}(:,k);
        stride = kwargs.stride{i}(:,k);
        
        temporary = cell(1, numel(sz{i}));
        for j = 1:numel(sz{i})
            temporary{j} = stride(j) + (0:kernel(j));
        end
        dataslice{i} = varargin{i}(temporary{:});

        if kwargs.filtpass
            tempfunc = masks{i};
            tempfunc(temporary{:}) = 3;
            filtpass{i}(1,:) = tempfunc(:);
        end
    end
    
    temporary = kwargs.method(dataslice{:});

    szout = size(temporary);
    if isscalar(temporary) || isvector(temporary)
        szout = prod(szout);
    end

    result = zeros(prod(szf), numel(temporary));
    result(1, :) = temporary(:); 
    
    if kwargs.filtpass
        for i = 1:numel(filtpass)
            tempfunc = filtpass{i};
            filtpass{i} = zeros(prod(szf), numel(tempfunc), kwargs.cast);
            filtpass{i}(1,:) = tempfunc;
        end
    end

    % main loop
    nel = size(result, 1);
    parfor k = 2:nel
        dataslice = cell(1, numel(sz));
        for i = 1:numel(sz)   
            kernel = kwargs.kernel{i}(:,k);
            stride = kwargs.stride{i}(:,k);

            temporary = cell(1, numel(sz{i}));
            for j = 1:numel(sz{i})
                temporary{j} = stride(j) + (0:kernel(j));
            end
            dataslice{i} = varargin{i}(temporary{:});

            % uncomment to debug
            % if kwargs.filtpass
            %     tempfunc = masks{i};
            %     tempfunc(temporary{:}) = 3;
            %     filtpass{1}(k,:) = tempfunc(:);
            % end
        end
        result(k, :) = reshape(kwargs.method(dataslice{:}), [], 1); 
    end

    result = squeeze(reshape(result, [szf, szout]));

    if kwargs.verbose; disp(strcat("nonlinfilt: elapsed time is ", num2str(toc(timer)), " seconds")); end

    varargout{1} = result;

    if kwargs.filtpass
        for i = 1:numel(filtpass)
            filtpass{i} = squeeze(reshape(filtpass{i}, [nel, size(masks{i})]));
            filtpass{i} = permute(filtpass{i}, [2:ndims(filtpass{i}), 1]);
        end
        varargout{2} = filtpass; 
    end

end