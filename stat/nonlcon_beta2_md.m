function [c, ceq] = nonlcon_beta2_md(x, rmean1, rmode1, rvar1, ramp1, rmean2, rmode2, rvar2, ramp2)
%% The function takes following arguments:
%   x:          [n×1 double]        - optimization vector
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
        rmean1 double = []
        rmode1 double = []
        rvar1 double = []
        ramp1 double = []
        rmean2 double = []
        rmode2 double = []
        rvar2 double = []
        ramp2 double = []
    end

    c = []; ceq = []; 

    modes = [1/x(2)*((x(4)-1)/(x(4)+x(5)-2)+x(3)), 1/x(7)*((x(9)-1)/(x(9)+x(10)-2)+x(8))];
    means = [1/x(2)*(x(4)/(x(4)+x(5))+x(3)), 1/x(7)*(x(9)/(x(9)+x(10))+x(8))];
    vars = [x(4)*x(5)/(x(4)+x(5))^2/(x(4)+x(5)+1)/x(2)^2, ...
        x(9)*x(10)/(x(9)+x(10))^2/(x(9)+x(10)+1)/x(7)^2];
    amps = [x(1)*betapdf(x(2)*modes(1)-x(3), x(4), x(5)), x(6)*betapdf(x(7)*modes(2)-x(8), x(9), x(10))]; 

    c = [c, means(1)-means(2)];
    c = [c, modes(1)-modes(2)];
    c = [c, vars(1)-vars(2)];
    
    %% mode 1
    % mean range restriction
    if ~isempty(rmean1)
        c = [c, rmean1(1)-means(1)];
        c = [c, means(1)-rmean1(2)];
    end

    % mode range restriction
    if ~isempty(rmode1)
        c = [c, rmode1(1)-modes(1)];
        c = [c, modes(1)-rmode1(2)];
    end

    % variance range restriction
    if ~isempty(rvar1)
        c = [c, rvar1(1)-vars(1)];
        c = [c, vars(1)-rvar1(2)];
    end

    % amplitude range restriction
    if ~isempty(ramp1)
        c = [c, ramp1(1)-amps(1)];
        c = [c, amps(1)-ramp1(2)];
    end
    %% mode 2
    % mean range restriction
    if ~isempty(rmean2)
        c = [c, rmean2(1)-means(2)];
        c = [c, means(2)-rmean2(2)];
    end

    % mode range restriction
    if ~isempty(rmode2)
        c = [c, rmode2(1)-modes(2)];
        c = [c, modes(2)-rmode2(2)];
    end

    % variance range restriction
    if ~isempty(rvar2)
        c = [c, rvar2(1)-vars(2)];
        c = [c, vars(2)-rvar2(2)];
    end

    % amplitude range restriction
    if ~isempty(ramp2)
        c = [c, ramp2(1)-amps(2)];
        c = [c, amps(2)-ramp2(2)];
    end
end