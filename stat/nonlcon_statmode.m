function [c, ceq] = nonlcon_statmode(x, options)
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
        options.distname (1,:) char {mustBeMember(options.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'

        options.mean1 double = []
        options.mode1 double = []
        options.var1 double = []
        options.amp1 double = []

        options.mean2 double = []
        options.mode2 double = []
        options.var2 double = []
        options.amp2 double = []
    end

    c = []; ceq = [];

    param = distparam(x, distname = options.distname);
    modes = param.mode;
    means = param.mean;
    vars = param.variance;
    amps = param.amplitude;

    c = [c, means(1)-means(2)];
    c = [c, modes(1)-modes(2)];
    c = [c, vars(1)-vars(2)];

    %% mode 1
    % mean range restriction
    if ~isempty(options.mean1)
        c = [c, options.mean1(1)-means(1)];
        c = [c, means(1)-options.mean1(2)];
    end

    % mode range restriction
    if ~isempty(options.mode1)
        c = [c, options.mode1(1)-modes(1)];
        c = [c, modes(1)-options.mode1(2)];
    end

    % variance range restriction
    if ~isempty(options.var1)
        c = [c, options.var1(1)-vars(1)];
        c = [c, vars(1)-options.var1(2)];
    end

    % amplitude range restriction
    if ~isempty(options.amp1)
        c = [c, options.amp1(1)-amps(1)];
        c = [c, amps(1)-options.amp1(2)];
    end
    %% mode 2
    % mean range restriction
    if ~isempty(options.mean2)
        c = [c, options.mean2(1)-means(2)];
        c = [c, means(2)-options.mean2(2)];
    end

    % mode range restriction
    if ~isempty(options.mode2)
        c = [c, options.mode2(1)-modes(2)];
        c = [c, modes(2)-options.mode2(2)];
    end

    % variance range restriction
    if ~isempty(options.var2)
        c = [c, options.var2(1)-vars(2)];
        c = [c, vars(2)-options.var2(2)];
    end

    % amplitude range restriction
    if ~isempty(options.amp2)
        c = [c, options.amp2(1)-amps(2)];
        c = [c, amps(2)-options.amp2(2)];
    end

end