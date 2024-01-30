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
%% process intermittency by default settings
% procinterm(data.dwdl)
%% process intermittency by custom settings
% % constrain function
% nonlcon = @(x) nonlcon_statmode(x,distname='gumbel2',mode1=[1e-4,6e-4],var1=[1e-8,1e-7],mode2=[7e-4,5e-3],var2=[1e-7,1e-5]);
% % boundary constrains
% lb = [0, 0, 0, 0, 0, 0];
% ub = [2, 5e-3, 5e-3, 2, 5e-3, 5e-3];
% % initial approximation
% x0 = [0.80857,0.00027965,0.000113,0.19571,0.00060174,0.00039031];
% [interm, binar, thresh] = procinterm(data.dwdl,distname='gumbel2',method='cdf-intersection', ...
%     x0=x0,lb=lb,ub=ub,nonlcon=nonlcon,binedge=linspace(0,5e-3,500),root='fminbnd');

    arguments
        data double
        %% data parameters
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge double = []
        %% algorithm parameters
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio', 'cluster', 'cnn', 'cluster-kernel'})} = 'integral-ratio'
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
        kwargs.quantile double = 0.2
        kwargs.root (1,:) char {mustBeMember(kwargs.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
        kwargs.distance (1,:) char {mustBeMember(kwargs.distance, {'sqeuclidean', 'cityblock', 'cosine', 'correlation', 'hamming'})} = 'sqeuclidean'
        kwargs.fillholes logical = false;
        kwargs.batch logical = true
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
        kwargs.mode1 double = [1e-4,6e-4]
        kwargs.var1 double = [1e-8,1e-7]
        kwargs.amp1 double = []
        kwargs.mean2 double = []
        kwargs.mode2 double = [7e-4,5e-3]
        kwargs.var2 double = [1e-7,1e-5]
        kwargs.amp2 double = []
        %% pre-pocessing parameters
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'median'
        kwargs.prefiltker double = [15, 15]
        %% post-processing parameters
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'median'
        kwargs.postfiltker double = [15, 15]
    end

    intermittency = []; binarized = [];

    if isempty(kwargs.nonlcon)
        kwargs.nonlcon = @(x) nonlcon_statmode(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    sz = size(data);

    switch kwargs.method
        case 'quantile-threshold'
            nlkernel = @(x) qntlfilter(x, quantile = kwargs.quantile, norm = kwargs.norm, binedge = kwargs.binedge, root = kwargs.root, ...
                distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
            threshold = nlpfilter(data, kwargs.kernel, @(x) nlkernel(x), strides = kwargs.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            threshold = imagfilter(threshold, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3, 'omitmissing');
            varargout{2} = binarized;
            varargout{3} = threshold;
        case 'cdf-intersection'
            nlkernel = @(x) cdfintfilter(x, norm = kwargs.norm, binedge = kwargs.binedge, root = kwargs.root, ...
                distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
            threshold = nlpfilter(data, kwargs.kernel, @(x) nlkernel(x), strides = kwargs.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            threshold = imagfilter(threshold, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3, 'omitmissing');
            varargout{2} = binarized;
            varargout{3} = threshold;
        case 'integral-ratio'
            nlkernel = @(x) intrelfilter(x, norm = kwargs.norm, binedge = kwargs.binedge, ...
                distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);
            intermittency = nlpfilter(data, kwargs.kernel, @(x) nlkernel(x), strides = kwargs.strides, type = 'deep');
            intermittency = imresize(intermittency, sz(1:2));
        case 'cluster'
            if kwargs.batch
                [binarized, center] = kmeans(data(:), 2, 'Distance', kwargs.distance);
                binarized = reshape(binarized, size(data));
                [~, index] = max(center);
                switch index
                    case 1
                        binarized = -(binarized - 2);
                    case 2
                        binarized = binarized - 1;
                end
            else
                for i = 1:size(data, 3)
                    temporary = data(:, :, i); 
                    [temporary, center] = kmeans(temporary(:), 2, 'Distance', kwargs.distance);
                    temporary = reshape(temporary, size(data, 1:2));
                    [~, index] = max(center);
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
                binarized(isnan(binarized)) = 0;
                for i = 1:size(data, 3)
                    binarized(:, :, i) = imfill(binarized(:, :, i), 'holes');
                end
            end
            intermittency = mean(binarized, 3, 'omitmissing');
            varargout{2} = binarized;
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