function varargout = parseargs(nargs, args, param)
    arguments (Input)
        nargs (1,1) {mustBeInteger}
        args (1,1) struct
        param.ans {mustBeMember(param.ans, {'separate', 'joint', 'struct'})} = 'separate'
    end
    arguments (Output, Repeating)
        varargout
    end
    % wrap structure field value by cell if it is not cell
    args = structfun(@(s) terop(isa(s, 'cell'), s, {s}), args, 'UniformOutput', false);
    % repeat field element if it is scalar cell array
    args = structfun(@(s) cat(2, s, repelem(teropf(isempty(s), @(){[]}, @() s(end)), terop(nargs>numel(s),nargs-numel(s),0))), args, UniformOutput = false);
    switch param.ans
        case 'struct'
            varargout{1} = args;
        otherwise
            % convert stucture of cell array to cell array of structure
            args = cellfun(@(i) structfun(@(e) terop(isa(e{i}, 'cell'), e{i}, {e{i}}), args, UniformOutput = false), ...
                num2cell(1:nargs), UniformOutput = false);
            args = cellfun(@(s) namedargs2cell(s), args, UniformOutput = false);
            switch param.ans
                case 'separate'
                    varargout{1} = cellfun(@(s) s(1:2:end), args, UniformOutput = false);
                    varargout{2} = cellfun(@(s) s(2:2:end), args, UniformOutput = false);
                case 'joint'
                    varargout{1} = args;
            end
    end
end