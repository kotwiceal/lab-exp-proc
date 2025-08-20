function data = ndfilt(data, kwargs, opts)
    %% Advance multi-dimensional data filtering.

    arguments (Input)
        data
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'fillmiss', 'griddatan'})} = 'gaussian'
        kwargs.filtker (1,:) double = [] % kernel size
        kwargs.filtdim (1,:) double = []
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

    if isempty(kwargs.filtker); return; end

    switch kwargs.filt
        case 'median'
            if isempty(kwargs.filtdim)
                filtdim = 1:numel(kwargs.filtker);
                filtdim(kwargs.filtker == 1) = [];
            else
                filtdim = kwargs.filtdim;
            end
            kerfunc = @(x, ~) squeeze(median(x, filtdim, 'omitmissing'));
        case 'fillmiss'
            if kwargs.method ~= "none"
                if kwargs.zero2nan; data(data==0) = nan; end
                switch numel(kwargs.filtdim)
                    case 1
                        kerfunc = @(x, ~) fillmissing1(squeeze(x), kwargs.method);
                    case 2
                        kerfunc = @(x, ~) fillmissing2(squeeze(x), kwargs.method);
                end
                kwargs.filtker = ones(1, ndims(data));
                kwargs.filtker(kwargs.filtdim) = nan;
                kwargs.filtdim = [];
                kwargs.padval = false;
            end
        case 'griddatan'
            kwargs.filt = 'none';
            szd = size(data);

            if isempty(kwargs.filtdim)
                tempfunc = @(x) x*(x > 0);
                kwargs.filtker = padarray(kwargs.filtker, [0, tempfunc(ndims(data)-numel(kwargs.filtker))], nan, 'post');

            else
                kernel = nan(1, ndims(data));
                kernel(kwargs.filtdim) = kwargs.filtker;
                kwargs.filtker = kernel;
            end
            kwargs.filtker(isnan(kwargs.filtker)) = szd(isnan(kwargs.filtker));

            temp = cellfun(@(x) 1:x, num2cell(szd), UniformOutput = false);
            subind = cell(1, numel(temp));
            [subind{:}] = ndgrid(temp{:});
            subind = cell2arr(cellfun(@(x) x(:), subind, UniformOutput = false));
                        
            temp = cellfun(@(x, y) linspace(1, x, y), num2cell(szd), num2cell(kwargs.filtker), UniformOutput = false);

            subindq = cell(1, numel(temp));
            [subindq{:}] = ndgrid(temp{:});
            subindq = cell2arr(cellfun(@(x) x(:), subindq, UniformOutput = false));

            data = griddatan(subind, data(:), subindq, kwargs.method);
            data = reshape(data, kwargs.filtker);
        otherwise
            if kwargs.filt ~= "none"
                kernelmat = fspecial(kwargs.filt, kwargs.filtker);
                kerfunc = @(x, ~) squeeze(tensorprod(kernelmat, x, 1:ndims(kernelmat), kwargs.filtdim));
            end
    end

    if kwargs.filt ~= "none"
        data = nonlinfilt(kerfunc, ...
            data, ...
            kernel = kwargs.filtker, ...
            padval = kwargs.padval, ...
            filtdim = kwargs.filtdim, ...
            verbose = kwargs.verbose, ...
            usefiledatastore = opts.usefiledatastore, ...
            useparallel = opts.useparallel, ...
            extract = opts.extract, ...
            resources = opts.resources, ...
            poolsize = opts.poolsize);
    end

    clearAllMemoizedCaches;

end