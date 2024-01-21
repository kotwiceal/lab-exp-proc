function [intermittency, binarized] = procinterm(data, named)
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

%   smooth_intermittency: [1×2 double]      - smooth kernel of imtermittensy field
%   smooth_threshold: [1×2 double]          - smooth kernel of threshold field

    arguments
        data double
        %% data parameters
        named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        named.binedge double = []
        %% algorithm parameters
        named.method (1,:) char {mustBeMember(named.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio'})} = 'integral-ratio'
        named.distname (1,:) char {mustBeMember(named.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
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
        named.rmean1 double = []
        named.rmode1 double = [1e-4,6e-4]
        named.rvar1 double = [1e-8,1e-7]
        named.ramp1 double = []
        named.rmean2 double = []
        named.rmode2 double = [7e-4,5e-3]
        named.rvar2 double = [1e-7,1e-5]
        named.ramp2 double = []
        %% post-processing parameters
        named.smooth_intermittency double = [15, 15]
        named.smooth_threshold double = [15, 15]
    end

    intermittency = []; binarized = [];

    if isempty(named.nonlcon)
        named.nonlcon = @(x) nonlcon_statmode(x, distname = named.distname, rmean1 = named.rmean1, rmode1 = named.rmode1, ...
            rvar1 = named.rvar1, ramp1 = named.ramp1, rmean2 = named.rmean2, rmode2 = named.rmode2, rvar2 = named.rvar2, ramp2 = named.ramp2);
    end

    sz = size(data);

    switch named.method
        case 'quantile-threshold'
            nlkernel = @(x) qntlfilter(x, quantile = named.quantile, norm = named.norm, binedge = named.binedge, ...
                distname = named.distname, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            threshold = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            if ~isempty(named.smooth_threshold); threshold = medfilt2(threshold, named.smooth_threshold); end
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3);
        case 'cdf-intersection'
            nlkernel = @(x) cdfintfilter(x, norm = named.norm, binedge = named.binedge, ...
                distname = named.distname, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            threshold = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            if ~isempty(named.smooth_threshold); threshold = medfilt2(threshold, named.smooth_threshold); end
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3);
        case 'integral-ratio'
            nlkernel = @(x) intrelfilter(x, norm = named.norm, binedge = named.binedge, ...
                distname = named.distname, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            intermittency = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            intermittency = imresize(intermittency, sz(1:2));
    end

    if ~isempty(named.smooth_intermittency); intermittency = medfilt2(intermittency, named.smooth_intermittency); end

end