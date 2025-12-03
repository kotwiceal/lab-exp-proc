function data = preppiv(data,opt,param)
    arguments (Input)
        data (1,:) struct
        opt.fields (1,:) cell = {'u', 'w'}
        opt.hypot (1,1) logical = true
        % fill missing
        param.fillmiss (1,:) char {mustBeMember(param.fillmiss, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        % prefilter
        param.filt (1,:) char {mustBeMember(param.filt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode'})} = 'gaussian'
        param.filtker (1,:) double = [3, 3] % prefilter kernel size
        param.filtdim (1,:) double = [1, 2] % filter dimension
        param.padval {mustBeA(param.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value        
        param.zero2nan (1,1) logical = false
    end

    arguments (Output)
        data (1,:) struct
    end

    temp = cellfun(@(s) data.(s), opt.fields, 'UniformOutput', false);

    % fill missing
    arg = param; arg.filt = 'fillmiss'; arg = namedargs2cell(arg);
    temp = cellfun(@(t) ndfilt(t, arg{:}), temp, ...
        'UniformOutput', false);

    % filter
    arg = param; arg = namedargs2cell(arg);
    temp = cellfun(@(t) ndfilt(t, arg{:}), temp, ...
        'UniformOutput', false);

    if opt.hypot; data.vm = hypot(temp{:}); end

    % cellfun(@(t,f) data.(s), temp, temp, opt.fields, 'UniformOutput', false);

end