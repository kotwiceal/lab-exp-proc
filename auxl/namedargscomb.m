function res = namedargscomb(varargin, param)
    %% Make combinations of named passing argument.

    arguments (Repeating, Input)
        varargin
    end
    arguments (Input)
        param.ans {mustBeMember(param.ans, {'table', 'cell', 'arg'})} = 'table'
    end
    arguments (Output)
        res {mustBeA(res, {'table', 'cell', 'arg'})}
    end

    s = struct; k = 1;

    for i = 1:nargin
        if isa(varargin{i}, 'struct')
             f = fieldnames(varargin{i});
             for j = 1:length(f)
                s.(f{j}) = varargin{i}.(f{j});
             end
        else
            s.(strcat("Var",num2str(k))) = varargin{i};
            k = k + 1;
        end
    end

    fields = fieldnames(s);
    arg = namedargs2cell(s);
    for i = 1:numel(arg)
        switch class(arg{i})
            case 'double'
                arg{i} = num2cell(arg{i});
            case 'char'
                arg{i} = string(arg{i});
        end
    end
    switch param.ans
        case 'table'
            res = combinations(arg{2:2:end});
            res.Properties.VariableNames = fields;
        case 'cell'
            res = combinations(arg{:});
            res = table2cell(res);
        case 'arg'
            res = combinations(arg{:});
            res = table2cell(res);
            
            ind = [];
            for i = 1:size(res, 2)
                temp = res(1,i); temp = temp{1};
                if isa(temp, 'char') | isa(temp, 'string')
                    if contains(temp, 'Var')
                        ind = cat(2, ind, i);
                    end
                end
            end

            res(:,ind) = [];

            temp = cell(size(res, 1), 1);
            for i = 1:size(res, 1)
                temp{i} = res(i,:);
            end

            res = temp;
    end

end