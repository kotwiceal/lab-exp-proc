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
        kwargs.filtdim (1,:) double = []
        kwargs.kernel (1,:) double = [] % size of processing window
        kwargs.stride (1,:) double = [] % strides of processing window
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
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
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'average', 'gaussian', 'median'})} = 'median'
        kwargs.postfiltker (1,:) double = [] % kernel of filtering intermittency field
        kwargs.postfiltdim (1,:) double = []
        kwargs.postpadval {mustBeA(kwargs.postpadval, {'double', 'char', 'string', 'logical', 'cell'})} = false % padding value
        kwargs.griddim (1,:) double = []
        kwargs.griddata {mustBeMember(kwargs.griddata, {'none', 'linear', 'nearest'})} = 'nearest'
        %% support parameters
        kwargs.verbose (1,1) logical = true
        %% optional
        kwargs.usefiledatastore (1,1) logical = false
        kwargs.useparallel (1,1) logical = false
        kwargs.extract {mustBeMember(kwargs.extract, {'readall', 'writeall'})} = 'readall'
        kwargs.poolsize (1,:) double = 16
    end

    timer = tic; szd = size(data);

    if isempty(kwargs.kernel); kwargs.kernel = nan(ndims(data)); end

    if isempty(kwargs.nonlcon)
        kwargs.nonlcon = @(x) nonlconfitdist(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    if isempty(kwargs.fitdistcoefinit)  
        nlkernel = @(x, ~) fitdistfilt(x, method = 'fitdistcoef', norm = kwargs.norm, binedge = kwargs.binedge, ...
            distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
        arg = {data};
    else
        x0 = @(y) squeeze(median(y, 1:ndims(y)-1, 'omitmissing'));
        nlkernel = @(x, y, ~) fitdistfilt(x, method = 'fitdistcoef', ...
            norm = kwargs.norm, binedge = kwargs.binedge, ...
            distname = kwargs.distname, x0 = x0(y), ...
            lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
        arg = {data, kwargs.fitdistcoefinit};
    end

    fitdistcoef = nonlinfilt(nlkernel, arg{:}, filtdim = kwargs.filtdim, ...
        kernel = kwargs.kernel, stride = kwargs.stride, padval = kwargs.padval, ...
        resources = 'Processes', usefiledatastore = kwargs.usefiledatastore, ...
            useparallel = kwargs.useparallel, extract = kwargs.extract, poolsize = kwargs.poolsize);

    fitdistcoef = shiftdim(fitdistcoef, 1);

    % postfiltering
    fitdistcoef = ndfilt(fitdistcoef, filtdim = kwargs.postfiltdim, filt = kwargs.postfilt, ...
        filtker = kwargs.postfiltker, padval = kwargs.postpadval);

    % resize to original size
    if isempty(kwargs.filtdim)
        ind = ~isnan(kwargs.kernel);
    else
        ind = 1:ndims(data);
        ind = ind(kwargs.filtdim(~isnan(kwargs.kernel)));
    end
    fitdistcoef = ndfilt(fitdistcoef, filt = 'griddatan', ...
        filtker = szd(ind), filtdim = 1:ndims(fitdistcoef)-1, method = kwargs.griddata);

    if kwargs.verbose; disp(strcat("procfitdistcoef: elapsed time is ", num2str(toc(timer)), " seconds")); end

    clearAllMemoizedCaches

end