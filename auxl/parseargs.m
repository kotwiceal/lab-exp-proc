function varargout = parseargs(nargs, args, param)
    arguments (Input)
        nargs (1,1) {mustBeInteger}
        args (1,1) struct
        param.ans {mustBeMember(param.ans, {'separate', 'joint'})} = 'separate'
    end
    arguments (Output, Repeating)
        varargout
    end
    args = structfun(@(s) terop(isa(s,'cell'),s,{s}), args, UniformOutput = false);
    argsn = unique(structfun(@(s) numel(s), args, UniformOutput = true));
    if (numel(argsn) > 2) | (nargs ~= argsn(end)); error('error'); end
    args = structfun(@(s) terop(numel(s)>1, s, repmat(s, 1, nargs)), args, UniformOutput = false);
    args = cellfun(@(i) structfun(@(e) terop(isa(e{i},'cell'),e{i},{e{i}}), args, UniformOutput = false), ...
        num2cell(1:nargs), UniformOutput = false);
    args = cellfun(@(s) namedargs2cell(s), args, UniformOutput = false);
    switch param.ans
        case 'separate'
            paramnames = cellfun(@(s) s(1:2:end), args, UniformOutput = false);
            paramvals = cellfun(@(s) s(2:2:end), args, UniformOutput = false);
            varargout{1} = paramnames;
            varargout{2} = paramvals;
        case 'joint'
            varargout{1} = args;
    end
end