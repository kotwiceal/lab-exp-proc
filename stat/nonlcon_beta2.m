function [c, ceq] = nonlcon_beta2(x, named)
%% The function takes following arguments:
%   x:          [n×1 double]        - optimization vector
%   rmean1:     [1×2 double]        - restrition range of mean value the first mode
%   rmode1:     [1×2 double]        - restrition range of mode value the first mode
%   rvar1:      [1×2 double]        - restrition range of variance value the first mode
%   rmean2:     [1×2 double]        - restrition range of mean value the second mode
%   rmode2:     [1×2 double]        - restrition range of mode value the second mode
%   rvar2:      [1×2 double]        - restrition range of variance value the second mode
%   regul:      [1×3 double]        - regularization parameters of statistical moments relation 
%% The function returns following results:
%   c:          [k×1 double]        - non-linear inequality vector
%   ceq:        [m×1 double]        - non-linear equality vector

    arguments
        x double
        named.rmean1 double = []
        named.rmode1 double = []
        named.rvar1 double = []
        named.ramp1 double = []
        named.rmean2 double = []
        named.rmode2 double = []
        named.rvar2 double = []
        named.ramp2 double = []
        named.regul double = []
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

    if ~isempty(named.regul)
        c = [c, means(1)/means(2)-named.regul(1)];
        c = [c, modes(1)/modes(2)-named.regul(2)];
        c = [c, vars(1)/vars(2)-named.regul(3)];
    end
    
    %% mode 1
    % mean range restriction
    if ~isempty(named.rmean1)
        c = [c, named.rmean1(1, 1)-means(1)];
        c = [c, means(1)-named.rmean1(1, 2)];
    end

    % mode range restriction
    if ~isempty(named.rmode1)
        c = [c, named.rmode1(1, 1)-modes(1)];
        c = [c, modes(1)-named.rmode1(1, 2)];
    end

    % variance range restriction
    if ~isempty(named.rvar1)
        c = [c, named.rvar1(1, 1)-vars(1)];
        c = [c, vars(1)-named.rvar1(1, 2)];
    end

    % amplitude range restriction
    if ~isempty(named.ramp1)
        c = [c, named.ramp1(1, 1)-amps(1)];
        c = [c, amps(1)-named.ramp1(1, 2)];
    end
    %% mode 2
    % mean range restriction
    if ~isempty(named.rmean2)
        c = [c, named.rmean2(1, 1)-means(2)];
        c = [c, means(2)-named.rmean2(1, 2)];
    end

    % mode range restriction
    if ~isempty(named.rmode2)
        c = [c, named.rmode2(1, 1)-modes(2)];
        c = [c, modes(2)-named.rmode2(1, 2)];
    end

    % variance range restriction
    if ~isempty(named.rvar2)
        c = [c, named.rvar2(1, 1)-vars(2)];
        c = [c, vars(2)-named.rvar2(1, 2)];
    end

    % amplitude range restriction
    if ~isempty(named.ramp2)
        c = [c, named.ramp2(1, 1)-amps(2)];
        c = [c, amps(2)-named.ramp2(1, 2)];
    end
end