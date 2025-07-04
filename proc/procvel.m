function varargout = procvel(varargin, param)
    %% Batch processing of 2D data.
    arguments (Input, Repeating)
        varargin 
    end

    arguments (Input)
        % fill missing
        param.fillmiss (1,:) char {mustBeMember(param.fillmiss, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        % prefilter
        param.prefilt (1,:) char {mustBeMember(param.prefilt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode'})} = 'gaussian'
        param.prefiltker (1,:) double = [3, 3] % prefilter kernel size
        param.padval {mustBeA(param.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value        
        % postfilter
        param.postfilt (1,:) char {mustBeMember(param.postfilt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode'})} = 'median'
        param.postfiltker (1,:) double = [15, 15] % postfilter kernel size
        param.hypot (1,1) logical = false
    end

    arguments (Output, Repeating)
        varargout
    end

    % fill missing
    varargin = cellfun(@(x) imfilt(x, filt = 'fillmiss',  method = param.fillmiss, zero2nan = true), ...
        varargin, UniformOutput = false);

    % prefiltering
    varargin = cellfun(@(x) imfilt(x, filt = param.prefilt, filtker = param.prefiltker), ...
        varargin, UniformOutput = false);

    % postfiltering
    varargin = cellfun(@(x) imfilt(x, filt = param.postfilt, filtker = param.postfiltker), ...
        varargin, UniformOutput = false);

    if (param.hypot); varargout{1} = hypot(varargin{:}); else; varargout = varargin; end

end