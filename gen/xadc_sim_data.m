function xadc_sim_data(kwargs)
    arguments
        kwargs.headers (1,:) {mustBeA(kwargs.headers, {'string', 'cell'})} = []
        kwargs.filename (1,:) {mustBeA(kwargs.filename, {'char', 'string'})} = []
        kwargs.Delimiter (1,:) char = 'tab'
        kwargs.default (1,1) logical = true
        kwargs.number (1,1) double = 1000
    end

    if isempty(kwargs.headers)
        kwargs.headers = ["TIME", "TEMP", "VCCINT", "VCCBRAM", "VCCAUX", "VP", "VN" "VAUXP[0]", "VAUXN[0]", "VAUXP[1]", ...
            "VAUXN[1]", "VAUXP[2]", "VAUXN[2]", "VAUXP[3]", "VAUXN[3]", "VAUXP[4]", "VAUXN[4]", "VAUXP[5]", ...
            "VAUXN[5]", "VAUXP[6]", "VAUXN[6]", "VAUXP[7]", "VAUXN[7]", "VAUXP[8]", "VAUXN[8]", "VAUXP[9]", ...
            "VAUXN[9]", "VAUXP[10]", "VAUXN[10]", "VAUXP[11]", "VAUXN[11]", "VAUXP[12]", "VAUXN[12]", ...
            "VAUXP[13]", "VAUXN[13]", "VAUXP[14]", "VAUXN[14]", "VAUXP[15]", "VAUXN[15]"];
    end

    if kwargs.default
        data = zeros(kwargs.number, numel(kwargs.headers));
        % data = [0, 63.1, 1.02, 1.02, 1.8, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0];
        % data = repmat(data, kwargs.number, 1);
        data(1:end,1) = round((0:kwargs.number-1)*100000);
        % data(1:end,8:2:end) = round(repmat((0.5*sin(1:kwargs.number)+0.5)', 1, 16), 2);
        data(1:end,2:2:end) = round(repmat((0.5*sin(1:kwargs.number)+0.5)', 1, 4), 2);
    end

    if ~isempty(kwargs.filename)
        writetable(array2table(data, 'VariableNames', kwargs.headers), kwargs.filename, 'Delimiter', kwargs.Delimiter)
    end
end