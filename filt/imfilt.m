function data = imfilt(data, kwargs, opts)
    %% Batch filtering of 2D data.

    arguments (Input)
        data
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'wiener', 'fillmiss', 'mediancond'})} = 'gaussian'
        kwargs.filtker double = [3, 3] % kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = nan % padding value
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'nearest' % at specifying `filtker=fillmiss`
        kwargs.zero2nan (1,1) logical = true
        kwargs.verbose (1,1) logical = false
        kwargs.mediancondvars (1,2) double = [1, 1]
        opts.usefiledatastore (1, 1) logical = false
        opts.useparallel (1,1) logical = false
        opts.extract {mustBeMember(opts.extract, {'readall', 'writeall'})} = 'readall'
        opts.poolsize = {16, 16}
        opts.resources {mustBeA(opts.resources, {'cell'}), mustBeMember(opts.resources, {'Processes', 'Threads'})} = {'Threads', 'Threads'}
    end

    arguments (Output)
        data
    end

    switch kwargs.filt
        case 'wiener'
            data = nonlinfilt(@(x,~) wiener2(x, kwargs.filtker), data, kernel = [nan, nan], padval = false, ...
                verbose = kwargs.verbose, usefiledatastore = opts.usefiledatastore, ...
                useparallel = opts.useparallel, extract = opts.extract, ...
                resources = opts.resources);
        case 'median'
            kerfunc = @(y,~) nonlinfilt(@(x,~) median(x(:), 'omitmissing'), y, kernel = kwargs.filtker, padval = kwargs.padval);

            data = nonlinfilt(kerfunc, data, kernel = [nan, nan], padval = false, ...
                verbose = kwargs.verbose, usefiledatastore = opts.usefiledatastore, ...
                useparallel = opts.useparallel, extract = opts.extract, ...
                resources = opts.resources);

            % m = numel(kwargs.filtker);
            % n = ndims(data) - numel(kwargs.filtker);
            % kwargs.padval = cat(2, repmat({kwargs.padval}, 1, m), repmat({false}, 1, n));
            % 
            % data = nonlinfilt(@(x,~) median(x(:), 'omitmissing'), data, kernel = kwargs.filtker, ...
            %     padval = kwargs.padval, verbose = kwargs.verbose, usefiledatastore = opts.usefiledatastore, ...
            %     useparallel = opts.useparallel, extract = opts.extract, ...
            %     resources = opts.resources);
        case 'fillmiss'
            if kwargs.method ~= "none"
                if kwargs.zero2nan; data(data==0) = nan; end
                data = nonlinfilt(@(x,~) fillmissing2(x, kwargs.method), data, kernel = [nan, nan], padval = false, ...
                    verbose = kwargs.verbose, usefiledatastore = opts.usefiledatastore, ...
                    useparallel = opts.useparallel, extract = opts.extract, ...
                    resources = opts.resources);
            end
        case 'mediancond'
            data = nonlinfilt(@(x,~) kermedcond(x, kwargs.mediancondvars), data, kernel = kwargs.filtker, ...
                padval = kwargs.padval, verbose = kwargs.verbose, usefiledatastore = opts.usefiledatastore, ...
                useparallel = opts.useparallel, extract = opts.extract, ...
                resources = opts.resources);
        otherwise
            if kwargs.filt ~= "none"
                data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker), kwargs.padval);
            end
    end

    clearAllMemoizedCaches;

    function y = kermedcond(x,n)
        szx = size(x); szm = floor(szx/2);
        mask = true(szx); mask(szm(1),szm(2)) = false; mask = mask(:);
        xvar = sqrt(var(x(mask),[],'omitmissing'));
        xmed = median(x(mask),'omitmissing');
        if isnan(x(szm(1),szm(2)))
            y = xmed;
        else
            if (xmed - n(1)*xvar <= x(szm(1),szm(2))) && (xmed + n(2)*xvar >= x(szm(1),szm(2)))
                y = x(szm(1),szm(2));
            else
                y = xmed;
            end
        end
    end

end