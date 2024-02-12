function varargout = procinterm(data, kwargs)
%% Intermittency processing.
%% The function takes following arguments:
%   data:           [n×m... double]     - multidimensional data
%   range:          [1×2 double]        - range to exculde statistical edges
%   norm:           [char]              - type of statistics normalization
%   binedge:        [1×l double]        - bins count or edge grid 
%
%   method:         [char array]        - method of intermittency processing
%   distname:       [char array]        - type of statistics fit
%   quantile:       [1×1 double]        - quantile threshold
%   root:           [char array]        - method to find root of two cdf intersection
%   fitdistinit:    [1×1 logical]       - advanced initializing approximation of optimization problem
%   fitdistcoef:    [n×m×k double]      - fit approximation coefficients
%   fitdistfilt:    [char array]        - filter name to filter initial fit coefficients
%   fitdistfiltker: [1×2 double]        - filter size to filter initial fit coefficients
%   weight:         [n×m... double]     - gridded window function by shape initial data to perform weighted filtering
%   weightname:     [char array]        - name of window function 
%   weightparam:    [1×k double]        - parameters of window function 
%   distance:       [char array]        - cluster method metric
%   fillholes:      [1×1 logical]       - fill closed domain of processed fields
%   batch:          [1×1 logical]       - clustering of data by all realization
%   cnnversion:     [char array]        - version of convolutional neural network
%   network:        [object]            - instance of sequence network
%   map:            [1×2 double]        - mapping data range to specified
%   crop:           [1×4 double]        - crop data: [x0, y0, width, height]
%
%   kernel:         [1×2 double]        - size of processing window
%   strides:        [1×2 double]        - strides of processing window
%
%   objnorm:        [1×l double]        - norm order at calculation objective function
%   nonlcon:        [funtion_handle]    - non-linear optimization constrain function
%   x0:             [1×k doule]         - inital parameters
%   lb:             [1×k doule]         - lower bound of parameters
%   ub:             [1×k doule]         - upper bpund of parameters

%   mean1:          [1×2 double]         - constraints of mean value the first mode
%   mode1:          [1×2 double]         - constraints of mode value the first mode
%   var1:           [1×2 double]         - constraints of variance value the first mode
%   amp1:           [1×2 double]         - constraints of amplitude value the first mode
%   mean2:          [1×2 double]         - constraints of mean value the second mode
%   mode2:          [1×2 double]         - constraints of mode value the second mode
%   var2:           [1×2 double]         - constraints of variance value the second mode
%   amp2:           [1×2 double]         - constraints of amplitude value the second mode

%   prefilt:        [char array]         - method to filter threshold field
%   prefiltker:     [1×2 double]         - kernel of filtering threshold field

%   postfilt:       [char array]         - method to filter intermittency field
%   postfiltker:    [1×2 double]         - kernel of filtering intermittency field
%% The function returns following results:
%   intermittency:              [n×m double]
%   binarized:                  [n×m... double]
%   threshold:                  [n×m... double]
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
% [interm, binar, thresh] = procinterm(data.dwdl, distname = 'gumbel2', method = 'integral-ratio', ...
%       x0 = [0.7351, 0.0004, 0.0002, 0.2305, 0.0008, 0.0004], lb = [1e-2, 0, 0, 0, 0, 0], ...
%       ub = [2, 5e-3, 5e-3, 2, 5e-3, 5e-3], binedge = linspace(0, 5e-3, 500), ...
%       mode1 = [3e-4, 7e-4], mode2 = [8e-4, 7e-3]);

    arguments
        data double
        %% data parameters
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge double = []
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio', 'cluster', 'cnn', 'cluster-kernel'})} = 'integral-ratio'
        %% intergal algorithm parameters
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
        kwargs.quantile double = 0.9
        kwargs.root (1,:) char {mustBeMember(kwargs.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
        %% advanced fit distribution parameters
        kwargs.fitdistinit logical = true
        kwargs.fitdistcoef double = []
        kwargs.fitdistfilt (1,:) char {mustBeMember(kwargs.fitdistfilt, {'none', 'average', 'gaussian', 'median', 'median-weighted', 'wiener', 'mode'})} = 'median-weighted'
        kwargs.fitdistfiltker double = [50, 50]
        kwargs.weight double = []
        kwargs.weightname (1,:) char {mustBeMember(kwargs.weightname, {'tukeywin'})} = 'tukeywin'
        kwargs.weightparam double = [0.05, 0.05]
        %% cluster algorithm parameters
        kwargs.distance (1,:) char {mustBeMember(kwargs.distance, {'sqeuclidean', 'cityblock', 'cosine', 'correlation', 'hamming'})} = 'sqeuclidean'
        kwargs.fillholes logical = false;
        kwargs.batch logical = true
        %% neural network parameters
        kwargs.cnnversion (1,:) char {mustBeMember(kwargs.cnnversion, {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6'})} = '0.1'
        kwargs.network = []
        kwargs.crop double = [20, 20, 230, 280];
        kwargs.map double = [0, 1.5]
        %% processing parameters
        kwargs.kernel double = [30, 30]
        kwargs.strides double = [5, 5]
        %% optimization parameters
        kwargs.objnorm double = 2
        kwargs.nonlcon = []
        kwargs.x0 double = []
        kwargs.lb double = []
        kwargs.ub double = []
        %% restriction parameters
        kwargs.mean1 double = []
        kwargs.mode1 double = []
        kwargs.var1 double = []
        kwargs.amp1 double = []
        kwargs.mean2 double = []
        kwargs.mode2 double = []
        kwargs.var2 double = []
        kwargs.amp2 double = []
        %% pre-pocessing parameters
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'mode'})} = 'median'
        kwargs.prefiltker double = [15, 15]
        %% post-processing parameters
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'average', 'gaussian', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'mode'})} = 'median'
        kwargs.postfiltker double = [15, 15]
    end

    function result = procfitdistfilt(method)
        if kwargs.fitdistinit
            if isempty(kwargs.fitdistcoef)
                fitdistcoef = procfitdistcoef(data, norm = kwargs.norm, binedge = kwargs.binedge, ...
                    distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon, ...
                    postfilt = kwargs.fitdistfilt, postfiltker = kwargs.fitdistfiltker, ...
                    weight = kwargs.weight, weightname = kwargs.weightname, weightparam = kwargs.weightparam);
            else
                fitdistcoef = kwargs.fitdistcoef;
            end

            nlkernel = @(x, y) fitdistfilter(x, method = method, norm = kwargs.norm, binedge = kwargs.binedge, root = kwargs.root, ...
                quantile = kwargs.quantile, distname = kwargs.distname, x0 = squeeze(median(y, [1, 2], 'omitmissing')), ...
                lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
            result = nlpfilter(data, kwargs.kernel, @(x, y) nlkernel(x, y), strides = kwargs.strides, type = 'deep-cross', y = fitdistcoef, resize = true);
            if method ~= "integral-ratio"
                varargout{4} = fitdistcoef;
            else
                varargout{2} = fitdistcoef;
            end
        else
            nlkernel = @(x) fitdistfilter(x, method = method, norm = kwargs.norm, binedge = kwargs.binedge, root = kwargs.root, ...
                quantile = kwargs.quantile, distname = kwargs.distname, x0 = kwargs.x0, ...
                lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
            result = nlpfilter(data, kwargs.kernel, @(x) nlkernel(x), strides = kwargs.strides, type = 'deep', resize = true);
        end
        if method ~= "integral-ratio"
            result = imagfilter(result, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
        end
    end

    function [intermittency, binarized] = procfitdistbinar(threshold)
        binarized = data ./ threshold; binarized(binarized >= 1) = 1; binarized(binarized < 1) = 0;
        intermittency = mean(binarized, 3, 'omitmissing');
    end

    intermittency = []; binarized = [];

    if isempty(kwargs.nonlcon)
        kwargs.nonlcon = @(x) nonlconfitdist(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    sz = size(data);

    switch kwargs.method
        case 'quantile-threshold'
            threshold = procfitdistfilt('quantile-threshold');
            [intermittency, binarized] = procfitdistbinar(threshold);
            varargout{2} = binarized; varargout{3} = threshold;
        case 'cdf-intersection'
            threshold = procfitdistfilt('cdf-intersection');
            [intermittency, binarized] = procfitdistbinar(threshold);
            varargout{2} = binarized; varargout{3} = threshold;
        case 'integral-ratio'
            intermittency = procfitdistfilt('integral-ratio');
        case 'cluster'
            if kwargs.batch
                [binarized, center, ~, distance] = kmeans(data(:), 2, 'Distance', kwargs.distance);
                binarized = reshape(binarized, size(data));
                distance = reshape(distance, [size(data), 2]);
                [~, index] = max(center);
                switch index
                    case 1
                        binarized = -(binarized - 2);
                    case 2
                        binarized = binarized - 1;
                end
            else
                distance = []; center = [];
                for i = 1:prod(sz(3:end))
                    temporary = data(:, :, i); 
                    [temporary, center(:, i), ~, distance_temp] = kmeans(temporary(:), 2, 'Distance', kwargs.distance);
                    temporary = reshape(temporary, size(data, 1:2));
                    distance(:,:,:,i) = reshape(distance_temp, [size(data, [1, 2]), 2]);
                    [~, index] = max(center(:, i));
                    switch index
                        case 1
                            temporary = -(temporary - 2);
                        case 2
                            temporary = temporary - 1;
                    end
                    binarized(:, :, i) = temporary;
                end
            end
            if kwargs.fillholes
                temporary = [];
                binarized(isnan(binarized)) = 0;
                for i = 1:prod(sz(3:end))
                    temporary(:, :, i) = imfill(binarized(:, :, i), 'holes');
                end
                binarized = reshape(temporary, sz);
            end
            intermittency = squeeze(mean(binarized, 3, 'omitmissing'));
            varargout{2} = binarized;
            varargout{3} = distance;
            varargout{4} = center;
        case 'cnn'
            [intermittency, binarized] = predinterm(data, network = kwargs.network, version = kwargs.cnnversion, crop = kwargs.crop, map = kwargs.map);
            varargout{2} = binarized;
        case 'cluster-kernel'
            nlkernel = @(x) clustfilter(x, k = 2, distance = kwargs.distance);
            intermittency = nlpfilter(data, kwargs.kernel, @(x) nlkernel(x), strides = kwargs.strides, type = 'deep');
            intermittency = imresize(intermittency, sz(1:2));
    end

    % postfiltering
    intermittency = imagfilter(intermittency, filt = kwargs.postfilt, filtker = kwargs.postfiltker);

    varargout{1} = intermittency;

end