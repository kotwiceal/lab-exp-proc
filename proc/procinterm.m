function [intermittency, binarized] = procinterm(data, named)
%% Interactive intermittency processing.
%% The function takes following arguments:
%   norm:           [char array]                    - type of statistics normalization
%   binedge:        [double]                        - bins count or edge grid

%   method:         [char array]                    - intermittency algorithm processing
%   dist:           [char array]                    - statistics approximation type
%   quantile:       [1×1 double]                    - quantile threshold at method='quantile-threshold'

%   kernel:         [1×2 double]                    - size of window processing in which statistic parameters are estimated
%   strides:        [1×2 double]                    - window processing strides

%   objnorm:        [1×1 double]                    - norm order at calculation objective function
%   x0:             [1×k doule]                     - inital approximation
%   lb:             [1×k doule]                     - lower bound of parameters
%   ub:             [1×k doule]                     - upper bpund of parameters

%   mean1:     [1×2 double]         - constraints of mean value the first mode
%   mode1:     [1×2 double]         - constraints of mode value the first mode
%   var1:      [1×2 double]         - constraints of variance value the first mode
%   amp1:      [1×2 double]         - constraints of amplitude value the first mode
%   mean2:     [1×2 double]         - constraints of mean value the second mode
%   mode2:     [1×2 double]         - constraints of mode value the second mode
%   var2:      [1×2 double]         - constraints of variance value the second mode
%   amp2:      [1×2 double]         - constraints of amplitude value the second mode

%   smooth_intermittency:   [1×2 double]  - kernel of median filter for smooth intermittency field
%   smooth_threshold:       [1×2 double]  - kernel of median filter for smooth threshold field
%% The function returns following results:
%   intermittency:  [n×m double]
%   binarized:      [n×m×k double] 

    arguments
        data double
        %% data parameters
        named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        named.binedge double = []
        %% algorithm parameters
        named.method (1,:) char {mustBeMember(named.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio'})} = 'integral-ratio'
        named.dist (1,:) char {mustBeMember(named.dist, {'gauss2', 'beta2', 'gamma2', 'gumbel2'})} = 'gumbel2'
        named.quantile double = 0.05
        %% processing parameters
        named.kernel double = [30, 30]
        named.strides double = [5, 5]
        %% optimization parameters
        named.objnorm double = 2
        named.nonlcon = []
        named.x0 double = []
        named.lb double = []
        named.ub double = []
        %% restriction parameters
        named.mean1 double = []
        named.mode1 double = [1e-4,6e-4]
        named.var1 double = [1e-8,1e-7]
        named.amp1 double = []
        named.mean2 double = []
        named.mode2 double = [7e-4,5e-3]
        named.var2 double = [1e-7,1e-5]
        named.amp2 double = []
        %% post-processing parameters
        named.smooth_intermittency double = [15, 15]
        named.smooth_threshold double = [15, 15]
    end

    intermittency = []; binarized = [];

    if isempty(named.nonlcon)
        named.nonlcon = @(x) nonlcon_statmode(x, type = named.dist, mean1 = named.mean1, mode1 = named.mode1, ...
            var1 = named.var1, amp1 = named.amp1, mean2 = named.mean2, mode2 = named.mode2, var2 = named.var2, amp2 = named.amp2);
    end

    sz = size(data);

    switch named.method
        case 'quantile-threshold'
            nlkernel = @(x) qntlfilter(x, quantile = named.quantile, norm = named.norm, binedge = named.binedge, ...
                type = named.dist, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            threshold = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            if ~isempty(named.smooth_threshold); threshold = medfilt2(threshold, named.smooth_threshold); end
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3);
        case 'cdf-intersection'
            nlkernel = @(x) cdfintfilter(x, norm = named.norm, binedge = named.binedge, ...
                type = named.dist, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            threshold = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            if ~isempty(named.smooth_threshold); threshold = medfilt2(threshold, named.smooth_threshold); end
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3);
        case 'integral-ratio'
            nlkernel = @(x) intrelfilter(x, norm = named.norm, binedge = named.binedge, ...
                type = named.dist, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            intermittency = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            intermittency = imresize(intermittency, sz(1:2));
    end

    if ~isempty(named.smooth_intermittency); intermittency = medfilt2(intermittency, named.smooth_intermittency); end

end