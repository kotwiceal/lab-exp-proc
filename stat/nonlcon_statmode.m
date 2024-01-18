function [c, ceq] = nonlcon_statmode(x, options)
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
        x double
        options.type (1,:) char {mustBeMember(options.type, {'beta2', 'gumbel2'})} = 'gumbel2'

        options.rmean1 double = []
        options.rmode1 double = []
        options.rvar1 double = []
        options.ramp1 double = []

        options.rmean2 double = []
        options.rmode2 double = []
        options.rvar2 double = []
        options.ramp2 double = []
    end

    c = []; ceq = [];

    switch options.type
        case 'beta2l'
            modes = [1/x(2)*((x(4)-1)/(x(4)+x(5)-2)+x(3)), 1/x(7)*((x(9)-1)/(x(9)+x(10)-2)+x(8))];
            means = [1/x(2)*(x(4)/(x(4)+x(5))+x(3)), 1/x(7)*(x(9)/(x(9)+x(10))+x(8))];
            vars = [x(4)*x(5)/(x(4)+x(5))^2/(x(4)+x(5)+1)/x(2)^2, ...
                x(9)*x(10)/(x(9)+x(10))^2/(x(9)+x(10)+1)/x(7)^2];
            amps = [x(1)*betapdf(x(2)*modes(1)-x(3), x(4), x(5)), x(6)*betapdf(x(7)*modes(2)-x(8), x(9), x(10))]; 
        case 'gumbel2'
            ec = 0.57721;
            modes = [x(2), x(5)];
            means = [x(2)+x(3)*ec, x(5)+x(6)*ec];
            vars = [pi^2/6*x(3)^2, pi^2/6*x(6)^2];
            amps = [x(1)/x(3)*exp(-(modes(1)-x(2))/x(3)-exp(-(modes(1)-x(2))/x(3))), ...
                x(4)/x(6)*exp(-(modes(2)-x(5))/x(6)-exp(-(modes(2)-x(5))/x(6)))];
    end

    c = [c, means(1)-means(2)];
    c = [c, modes(1)-modes(2)];
    c = [c, vars(1)-vars(2)];

    %% mode 1
    % mean range restriction
    if ~isempty(options.rmean1)
        c = [c, options.rmean1(1)-means(1)];
        c = [c, means(1)-options.rmean1(2)];
    end

    % mode range restriction
    if ~isempty(options.rmode1)
        c = [c, options.rmode1(1)-modes(1)];
        c = [c, modes(1)-options.rmode1(2)];
    end

    % variance range restriction
    if ~isempty(options.rvar1)
        c = [c, options.rvar1(1)-vars(1)];
        c = [c, vars(1)-options.rvar1(2)];
    end

    % amplitude range restriction
    if ~isempty(options.ramp1)
        c = [c, options.ramp1(1)-amps(1)];
        c = [c, amps(1)-options.ramp1(2)];
    end
    %% mode 2
    % mean range restriction
    if ~isempty(options.rmean2)
        c = [c, options.rmean2(1)-means(2)];
        c = [c, means(2)-options.rmean2(2)];
    end

    % mode range restriction
    if ~isempty(options.rmode2)
        c = [c, options.rmode2(1)-modes(2)];
        c = [c, modes(2)-options.rmode2(2)];
    end

    % variance range restriction
    if ~isempty(options.rvar2)
        c = [c, options.rvar2(1)-vars(2)];
        c = [c, vars(2)-options.rvar2(2)];
    end

    % amplitude range restriction
    if ~isempty(options.ramp2)
        c = [c, options.ramp2(1)-amps(2)];
        c = [c, amps(2)-options.ramp2(2)];
    end

end