function [c, ceq] = nonlcon_cond(options)
%% The function takes following arguments:
%   rmean1:     [1×2 double]        - restrition range of mean value the first mode
%   rmode1:     [1×2 double]        - restrition range of mode value the first mode
%   rvar1:      [1×2 double]        - restrition range of variance value the first mode
%   ramp1:      [1×2 double]        - restrition range of amplitude value the first mode
%   rmean2:     [1×2 double]        - restrition range of mean value the second mode
%   rmode2:     [1×2 double]        - restrition range of mode value the second mode
%   rvar2:      [1×2 double]        - restrition range of variance value the second mode
%   ramp2:      [1×2 double]        - restrition range of amplitude value the second mode
%% The function returns following results:
%   c:          [k×1 double]        - non-linear inequality vector
%   ceq:        [m×1 double]        - non-linear equality vector

    arguments
        options.c double = []
        options.ceq double = []

        options.means double = []
        options.modes double = []
        options.vars double = []
        options.amps double = []

        options.rmean1 double = []
        options.rmode1 double = []
        options.rvar1 double = []
        options.ramp1 double = []

        options.rmean2 double = []
        options.rmode2 double = []
        options.rvar2 double = []
        options.ramp2 double = []
    end

    options.c = [options.c, options.means(1)-options.means(2)];
    options.c = [options.c, options.modes(1)-options.modes(2)];
    options.c = [options.c, options.vars(1)-options.vars(2)];

    %% mode 1
    % mean range restriction
    if ~isempty(options.rmean1)
        options.c = [options.c, options.rmean1(1)-options.means(1)];
        options.c = [options.c, options.means(1)-options.rmean1(2)];
    end

    % mode range restriction
    if ~isempty(options.rmode1)
        options.c = [options.c, options.rmode1(1)-options.modes(1)];
        options.c = [options.c, options.modes(1)-options.rmode1(2)];
    end

    % variance range restriction
    if ~isempty(options.rvar1)
        options.c = [options.c, options.rvar1(1)-options.vars(1)];
        options.c = [options.c, options.vars(1)-options.rvar1(2)];
    end

    % amplitude range restriction
    if ~isempty(options.ramp1)
        options.c = [options.c, options.ramp1(1)-options.amps(1)];
        options.c = [options.c, options.amps(1)-options.ramp1(2)];
    end
    %% mode 2
    % mean range restriction
    if ~isempty(options.rmean2)
        options.c = [options.c, options.rmean2(1)-options.means(2)];
        options.c = [options.c, options.means(2)-options.rmean2(2)];
    end

    % mode range restriction
    if ~isempty(options.rmode2)
        options.c = [options.c, options.rmode2(1)-options.modes(2)];
        options.c = [options.c, options.modes(2)-options.rmode2(2)];
    end

    % variance range restriction
    if ~isempty(options.rvar2)
        options.c = [options.c, options.rvar2(1)-options.vars(2)];
        options.c = [options.c, options.vars(2)-options.rvar2(2)];
    end

    % amplitude range restriction
    if ~isempty(options.ramp2)
        options.c = [options.c, options.ramp2(1)-options.amps(2)];
        options.c = [options.c, options.amps(2)-options.ramp2(2)];
    end

    return [options.c, options.ceq]

end