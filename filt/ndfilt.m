function data = ndfilt(data, kwargs, opts)
    %% Advance multi-dimensional data filtering.

    arguments (Input)
        data
        kwargs.filtdims (1,:) double = 1
        kwargs.filtdimsdef {mustBeMember(kwargs.filtdimsdef, {'manual', '1d', '2d'})} = 'manual'
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'fillmiss'})} = 'gaussian'
        kwargs.filtker double = 3 % kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'nearest' % at specifying `filtker=fillmiss`
        kwargs.zero2nan (1,1) logical = true
        kwargs.verbose (1,1) logical = false
        kwargs.mediancondvars (1,2) double = [1, 1]
        opts.usefiledatastore (1, 1) logical = false
        opts.useparallel (1,1) logical = false
        opts.extract {mustBeMember(opts.extract, {'readall', 'writeall'})} = 'readall'
        opts.poolsize (1,:) double = 16
        opts.resources {mustBeA(opts.resources, {'char', 'string', 'cell'}), mustBeMember(opts.resources, {'Processes', 'Threads'})} = 'Threads'
    end

    arguments (Output)
        data
    end

    if isa(kwargs.padval, 'char'); kwargs.padval = string(kwargs.padval); end
    if isscalar(kwargs.padval); kwargs.padval = repmat({kwargs.padval}, 1, numel(kwargs.filtdims)); end

    kernel = nan(1, ndims(data));
    padval = num2cell(nan(1, ndims(data)));

    kernel(kwargs.filtdims) = kwargs.filtker(1:numel(kwargs.filtdims));
    padval(kwargs.filtdims) = kwargs.padval;

    switch kwargs.filt
        case 'median'
            kerfunc = @(x, ~) squeeze(median(x, kwargs.filtdims), 'omitmissing');
        case 'fillmiss'
            if kwargs.method ~= "none"
                if kwargs.zero2nan; data(data==0) = nan; end
                switch numel(kwargs.filtdims)
                    case 1
                        kerfunc = @(x, ~) fillmissing1(squeeze(x), kwargs.method);
                    case 2
                        kerfunc = @(x, ~) fillmissing2(squeeze(x), kwargs.method);
                end
                kernel = ones(1, ndims(data));
                kernel(kwargs.filtdims) = nan;
                padval = false;
            end
        otherwise
            if kwargs.filt ~= "none"
                kernelmat = fspecial(kwargs.filt, kwargs.filtker);
                kerfunc = @(x, ~) squeeze(tensorprod(kernelmat, x, 1:numel(kernelmat), kwargs.filtdims));
            end
    end

    data = nonlinfilt(kerfunc, ...
        data, ...
        kernel = kernel, ...
        padval = padval, ...
        verbose = kwargs.verbose, ...
        usefiledatastore = opts.usefiledatastore, ...
        useparallel = opts.useparallel, ...
        extract = opts.extract, ...
        resources = opts.resources, ...
        poolsize = opts.poolsize);

    clearAllMemoizedCaches;

end