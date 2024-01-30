function param = distparam(x, kwargs)
%% Processing of distribution parameters.
%% The function takes following arguments:
%   x:          [1×n double]            - parameter vector
%   distname:   [char array]            - approximation distribution name
%   disp:       [1×1 logical]           - display distribution parameters
%% The function returns following results:
%   param:      [struct]                - distribution parameters

    arguments
        x double
        kwargs.distname (1,:) char {mustBeMember(kwargs.distname, {'chi21', 'beta1', 'beta1l', 'beta2', 'beta2l', 'gamma1', 'gamma2', 'gumbel1', 'gumbel2'})} = 'gumbel2'
        kwargs.disp logical = false
    end

    param = struct();

    switch kwargs.distname
        case 'chi21'
            param.mean = x(1);
            param.mode = max([0, x(1)-2]);
            param.variance = 2*x(1);
            param.amplitude = chi2pdf(param.mode, x(1));
        case 'beta1'
            param.mean = x(2)/(x(2)+x(3));
            param.mode = (x(2)-1)/(x(2)+x(3)-2);
            param.variance = x(2)*x(3)/(x(2)+x(3))^2/(x(2)+x(3)+1);
            param.amplitude = x(1)*betapdf(param.mode, x(2), x(3));
        case 'beta1l'
            param.mean = 1/x(2)*(x(4)/(x(4)+x(5))+x(3));
            param.mode = 1/x(2)*((x(4)-1)/(x(4)+x(5)-2)+x(3));
            param.variance = x(4)*x(5)/(x(4)+x(5))^2/(x(4)+x(5)+1)/x(2)^2;
            param.amplitude = x(1)*betapdf(x(2)*param.mode-x(3), x(4), x(5));
        case 'beta2'
            param.mean = [x(2)/(x(2)+x(3)), x(5)/(x(5)+x(6))];
            param.mode = [(x(2)-1)/(x(2)+x(3)-2), (x(5)-1)/(x(5)+x(6)-2)];
            param.variance = [x(2)*x(3)/(x(2)+x(3))^2/(x(2)+x(3)+1), ...
                x(5)*x(6)/(x(5)+x(6))^2/(x(5)+x(6)+1)];
            param.amplitude = [x(1)*betapdf(param.mode(1), x(2), x(3)), ...
                x(4)*betapdf(param.mode(2), x(5), x(6))];
        case 'beta2l'
            param.mean = [1/x(2)*(x(4)/(x(4)+x(5))+x(3)), ...
                    1/x(7)*(x(9)/(x(9)+x(10))+x(8))];
            param.mode = [1/x(2)*((x(4)-1)/(x(4)+x(5)-2)+x(3)), ...
                1/x(7)*((x(9)-1)/(x(9)+x(10)-2)+x(8))];
            param.variance = [x(4)*x(5)/(x(4)+x(5))^2/(x(4)+x(5)+1)/x(2)^2, ...
                x(9)*x(10)/(x(9)+x(10))^2/(x(9)+x(10)+1)/x(7)^2];
            param.amplitude = [x(1)*betapdf(x(2)*param.mode(1)-x(3), x(4), x(5)), ...
                x(6)*betapdf(x(7)*param.mode(2)-x(8), x(9), x(10))];
        case 'gamma1'
            param.mean = x(2)*x(3);
            if (x(2) >= 1)
                param.mode = (x(2)-1)*x(3);
                param.amplitude = x(1)*gampdf(param.mode, x(2), x(3));
            else
                param.mode = 0;
                param.amplitude = nan;
            end
            param.variance = x(2)*x(3)^2;
        case 'gamma2'
            param.mean = [x(2)*x(3), x(5)*x(6)];
            if (x(2) >= 1)
                param.mode(1) = (x(2)-1)*x(3);
                param.amplitude(1) = x(1)*gampdf(param.mode(1), x(2), x(3));
            else
                param.mode(1) = 0;
                param.amplitude(1) = nan;
            end
            if (x(5) >= 1)
                param.mode(2) = (x(5)-1)*x(6);
                param.amplitude(2) = x(4)*gampdf(param.mode(2), x(5), x(6));
            else
                param.mode(2) = 0;
                param.amplitude(2) = nan;
            end
            param.variance = [x(2)*x(3)^2, x(5)*x(6)^2];
        case 'gumbel1'
            ec = 0.57721;
            param.mean = x(2)+x(3)*ec;
            param.mode = x(2);
            param.variance = pi^2/6*x(3)^2;
            param.amplitude = x(1)/x(3)*exp(-(param.mode-x(2))/x(3)-exp(-(param.mode-x(2))/x(3)));
        case 'gumbel2'
            ec = 0.57721;
            param.mean = [x(2)+x(3)*ec, x(5)+x(6)*ec]; 
            param.mode = [x(2), x(5)];
            param.variance = [pi^2/6*x(3)^2, pi^2/6*x(6)^2];
            param.amplitude = [x(1)/x(3)*exp(-(param.mode(1)-x(2))/x(3)-exp(-(param.mode(1)-x(2))/x(3))), ...
                x(4)/x(6)*exp(-(param.mode(2)-x(5))/x(6)-exp(-(param.mode(2)-x(5))/x(6)))];
    end

    if kwargs.disp
        tab = [param.mean; param.mode; param.variance; param.amplitude];
        if iscolumn(tab)
            tab = array2table(tab, 'VariableNames', {'full'}, 'RowName', {'mean', 'mode', 'variance', 'amplitude'});
        else
            tab = array2table(tab, 'VariableNames', {'laminar', 'turbulent'}, 'RowName', {'mean', 'mode', 'variance', 'amplitude'});
        end
        disp(tab);
    end

end