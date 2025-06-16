function result = procinterm(data, kwargs)
    %% Intermittency processing.

    %% Examples:
    %% 1. Process intermittency by clustering method k-means: 
    % % all sample realizations, euclidean metric, median intermittency field postfitlering by kernel size [3,3]
    % [interm, binar, dist, cent] = procinterm(data.dwdl, method = 'cluster', distance = 'sqeuclidean', ...
    %   batch = true, postfilt = 'median', postfiltker = [5, 5]);
    %% 2. Process intermittency by clustering method k-means: 
    % % instantaneous sample realizations, euclidean metric, without postfiltering
    % [interm, binar, dist, cent] = procinterm(data.dwdl, method = 'cluster', distance = 'sqeuclidean', ...
    %   batch = false, postfilt = 'none');
    %% 3. Process intermittency by PDF integral ratio method:
    % % gubmel distribution, coeffificent constrains, mesh of histogram bins, statistical constrains
    % [interm, fitdistcoef] = procinterm(data.dwdl, distname = 'gumbel2', method = 'integral-ratio', ...
    %       x0 = [0.7351, 0.0004, 0.0002, 0.2305, 0.0008, 0.0004], lb = [1e-2, 0, 0, 0, 0, 0], ...
    %       ub = [2, 5e-3, 5e-3, 2, 5e-3, 5e-3], binedge = linspace(0, 5e-3, 500), ...
    %       mode1 = [3e-4, 7e-4], mode2 = [8e-4, 7e-3]);
    %% 4. Process intermittency by CDF integral intersection method:
    % % gubmel distribution, coeffificent constrains, mesh of histogram bins, statistical constrains
    % [interm, binar, thresh, fitdistcoef] = procinterm(data.dwdl, distname = 'gumbel2', method = 'cdf-intersection', ...
    %       x0 = [0.7351, 0.0004, 0.0002, 0.2305, 0.0008, 0.0004], lb = [1e-2, 0, 0, 0, 0, 0], ...
    %       ub = [2, 5e-3, 5e-3, 2, 5e-3, 5e-3], binedge = linspace(0, 5e-3, 500), ...
    %       mode1 = [3e-4, 7e-4], mode2 = [8e-4, 7e-3]);

    arguments
        data double % multidimensional data
        %% data parameters
        % statistical distribution norm
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge (1,:) double = [] % bin count or edge grid 
        % method of intermittency processing
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio', 'cluster', 'cnn'})} = 'integral-ratio'
        %% intergal algorithm parameters
        % type of statistics fit
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
        kwargs.quantile (1,1) double = 0.9 % quantile threshold
        % method to find root of two cdf intersection
        kwargs.root (1,:) char {mustBeMember(kwargs.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
        %% advanced fit distribution parameters
        kwargs.fitdistinit (1,1) logical = true % advanced initializing approximation of optimization problem
        kwargs.fitdistcoef (:,:,:) double = [] % fit approximation coefficients
        kwargs.fitdistfiltker (1,:) double = [30, 30] % filter size to filt initial fit coefficients at processing
        kwargs.fitdistfiltstrd (1,:) double = [5, 5] % filter strides to filt initial fit coefficients at processing
        % filter kernel to smooth initial fit coefficients
        kwargs.fitdistpostfilt (1,:) char {mustBeMember(kwargs.fitdistpostfilt, {'none', 'average', 'gaussian', 'median', 'wiener', 'mode'})} = 'median'
        kwargs.fitdistpostfiltker (1,:) double = [5, 5] % filter kernel size at smooth initial fit coefficients at postporcessing
        %% cluster algorithm parameters
        % cluster method metric
        kwargs.distance (1,:) char {mustBeMember(kwargs.distance, {'sqeuclidean', 'cityblock', 'cosine', 'correlation', 'hamming'})} = 'sqeuclidean'
        kwargs.fill (1,1) logical = false % fill closed domain of processed fields
        kwargs.imerode (1,1) logical = false % image morphological erosion
        kwargs.erodeker (1,:) double = 5 % kernel of morphological erosion
        kwargs.imclose logical = false % apply a close morphological operation to 2D binarized data
        kwargs.closeker (1,:) double = 10 % kernel of close morphological operation
        kwargs.dilate (1,1) logical = false % apply a dilate morphological operation to 2D binarized data
        kwargs.dilateker (1,:) double = 5 % kernel of 2D dilate morphological operation
        kwargs.dilate1d (1,1) logical = false % apply a dilate morphological operation to 1D binarized data
        kwargs.dilate1dker (1,:) double = [1, 1, 15] % kernel of 1D dilate morphological operation
        kwargs.mask (:,:) double = [] % polygonal mask to select 2D data
        %% neural network parameters
        % version of convolutional neural network
        kwargs.cnnversion (1,:) char {mustBeMember(kwargs.cnnversion, {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6'})} = '0.1'
        kwargs.network = [] % instance of sequence network
        kwargs.crop double = [20, 20, 230, 280] % crop data: [x0, y0, width, height]
        kwargs.map double = [0, 1.5] % mapping data range to specified
        %% processing parameters
        kwargs.kernel double = [30, 30] % size of processing window
        kwargs.stride double = [5, 5] % strides of processing window
        kwargs.offset (1,:) {mustBeA(kwargs.offset, {'double', 'cell'})} = [] % offset of processing window
        kwargs.avgdim (1,:) double = [] % averaging dimension
        %% optimization parameters
        kwargs.objnorm double = 2 % norm order at calculation objective function
        kwargs.nonlcon = [] % non-linear optimization constrain function
        kwargs.x0 double = [] % inital parameters
        kwargs.lb double = [] % lower bound of parameters
        kwargs.ub double = [] % upper bpund of parameters
        %% restriction parameters
        kwargs.mean1 double = [] % constraints of mean value the first mode
        kwargs.mode1 double = [] % constraints of mode value the first mode
        kwargs.var1 double = [] % constraints of variance value the first mode
        kwargs.amp1 double = [] % constraints of amplitude value the first mode
        kwargs.mean2 double = [] % constraints of mean value the second mode
        kwargs.mode2 double = [] % constraints of mode value the second mode
        kwargs.var2 double = [] % constraints of variance value the second mode
        kwargs.amp2 double = [] % constraints of amplitude value the second mode
        %% pre-pocessing parameters
        % method to filter threshold field
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener', 'mode', 'dilate'})} = 'median'
        kwargs.prefiltker double = [4, 4] % kernel of filtering threshold field
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
        %% post-processing parameters
        % method to filter intermittency field
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'average', 'gaussian', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'mode'})} = 'none'
        kwargs.postfiltker double = [5, 5] % kernel of filtering intermittency field
        kwargs.resize (1,1) logical = true
        %% support parameters
        kwargs.verbose (1,1) logical = true % show logger
        %% optional
        kwargs.resources {mustBeA(kwargs.resources, {'cell'}), mustBeMember(kwargs.resources, {'Processes', 'Threads'})} = {'Processes', 'Processes'}
        kwargs.usefiledatastore (1, 1) logical = false
        kwargs.useparallel (1,1) logical = false
        kwargs.extract {mustBeMember(kwargs.extract, {'readall', 'writeall'})} = 'readall'
    end

    function [result, fitdistcoef] = procfitdistfilt(data, kwargs)
        szd = size(data); fitdistcoef = [];
        if kwargs.fitdistinit
            if isempty(kwargs.fitdistcoef)
                fitdistcoef = procfitdistcoef(data, norm = kwargs.norm, binedge = kwargs.binedge, ...
                    distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon, ...
                    kernel = kwargs.fitdistfiltker, stride = kwargs.fitdistfiltstrd, ...
                    postfilt = kwargs.fitdistpostfilt, postfiltker = kwargs.fitdistpostfiltker, verbose = kwargs.verbose);
            else
                fitdistcoef = kwargs.fitdistcoef;
            end

            if ~isvector(data)
                m = numel(kwargs.kernel);
                n = ndims(data) - numel(kwargs.kernel);
                padval = {cat(2, repmat({kwargs.padval}, 1, m), repmat({false}, 1, n)), ...
                    cat(2, repmat({kwargs.padval}, 1, m), {false})};
                kernel = kwargs.kernel; stride = kwargs.stride;
                kwargs.kernel = cell(1, 2); kwargs.stride = cell(1, 2);
                kwargs.kernel{1} = [kernel, nan(1, n)];
                kwargs.stride{1} = [stride, ones(1, n)];
                kwargs.kernel{2} = [kernel, nan];
                kwargs.stride{2} = [stride, 1];
                x0 = @(y) squeeze(median(y, [1, 2], 'omitmissing'));
            else
                x0 = @(y) median(y, 1, 'omitmissing');
            end

            nlkernel = @(x, y, ~) fitdistfilt(x, method = kwargs.method, norm = kwargs.norm, ...
                binedge = kwargs.binedge, root = kwargs.root, ...
                quantile = kwargs.quantile, distname = kwargs.distname, x0 = x0(y), ...
                lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);

            result = nonlinfilt(nlkernel, data, fitdistcoef, ...
                kernel = kwargs.kernel, stride = kwargs.stride, padval = padval, ...
                    resources = kwargs.resources, usefiledatastore = kwargs.usefiledatastore, ...
                    useparallel = kwargs.useparallel, extract = kwargs.extract);
        else
            nlkernel = @(x, ~) fitdistfilt(x, method = kwargs.method, norm = kwargs.norm, binedge = kwargs.binedge, root = kwargs.root, ...
                quantile = kwargs.quantile, distname = kwargs.distname, x0 = kwargs.x0, ...
                lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);

            if ~isvector(data)
                m = numel(kwargs.kernel);
                n = ndims(data) - numel(kwargs.kernel);
                kwargs.kernel = [kwargs.kernel, nan(1, n)];
                kwargs.stride = [kwargs.stride, ones(1, n)];
    
                padval = cat(2, repmat({kwargs.padval}, 1, m), repmat({false}, 1, n));
            end

            result = nonlinfilt(nlkernel, data, kernel = kwargs.kernel, stride = kwargs.stride, padval = padval, ...
                resources = kwargs.resources, usefiledatastore = kwargs.usefiledatastore, ...
                useparallel = kwargs.useparallel, extract = kwargs.extract);
        end
        if kwargs.method ~= "integral-ratio"
            result = imfilt(result, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);
            if ~isvector(data)
                result = imdresize(result, szd(1:2));
            end
        end
    end

    function binarized = procfitdistbinar(data, threshold)
        binarized = data ./ threshold; binarized(binarized >= 1) = 1; binarized(binarized < 1) = 0;
    end

    function [binarized, center, distance] = procclust(data, kwargs)
        szd = size(data);
        if isempty(kwargs.mask)
            temporary = data;
        else
            index = poly2mask(kwargs.mask(:,1), kwargs.mask(:,2), szd(1), szd(2));
            if ~ismatrix(data)
                index = repmat(index(:), prod(szd(3:end)), 1);
            end
            temporary = data(index);
        end
        [binarized, center, ~, distance] = kmeans(temporary(:), 2, 'Distance', kwargs.distance);
        if ~isempty(kwargs.mask)
            temporary = zeros(szd);
            temporary(index) = binarized;
            binarized = temporary;

            temporary = zeros([szd, 2]);
            index = poly2mask(kwargs.mask(:,1), kwargs.mask(:,2), szd(1), szd(2));
            index = repmat(index(:), prod(szd(3:end)*2), 1);
            temporary(index) = distance(:);
            distance = temporary;
        else
            binarized = reshape(binarized, szd);
            distance = squeeze(reshape(distance, [szd, 2]));
        end
        [~, index] = max(center);
        switch index
            case 1
                binarized = -(binarized - 2);
            case 2
                binarized = binarized - 1;
        end
    end

    intermittency = []; binarized = []; threshold = []; fitdistcoef = []; distance = []; center = [];

    if isempty(kwargs.nonlcon)
        kwargs.nonlcon = @(x) nonlconfitdist(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    timerVal = tic;

    switch kwargs.method
        case 'quantile-threshold'
            [threshold, fitdistcoef] = procfitdistfilt(data, kwargs);
            binarized = procfitdistbinar(data, threshold);
        case 'cdf-intersection'
            [threshold, fitdistcoef] = procfitdistfilt(data, kwargs);
            binarized = procfitdistbinar(data, threshold);
        case 'cluster'
            [binarized, center, distance] = procclust(data, kwargs);
    end

    % morphological postprocessing
    if ~isempty(binarized)
        if kwargs.dilate1d; binarized = nonlinfilt(@(x) sum(x(:))>0, binarized, kernel = kwargs.dilate1dker); end
        if kwargs.dilate; binarized = immorph(binarized, method = 'dilate', strelker = kwargs.dilateker); end
        if kwargs.imerode; binarized = immorph(binarized, method = 'erode', strelker = kwargs.erodeker); end
        if kwargs.imclose; binarized = immorph(binarized, method = 'close', strelker = kwargs.closeker); end
        if kwargs.fill; binarized = immorph(binarized, method = 'fill'); end
    end

    % averaging
    if isempty(kwargs.avgdim)
        if ismatrix(data)
            intermittency = squeeze(mean(binarized, 2, 'omitmissing'));
        else
            intermittency = squeeze(mean(binarized, 3, 'omitmissing'));
        end
    else
        intermittency = squeeze(mean(binarized, kwargs.avgdim, 'omitmissing'));
    end

    switch kwargs.method
        case 'integral-ratio'
            [intermittency, fitdistcoef] = procfitdistfilt(data, kwargs);
        case 'cnn'
            [intermittency, binarized] = predinterm(data, network = kwargs.network, version = kwargs.cnnversion, ...
                crop = kwargs.crop, map = kwargs.map);
    end

    % postfiltering
    intermittency = imfilt(intermittency, filt = kwargs.postfilt, filtker = kwargs.postfiltker);

    switch kwargs.method
        case 'integral-ratio'
            if kwargs.resize; intermittency = imdresize(intermittency, size(data, [1, 2])); end
    end

    if kwargs.verbose; disp(strcat("procinterm: elapsed time is ", num2str(toc(timerVal)), " seconds")); end

    result = struct();
    if ~isempty(intermittency); result.intermittency = intermittency; end
    if ~isempty(binarized); result.binarized = binarized; end
    if ~isempty(threshold); result.threshold = threshold; end
    if ~isempty(fitdistcoef); result.fitdistcoef = fitdistcoef; end
    if ~isempty(distance); result.distance = distance; end
    if ~isempty(center); result.center = center; end

end