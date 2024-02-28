function fitdistcoef =  procfitdistcoef(data, kwargs)
%% Fit statistical distribution by theoretical distributions.
%% The function takes following arguments:
%   data:           [n×m... double]     - multidimensional data
%   norm:           [char]              - type of statistics normalization
%   binedge:        [1×l double]        - bins count or edge grid 
%   distname:       [char array]        - type of statistics fit

%   fitdistinit:    [1×1 logical]       - advanced initializing approximation of optimization problem
%   fitdistcoef:    [n×m×k double]      - fit approximation coefficients
%   fitdistfilt:    [char array]        - filter name to filter initial fit coefficients
%   fitdistfiltker: [1×2 double]        - filter size to filter initial fit coefficients
%   weight:         [n×m... double]     - gridded window function by shape initial data to perform weighted filtering
%   weightname:     [char array]        - name of window function 
%   weightparam:    [1×k double]        - parameters of window function 

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

%   postfilt:       [char array]         - method to filter intermittency field
%   postfiltker:    [1×2 double]         - kernel of filtering intermittency field
%% The function returns following results:
%   fitdistcoef:    [n×m... double]      - fit coefficients
%% Examples:
%% 1. Fit distribution of directed velocity gradient by bimode gumbel distribution with custom restrictions:
% fitdistcoef = procfitdistcoef(data.dwdl, distname = 'gumbel2', mode1 = mode1, var1 = var1, ...
%     mode2 = mode2, var2 = var2, binedge = binedge, x0 = x0, lb = lb, ub = ub, ...
%     strides = [5, 5], kernel = [30, 30], postfilt = 'none');

    arguments
        data double
        %% data parameters
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        kwargs.binedge double = []
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'
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
        %% post-pocessing parameters
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'average', 'gaussian', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'mode'})} = 'median-weighted'
        kwargs.postfiltker double = [50, 50]
        kwargs.weight double = []
        kwargs.weightname (1,:) char {mustBeMember(kwargs.weightname, {'tukeywin'})} = 'tukeywin'
        kwargs.weightparam double = [0.05, 0.05]
    end

    if isempty(kwargs.nonlcon)
        kwargs.nonlcon = @(x) nonlconfitdist(x, distname = kwargs.distname, mean1 = kwargs.mean1, mode1 = kwargs.mode1, ...
            var1 = kwargs.var1, amp1 = kwargs.amp1, mean2 = kwargs.mean2, mode2 = kwargs.mode2, var2 = kwargs.var2, amp2 = kwargs.amp2);
    end

    nlkernel = @(x) fitdistfilter(x, method = 'fitdistcoef', norm = kwargs.norm, binedge = kwargs.binedge, ...
        distname = kwargs.distname, x0 = kwargs.x0, lb = kwargs.lb, ub = kwargs.ub, nonlcon = kwargs.nonlcon);

    if isvector(data); type = 'slice'; resize = false; else; type = 'deep'; resize = true; end
    fitdistcoef = nlpfilter(data, kwargs.kernel, @(x) nlkernel(x), strides = kwargs.strides, type = type, resize = resize);
    
    fitdistcoef = imagfilter(fitdistcoef, filt = kwargs.postfilt, filtker = kwargs.postfiltker, ...
        weight = kwargs.weight, weightname = kwargs.weightname, weightparam = kwargs.weightparam);
end