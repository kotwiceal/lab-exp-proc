function [c, ceq] = nonlconfitdist(x, kwargs)
    %% Non-linear constraint function for two mode distribution fitting

    arguments
        x double % parameter vector
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'gamma2', 'beta2', 'beta2l', 'gumbel2'})} = 'gumbel2'

        kwargs.mean1 (1,:) double = [] % constraints of mean value the first mode
        kwargs.mode1 (1,:) double = [] % constraints of mode value the first mode
        kwargs.var1 (1,:) double = [] % constraints of variance value the first mode
        kwargs.amp1 (1,:) double = [] % constraints of amplitude value the first mode

        kwargs.mean2 (1,:) double = [] % constraints of mean value the second mode
        kwargs.mode2 (1,:) double = [] % constraints of mode value the second mode
        kwargs.var2 (1,:) double = [] % constraints of variance value the second mode
        kwargs.amp2 (1,:) double = [] % constraints of amplitude value the second mode
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