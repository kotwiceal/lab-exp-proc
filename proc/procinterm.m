function varargout = procinterm(data, named)
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

%   prefitler:      [char array]         - method to filter threshold field
%   prefiltkernel:  [1×2 double]         - kernel of filtering threshold field

%   postfitler:     [char array]         - method to filter intermittency field
%   postfiltkernel: [1×2 double]         - kernel of filtering intermittency field
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
        named.norm (1,:) char {mustBeMember(named.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        named.binedge double = []
        %% algorithm parameters
        named.method (1,:) char {mustBeMember(named.method, {'quantile-threshold', 'cdf-intersection', 'integral-ratio'})} = 'integral-ratio'
        named.distname (1,:) char {mustBeMember(named.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
        named.quantile double = 0.2
        named.root (1,:) char {mustBeMember(named.root, {'diff', 'fsolve', 'fminbnd'})} = 'diff'
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
        %% pre-pocessing parameters
        named.prefilter (1,:) char {mustBeMember(named.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'median'
        named.prefiltkernel double = [15, 15]
        %% post-processing parameters
        named.postfitler (1,:) char {mustBeMember(named.postfitler, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'median'
        named.postfiltkernel double = [15, 15]
    end

    intermittency = []; binarized = [];

    if isempty(named.nonlcon)
        named.nonlcon = @(x) nonlcon_statmode(x, distname = named.distname, rmean1 = named.rmean1, rmode1 = named.rmode1, ...
            rvar1 = named.rvar1, ramp1 = named.ramp1, rmean2 = named.rmean2, rmode2 = named.rmode2, rvar2 = named.rvar2, ramp2 = named.ramp2);
    end

    sz = size(data);

    switch named.method
        case 'quantile-threshold'
            nlkernel = @(x) qntlfilter(x, quantile = named.quantile, norm = named.norm, binedge = named.binedge, root = named.root, ...
                distname = named.distname, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            threshold = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            switch named.prefilter
                case 'median'
                    threshold = medfilt2(threshold, named.prefiltkernel);
                case 'wiener'
                    threshold = wiener2(threshold, named.prefiltkernel);
                case 'gaussian'
                    threshold = imfilter(threshold, fspecial('gaussian', named.prefiltkernel));
                case 'average'
                    threshold = imfilter(threshold, fspecial('average', named.prefiltkernel));
            end
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3);
            varargout{2} = binarized;
            varargout{3} = threshold;
        case 'cdf-intersection'
            nlkernel = @(x) cdfintfilter(x, norm = named.norm, binedge = named.binedge, root = named.root, ...
                distname = named.distname, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            threshold = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            threshold = imresize(threshold, sz(1:2));
            switch named.prefilter
                case 'median'
                    threshold = medfilt2(threshold, named.prefiltkernel);
                case 'wiener'
                    threshold = wiener2(threshold, named.prefiltkernel);
                case 'gaussian'
                    threshold = imfilter(threshold, fspecial('gaussian', named.prefiltkernel));
                case 'average'
                    threshold = imfilter(threshold, fspecial('average', named.prefiltkernel));
            end
            binarized = data ./ threshold;
            binarized(binarized >= 1) = 1;
            binarized(binarized < 1) = 0;
            intermittency = mean(binarized, 3);
            varargout{2} = binarized;
            varargout{3} = threshold;
        case 'integral-ratio'
            nlkernel = @(x) intrelfilter(x, norm = named.norm, binedge = named.binedge, ...
                distname = named.distname, x0 = named.x0, lb = named.lb, ub = named.ub, nonlcon = named.nonlcon);
            intermittency = nlpfilter(data, named.kernel, @(x) nlkernel(x), strides = named.strides, type = 'deep');
            intermittency = imresize(intermittency, sz(1:2));
    end

    switch named.postfitler
        case 'median'
            intermittency = medfilt2(intermittency, named.postfiltkernel);
        case 'wiener'
            intermittency = wiener2(intermittency, named.postfiltkernel);
        case 'gaussian'
            intermittency = imfilter(intermittency, fspecial('gaussian', named.postfiltkernel));
        case 'average'
            intermittency = imfilter(intermittency, fspecial('average', named.postfiltkernel));
    end

    varargout{1} = intermittency;

end