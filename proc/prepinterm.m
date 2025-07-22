function result = prepinterm(data, kwargs)
    %% Prepare data to process intermittency.

    %% Examples:
    %% 1. Process a velocity directed gradient:
    % data.dwdl = prepinterm(data, type = 'dirgrad');
    %% 2. Process a lambda-2 criteria with custom settings:
    % data.l2 = prepinterm(data, type = 'l2', diffilt = 'sobel', prefilt = 'wiener', ...
    %       prefiltker = [15, 15], postfilt = 'median', postfiltker = [15, 15]);

    arguments
        data % struct stucture of PIV data reterned by `loadpiv` or `loadcta` function
        % processing value
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'dirgrad', 'l2', 'q', 'd', 'vm', 'dt'})} = 'drigrad'
        %% preprosessing parameters
        kwargs.norm (1,1) logical = true % norm 2D fields
        % differentiation kernel
        kwargs.diffilt (1,:) char {mustBeMember(kwargs.diffilt, {'sobel', '4ord', '4ordgauss', '2ord'})} = '4ord'
        % differentiation directions 
        kwargs.dirdim (1,:) double = 1
        % prefilter type
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode'})} = 'gaussian'
        kwargs.prefiltker (1,:) double = [3, 3] % prefilter kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
        % fill missing data
        kwargs.fillmiss (1,:) char {mustBeMember(kwargs.fillmiss, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        kwargs.pow (1,1) double = 2 % raise to the power
        kwargs.abs (1,1) logical = false % calculate an absolute value
        %% dirgrad parameters
        kwargs.angle double = deg2rad(-22) % anlge of directed gradient, [rad]
        % derivative component at spatial differentiation
        kwargs.component (1,:) char {mustBeMember(kwargs.component, {'dudl', 'dudn', 'dwdl', 'dwdn'})} = 'dwdl'
        %% l2 parameters
        % threshold of tensor invariant
        kwargs.threshold (1,:) char {mustBeMember(kwargs.threshold, {'none', 'neg', 'pos'})} = 'none'
        kwargs.eigord (1,1) double = 1
        %% postprocessing parameters
        % portfilter type
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode'})} = 'median'
        % postfilter
        kwargs.postfiltker (1,:) double = [15, 15] % postfilter kernel size
        %% optional
        kwargs.resources {mustBeA(kwargs.resources, {'char', 'string', 'cell'}), mustBeMember(kwargs.resources, {'Processes', 'Threads'})} = 'Threads'
        kwargs.poolsize (1,:) double = 16
        kwargs.usefiledatastore (1, 1) logical = false
        kwargs.useparallel (1,1) logical = false
        kwargs.extract {mustBeMember(kwargs.extract, {'readall', 'writeall'})} = 'readall'
    end

    result = [];

    if isfield(data, 'u') && isfield(data, 'w')
        u = data.u; w = data.w;
    
        % norm velocity
        if kwargs.norm && isfield(data, 'U') && isfield(data, 'W')
            if kwargs.fillmiss ~= "none"
                data.U = imfilt(data.U, filt = 'fillmiss', method = kwargs.fillmiss, zero2nan = true);
                data.W = imfilt(data.W, filt = 'fillmiss', method = kwargs.fillmiss, zero2nan = true);
            end
            Vm = hypot(data.U, data.W);
            if ~ismatrix(Vm); Vm = mean(Vm, 3); end
            u = u./Vm;
            w = w./Vm;
        end
    end

    if isfield(data, 'raw'); v = data.raw; end

    % processing
    switch kwargs.type
        case 'dirgrad'
            kernel = [nan, nan];
            padval = false;
            arg = {u, w};
            handl = @(u,w,~) dirgrad(u, w, kwargs.angle, component = kwargs.component, ...
                diffilt = kwargs.diffilt, fillmiss = kwargs.fillmiss, ...
                prefilt = kwargs.prefilt, prefiltker = kwargs.prefiltker, ...
                postfilt = kwargs.postfilt, postfiltker = kwargs.postfiltker, pow = kwargs.pow);
        case 'l2'
            kernel = [nan, nan];
            padval = false;
            arg = {u, w};
            handl = @(u,w,~) vortind(u, w, type = 'l2', diffilt = kwargs.diffilt, prefilt = kwargs.prefilt, abs = kwargs.abs, ...
                prefiltker = kwargs.prefiltker, threshold = kwargs.threshold, pow = kwargs.pow, eigord = kwargs.eigord, ...
                postfilt = kwargs.postfilt, postfiltker = kwargs.postfiltker, fillmiss = kwargs.fillmiss);
        case 'q'
            handl = @(u,w,~) vortind(u, w, type = 'q', diffilt = kwargs.diffilt, prefilt = kwargs.prefilt, abs = kwargs.abs, ...
                prefiltker = kwargs.prefiltker, threshold = kwargs.threshold, pow = kwargs.pow, eigord = kwargs.eigord, ...
                postfilt = kwargs.postfilt, postfiltker = kwargs.postfiltker, fillmiss = kwargs.fillmiss);
        case 'd'
            handl = @(u,w,~) vortind(u, w, type = 'd', diffilt = kwargs.diffilt, prefilt = kwargs.prefilt, abs = kwargs.abs, ...
                prefiltker = kwargs.prefiltker, threshold = kwargs.threshold, pow = kwargs.pow, eigord = kwargs.eigord, ...
                postfilt = kwargs.postfilt, postfiltker = kwargs.postfiltker, fillmiss = kwargs.fillmiss);
        case 'vm'
            kernel = [nan, nan];
            padval = false;
            arg = {u, w};

            handl = @(u,w,~) procvel(u, w, ...
                fillmiss = kwargs.fillmiss, prefilt = kwargs.prefilt, ...
                prefiltker = kwargs.prefiltker, postfilt = kwargs.postfilt, ...
                postfiltker = kwargs.postfiltker, hypot = true);
        case 'dt'
            diffilt = difkernel(kwargs.diffilt); diffilt = diffilt(:,1);
            kernel = nan(1, ndims(v)); kernel(kwargs.dirdim) = numel(diffilt);
            padval = num2cell(false(1, ndims(v)));
            padval{kwargs.dirdim} = 'symmetric';

            handl = @(x,~) squeeze(tensorprod(diffilt(:), x, 1, kwargs.dirdim)).^kwargs.pow;
            arg{1} = v;
    end

    result = nonlinfilt(handl, arg{:}, kernel = kernel, padval = padval, ...
        resources = kwargs.resources, poolsize = kwargs.poolsize, ....
        usefiledatastore = kwargs.usefiledatastore, ...
        useparallel = kwargs.useparallel, extract = kwargs.extract);

    % postprocessing
    switch kwargs.type
        case 'dt'
            kernel(kwargs.dirdim) = kwargs.postfiltker;
            result = nonlinfilt(@(x, ~) median(x, kwargs.dirdim), result, ...
                kernel = kernel, padval = padval,...
                resources = kwargs.resources, poolsize = kwargs.poolsize, ...
                usefiledatastore = kwargs.usefiledatastore, ...
                useparallel = kwargs.useparallel, extract = kwargs.extract);
    end
    
    clearAllMemoizedCaches
    
end