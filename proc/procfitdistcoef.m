function fitdistcoef =  procfitdistcoef(data, kwargs)
    %% Fit statistical distribution by analytical distributions.

    %% Examples:
    %% 1. Fit distribution of directed velocity gradient by bimode gumbel distribution with custom constraints:
    % fitdistcoef = procfitdistcoef(data.dwdl, distname = 'gumbel2', mode1 = mode1, var1 = var1, ...
    %     mode2 = mode2, var2 = var2, binedge = binedge, x0 = x0, lb = lb, ub = ub, ...
    %     strides = [5, 5], kernel = [30, 30], postfilt = 'none');

    arguments
        data double % multidimensional data
        %% data parameters
        % type of statistics normalization
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge (1,:) double = [] % bins count or edge grid
        % type of statistics fit
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
        kwargs.fitdistcoefinit double = [] % initial fitdistcoef
        %% processing parameters
        kwargs.kernel (1,:) double = [30, 30] % size of processing window
        kwargs.stride (1,:) double = [5, 5] % strides of processing window
        %% optimization parameters
        kwargs.objnorm (1,1) double = 2 % norm order at calculation objective function
        kwargs.nonlcon = [] % non-linear optimization constrain function
        kwargs.x0 (1,:) double = [] % inital parameters
        kwargs.lb (1,:) double = [] % lower bound of parameters
        kwargs.ub (1,:) double = [] % upper bpund of parameters
        %% restriction parameters
        kwargs.mean1 (1,:) double = [] % constraints of mean value the first mode
        kwargs.mode1 (1,:) double = [] % constraints of mode value the first mode
        kwargs.var1 (1,:) double = [] % constraints of variance value the first mode
        kwargs.amp1 (1,:) double = [] % constraints of amplitude value the first mode
        kwargs.mean2 (1,:) double = [] % constraints of mean value the second mode
        kwargs.mode2 (1,:) double = [] % constraints of mode value the second mode
        kwargs.var2 (1,:) double = [] % constraints of variance value the second mode
        kwargs.amp2 (1,:) double = [] % constraints of amplitude value the second mode
        %% post-pocessing parameters
        % method to filter intermittency field
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'average', 'gaussian', 'median', 'wiener', 'mode'})} = 'median'
        kwargs.postfiltker double = [5, 5] % kernel of filtering intermittency field
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
        %% support parameters
        kwargs.verbose (1,1) logical = true
        %% optional
        kwargs.resources {mustBeA(kwargs.resources, {'cell'}), mustBeMember(kwargs.resources, {'Processes', 'Threads'})} = {'Processes', 'Processes'}
        kwargs.usefiledatastore (1, 1) logical = false
        kwargs.useparallel (1,1) logical = false
        kwargs.extract {mustBeMember(kwargs.extract, {'readall', 'writeall'})} = 'readall'
    end

    timer = tic; szd = size(data);

    if isempty(kwargs.nonlcon)
        kwargs.nonlcon = @(x) nonlconfitdist(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    if isempty(kwargs.fitdistcoefinit)
        if ~isvector(data)
            m = numel(kwargs.kernel);
            n = ndims(data) - numel(kwargs.kernel);
            kwargs.kernel = [kwargs.kernel, nan(1, n)];
            kwargs.stride = [kwargs.stride, ones(1, n)];

            padval = cat(2, repmat({kwargs.padval}, 1, m), repmat({false}, 1, n));
        end
    
        nlkernel = @(x, ~) fitdistfilt(x, method = 'fitdistcoef', norm = kwargs.norm, binedge = kwargs.binedge, ...
            distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);

        fitdistcoef = nonlinfilt(nlkernel, data, kernel = kwargs.kernel, stride = kwargs.stride, padval = padval, ...
            resources = kwargs.resources, usefiledatastore = kwargs.usefiledatastore, ...
                useparallel = kwargs.useparallel, extract = kwargs.extract);
    else
        szf = size(kwargs.fitdistcoefinit);

        if ~isvector(data)
            kernel = kwargs.kernel; stride = kwargs.stride;
            kwargs.kernel = cell(1, 2); kwargs.stride = cell(1, 2); kwargs.offset = cell(1, 2);
            kwargs.kernel{1} = [kernel, szd(3)];
            kwargs.stride{1} = [stride, szd(3)];
            kwargs.offset{1} = [0, 0, 0];
            kwargs.kernel{2} = [kernel, szf(3)];
            kwargs.stride{2} = [stride, szf(3)];
            kwargs.offset{2} = [0, 0, 0];

            x0 = @(y) squeeze(median(y, [1, 2], 'omitmissing'));
        else
            x0 = @(y) median(y, 1, 'omitmissing');
        end

        nlkernel = @(x, y, ~) fitdistfilt(x, method = 'fitdistcoef', norm = kwargs.norm, binedge = kwargs.binedge, ...
            distname = kwargs.distname, x0 = x0(y), ...
            lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);

        fitdistcoef = nonlinfilt(nlkernel, data, kwargs.fitdistcoefinit, ...
            kernel = kwargs.kernel, stride = kwargs.stride, offset = kwargs.offset, padval = kwargs.padval, ...
            resources = kwargs.resources, usefiledatastore = kwargs.usefiledatastore, ...
                useparallel = kwargs.useparallel, extract = kwargs.extract);
    end

    fitdistcoef = shiftdim(fitdistcoef, 1);

    fitdistcoef = imfilt(fitdistcoef, filt = kwargs.postfilt, filtker = kwargs.postfiltker, padval = kwargs.padval);

    fitdistcoef = imdresize(fitdistcoef, szd(1:2));

    if kwargs.verbose; disp(strcat("procfitdistcoef: elapsed time is ", num2str(toc(timer)), " seconds")); end

    clearAllMemoizedCaches

end