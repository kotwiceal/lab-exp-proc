%% wire/yz-scan
load('files/data/cta_f37.8hz_u31.2mps_x270mm_yz_scan_single_rough_h260um_date20251113.mat')
data = prepcta(data, storeraw = true);
data.raw = data.raw(:,:,:,1);
%%
data.dudt = prepinterm(data, type = 'dt', diffilt = 'sobel', ...
    dirdim = 3, postfilt = 'median', postfiltker = 50);
%%
clc
rpos = {[175,2],[180,2]};
cellprobe('contourf','plot',@(x)x{:},[1,2],data.z,data.y,data.vm,...
    {data.raw,data.dudt},draw='drawpoint',axis={'equal','auto'},...
    xlim={'auto',[1,200]},rposition=rpos,rnumber=2)
%%
clc
rpos = {[175,2],[180,2]};
cellprobe('contourf','plot',@(x)x{:},[1,2],data.z,data.y,data.vm,...
    {data.raw,data.dudt},draw='drawpoint',axis={'equal','auto'},...
    xlim={'auto',[1,200]},rposition=rpos,rgroup=[1,2],rnumber=2)
%%
clc
rpos = {[175,2]};
bins = linspace(0,20,200);
cellprobe('contourf','plot',@(x)histcounts(x{:},bins,'Normalization','pdf'),...
    [1,2],data.z,data.y,data.vm,...
    bins(2:end)',data.dudt,draw='drawpoint',axis={'equal','auto'},...
    xlim={'auto'},rposition=rpos,rnumber=2)
%%
tic
[coef, modes] = fithist(linspace(0,20,100),data.dudt,filtdim=3,kernel=nan,padval=false,...
    dist={'gamma'},x0=[1,0.5,0.5],lb=zeros(1,3),ub=ones(1,3),mode=[4,10]);
toc
modes = permute(modes, [2, 3, 1]);
%%
cellprobe('contourf','plot',@(x)histcounts(x{:},bins,'Normalization','pdf'),...
    [1,2],data.z,data.y,data.vm,...
    bins(2:end)',modes,draw='drawpoint',axis={'equal','auto'},...
    xlim={'auto'},rposition=rpos,rnumber=2)
%%
function [coef, modes] = fithist(bins,data,filt,param,const,prob)
    arguments
        bins
        data
        %% nonlinfilt
        filt.kernel (1,:) double = []
        % filt.stride (1,:) double = []
        filt.filtdim (1,:) double = []
        filt.padval (1,:) = false
        %% histcount
        param.norm (1,:) char {mustBeMember(param.norm, {'count', 'pdf', 'probability', 'percentage', 'countdensity'})} = 'pdf'
        %% optimization
        param.dist {mustBeMember(param.dist, {'chi', 'beta', 'gamma', 'gumbel'})} = 'beta' % approximation distribution name
        param.objnorm (1,1) double = 2 % norm order at calculation objective function
        param.mb (1,:) double = [0, 10]; % scale range of auto constrains
        param.verbose (1,1) logical = false % display optimization result and distribution parameters
        const.mean (1,:) {mustBeA(const.mean, {'double', 'cell'})} = []
        const.mode (1,:) {mustBeA(const.mode, {'double', 'cell'})} = [] 
        const.var (1,:) {mustBeA(const.var, {'double', 'cell'})} = []
        const.amp (1,:) {mustBeA(const.amp, {'double', 'cell'})} = []
        %% fmincon
        prob.x0 (1,:) double = [] % inital parameters
        prob.Aeq (:,:) double = [] % linear optimization equality constrain matrix
        prob.beq (1,:) double = [] % linear optimization equality constrain right side
        prob.Aineq (:,:) double = [] % linear optimization inequality constrain matrix
        prob.bineq (1,:) double = [] % linear optimization inequality constrain right side
        prob.lb (1,:) double = [] % lower bound of parameters
        prob.ub (1,:) double = [] % upper bpund of parameters
        prob.nonlcon = [] % non-linear optimization constrain function
    end
  
    % process a statistical distribution
    filt = namedargs2cell(filt);
    hist = nonlinfilt(@(x, ~) histcounts(x(:), bins, 'Normalization', param.norm), data, filt{:});
    bins = bins(2:end)-diff(bins)/2;

    % assembly approximation distribution
    funcs = struct(chi = @chi2pdf, beta = @betapdf, gamma = @gampdf, gumbel = @evpdf);
    funcs = structfun(@(f) @(a, x) a{1}*f(x, a{2:end}), funcs, UniformOutput = false);
    sarg = struct(chi = 2, beta = 3, gamma = 3, gumbel = 3);
    narg = cellfun(@(d) sarg.(d), param.dist);
    index = mat2cell(1:sum(narg), 1, narg);
    % statistical mode functions
    fstatmode = @(p) cellfun(@(d,i) funcs.(d)(num2cell(p(i)), bins), param.dist, index, 'UniformOutput', false);
    % approximation function
    if isscalar(param.dist)
        fapprox = @(a) cell2arr(fstatmode(a));
    else
        fapprox = @(a) sum(cell2arr(fstatmode(a)), 2);
    end
    % objective function
    fobj = @(a, x) norm(excludeundef(fapprox(a)-x), param.objnorm);

    distparams = @(p) cell2mat(cellfun(@(d,i) dparam(p(i), d), param.dist(:), index(:), 'UniformOutput', false));

    % inequality constraints
    const = structfun(@(s) terop(isempty(s), nan(1,2), s), const, 'UniformOutput', false);
    const = parseargs(numel(param.dist), const, ans = 'struct');
    const = namedargs2cell(const);
    const = permute(cell2arr(cellfun(@(varargin) cat(1, varargin{:}), const{2:2:end}, ...
        'UniformOutput', false)), [3, 1, 2]);

    % process an approximation distribution
    prob.nonlcon = @nonlcon; % non-linear optimization constrain function
    args = namedargs2cell(prob);
    coef = nonlinfilt(@(x, ~) fmincon(@(a) fobj(a, x), args{2:2:end}), hist, ...
        kernel = nan, padval = false);

    modes = nonlinfilt(@(x, ~) fapprox(x), coef, ...
        kernel = nan, padval = false);

    function [c, ceq] = nonlcon(x)
        ceq = [];
        c = excludeundef(distparams(x)-const);
    end

    function y = excludeundef(x)
        y = x(~isnan(x)&~isinf(x));
    end

    function p = dparam(x, dist)   
        switch dist
            case 'chi'
                dmean = x(1);
                dmode = max([0, x(1)-2]);
                dvar = 2*x(1);
                damp = chi2pdf(dmode, x(1));
            case 'beta'
                dmean = x(2)/(x(2)+x(3));
                dmode = (x(2)-1)/(x(2)+x(3)-2);
                dvar = x(2)*x(3)/(x(2)+x(3))^2/(x(2)+x(3)+1);
                damp = x(1)*betapdf(dmode, x(2), x(3));
            case 'gamma'
                dmean = x(2)*x(3);
                if (x(2) >= 1)
                    dmode = (x(2)-1)*x(3);
                    damp = x(1)*gampdf(dmode, x(2), x(3));
                else
                    dmode = 0;
                    damp = nan;
                end
                dvar = x(2)*x(3)^2;
            case 'gumbel'
                ec = 0.57721;
                dmean = x(2)+x(3)*ec;
                dmode = x(2);
                dvar = pi^2/6*x(3)^2;
                damp = x(1)*evpdf(dmode, x(2), x(3));
        end
        p = [dmean, dmode, dvar, damp];
    end

end