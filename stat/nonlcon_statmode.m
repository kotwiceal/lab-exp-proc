function [c, ceq] = nonlcon_statmode(x, kwargs)
%% Non-linear constraint function for two mode distribution fitting
%% The function takes following arguments:
%   x:         [1×n double]         - parameter vector
%   distname:  [char array]         - approximation distribution name
%   mean1:     [1×2 double]         - constraints of mean value the first mode
%   mode1:     [1×2 double]         - constraints of mode value the first mode
%   var1:      [1×2 double]         - constraints of variance value the first mode
%   amp1:      [1×2 double]         - constraints of amplitude value the first mode
%   mean2:     [1×2 double]         - constraints of mean value the second mode
%   mode2:     [1×2 double]         - constraints of mode value the second mode
%   var2:      [1×2 double]         - constraints of variance value the second mode
%   amp2:      [1×2 double]         - constraints of amplitude value the second mode
%% The function returns following results:
%   c:          [k×1 double]        - non-linear inequality vector
%   ceq:        [m×1 double]        - non-linear equality vector

    arguments
        x double
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'

        kwargs.mean1 double = []
        kwargs.mode1 double = []
        kwargs.var1 double = []
        kwargs.amp1 double = []

        kwargs.mean2 double = []
        kwargs.mode2 double = []
        kwargs.var2 double = []
        kwargs.amp2 double = []
    end

    c = []; ceq = [];

    param = distparam(x, distname = kwargs.distname);
    modes = param.mode;
    means = param.mean;
    vars = param.variance;
    amps = param.amplitude;

    c = [c, means(1)-means(2)];
    c = [c, modes(1)-modes(2)];
    c = [c, vars(1)-vars(2)];

    %% mode 1
    % mean range restriction
    if ~isempty(kwargs.mean1)
        c = [c, kwargs.mean1(1)-means(1)];
        c = [c, means(1)-kwargs.mean1(2)];
    end

    % mode range restriction
    if ~isempty(kwargs.mode1)
        c = [c, kwargs.mode1(1)-modes(1)];
        c = [c, modes(1)-kwargs.mode1(2)];
    end

    % variance range restriction
    if ~isempty(kwargs.var1)
        c = [c, kwargs.var1(1)-vars(1)];
        c = [c, vars(1)-kwargs.var1(2)];
    end

    % amplitude range restriction
    if ~isempty(kwargs.amp1)
        c = [c, kwargs.amp1(1)-amps(1)];
        c = [c, amps(1)-kwargs.amp1(2)];
    end
    %% mode 2
    % mean range restriction
    if ~isempty(kwargs.mean2)
        c = [c, kwargs.mean2(1)-means(2)];
        c = [c, means(2)-kwargs.mean2(2)];
    end

    % mode range restriction
    if ~isempty(kwargs.mode2)
        c = [c, kwargs.mode2(1)-modes(2)];
        c = [c, modes(2)-kwargs.mode2(2)];
    end

    % variance range restriction
    if ~isempty(kwargs.var2)
        c = [c, kwargs.var2(1)-vars(2)];
        c = [c, vars(2)-kwargs.var2(2)];
    end

    % amplitude range restriction
    if ~isempty(kwargs.amp2)
        c = [c, kwargs.amp2(1)-amps(2)];
        c = [c, amps(2)-kwargs.amp2(2)];
    end

end