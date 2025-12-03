function data = ndfilt(data, kwargs, opts)
    %% Advance multi-dimensional data filtering.

    arguments (Input)
        data
        % filter name
        kwargs.filt {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'sobel', 'median', 'fillmiss', 'griddatan', 'fillmissn', 'interpn'})} = 'gaussian'
        kwargs.filtker (1,:) double = [] % kernel size
        kwargs.filtdim (1,:) double = [] % filter dimension 
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'nearest' % at specifying `filtker=fillmiss`
        kwargs.zero2nan (1,1) logical = true
        kwargs.verbose (1,1) logical = false
        opts.usefiledatastore (1, 1) logical = false
        opts.useparallel (1,1) logical = false
        opts.extract {mustBeMember(opts.extract, {'readall', 'writeall'})} = 'readall'
        opts.poolsize (1,:) double = [] % pool size
        opts.pool {mustBeMember(opts.pool, {'Processes', 'Threads', 'backgroundPool'})} = 'backgroundPool'
    end

    arguments (Output)
        data
    end

    if (isempty(kwargs.filtker) & isempty(kwargs.filtdim)) | strcmp(kwargs.filt,"none") | isscalar(data); return; end

    switch kwargs.filt
        case 'median'
            if isempty(kwargs.filtdim)
                kwargs.filtdim = 1:numel(kwargs.filtker);
                kwargs.filtdim(kwargs.filtker == 1) = [];
            end
            kerfunc = @(x, ~) squeeze(median(x, kwargs.filtdim, 'omitmissing'));
            padval = kwargs.padval;
            if ~isa(padval,'cell'); padval = {padval}; end
            kwargs.padval = num2cell(false(1, ndims(data)));
            if numel(padval) == numel(kwargs.filtdim)
                kwargs.padval(kwargs.filtdim) = padval;
            else
                kwargs.padval = padval;
            end
            kernel = nan(1, ndims(data));
            kernel(kwargs.filtdim) = kwargs.filtker;
            kwargs.filtker = kernel;
            kwargs.filtdim = [];
        case 'fillmiss'
            if kwargs.method ~= "none"
                kwargs.filtker = nan(1, numel(kwargs.filtdim));
                kwargs.padval = false;
                if kwargs.zero2nan; data(data==0) = nan; end
                switch numel(kwargs.filtdim)
                    case 1
                        kerfunc = @(x, ~) fillmissing(squeeze(x), kwargs.method);
                    case 2
                        kerfunc = @(x, ~) fillmissing2(squeeze(x), kwargs.method);
                end
            end
        case 'fillmissn'
            kwargs.padval = false;
            kwargs.filtker = size(data,kwargs.filtdim);
            if isscalar(kwargs.filtker); kwargs.filtker = [kwargs.filtker, 1]; end
            p = cellfun(@(x)linspace(0,1,x),num2cell(size(data,kwargs.filtdim)),'UniformOutput',false);
            [p{:}] = ndgrid(p{:});
            p = cellfun(@(x)x(:),p,'UniformOutput',false);
            p = cat(2,p{:});
            kerfunc = @(x,~) reshape(griddatan(p(~isnan(x(:)),:),x(~isnan(x(:))),p,kwargs.method),kwargs.filtker);
            kwargs.filtker = nan(1,numel(kwargs.filtdim));
        case 'griddatan'
            kwargs.padval = false;
            if isempty(kwargs.filtdim); kwargs.filtdim = 1:numel(kwargs.filtker); end
            p = cellfun(@(x)linspace(0,1,x),num2cell(size(data,kwargs.filtdim)),'UniformOutput',false);
            [p{:}] = ndgrid(p{:});
            p = cellfun(@(x)x(:),p,'UniformOutput',false);
            q = cellfun(@(x)linspace(0,1,x),num2cell(kwargs.filtker),'UniformOutput',false);
            [q{:}] = ndgrid(q{:});
            q = cellfun(@(x)x(:),q,'UniformOutput',false);
            kerfunc = @(x,~) reshape(griddatan(cat(2,p{:}),x(:),cat(2,q{:}),kwargs.method),kwargs.filtker);
            kwargs.filtker = nan(1,numel(kwargs.filtdim));
        case 'interpn'
            kwargs.padval = false;
            if isempty(kwargs.filtdim); kwargs.filtdim = 1:numel(kwargs.filtker); end
            p = cellfun(@(x)linspace(0,1,x),num2cell(size(data,kwargs.filtdim)),'UniformOutput',false);
            [p{:}] = ndgrid(p{:});
            q = cellfun(@(x)linspace(0,1,x),num2cell(kwargs.filtker),'UniformOutput',false);
            [q{:}] = ndgrid(q{:});
            if isscalar(kwargs.filtker); kwargs.filtker = [kwargs.filtker, 1]; end
            kerfunc = @(x,~) reshape(interpn(p{:},x,q{:},kwargs.method),kwargs.filtker);
            kwargs.filtker = nan(1,numel(kwargs.filtdim));
        otherwise
            if isempty(kwargs.filtdim); kwargs.filtdim = 1:numel(kwargs.filtker); end
            if isscalar(kwargs.filtdim); kwargs.filtdim = [kwargs.filtdim, 2]; end
            if isscalar(kwargs.filtker); kwargs.filtker = [kwargs.filtker, 1]; end
            padval = kwargs.padval;
            if ~isa(padval,'cell'); padval = {padval}; end
            kwargs.padval = num2cell(false(1, ndims(data)));
            kwargs.padval(kwargs.filtdim) = padval;
            kernelmat = fspecial(kwargs.filt, kwargs.filtker);
            kerfunc = @(x,~) squeeze(tensorprod(kernelmat, x, 1:ndims(kernelmat), kwargs.filtdim));
    end

    data = nonlinfilt(kerfunc, ...
        data, ...
        kernel = kwargs.filtker, ...
        padval = kwargs.padval, ...
        filtdim = kwargs.filtdim, ...
        verbose = kwargs.verbose, ...
        usefiledatastore = opts.usefiledatastore, ...
        useparallel = opts.useparallel, ...
        extract = opts.extract, ...
        pool = opts.pool, ...
        poolsize = opts.poolsize);

    clearAllMemoizedCaches;

end