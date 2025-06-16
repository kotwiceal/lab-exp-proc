function varargout = dirgrad(u, w, angle, kwargs)
%% Process a directed gradient of multidimensional data

%% Example
% 1. Calculate a longitudinal derivative of transverse velocity component in rotated coordinate system
% data.dwdl = dirgrad(data.u, data.w, deg2rad(-22), component = 'dwdl', diffilt = '4ord');
    
    arguments
        u double % first vector component
        w double % second vector component
        angle % double angle rotation, [rad]
        % returned directed derivatives
        kwargs.component (1,:) char {mustBeMember(kwargs.component, {'dudl', 'dudn', 'dwdl', 'dwdn', 'all'})} = 'dwdl'
        % differentiation kernel
        kwargs.diffilt (1,:) char {mustBeMember(kwargs.diffilt, {'sobel', '4ord', '4ordgauss', '2ord'})} = 'sobel'
        kwargs.fillmiss (1,:) char {mustBeMember(kwargs.fillmiss, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        % prefilter kernel
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3] % prefilter kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
        kwargs.pow (1,1) double = 2 % raise to the power
        % portfilter type
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'gaussian', 'average', 'median', 'wiener'})} = 'none'
        kwargs.postfiltker (1,:) double = [] % postfilter kernel size
        %%
        kwargs.ans {mustBeMember(kwargs.ans, {'array', 'cell'})} = 'array'
    end

    math = memoize(@(angle) [cos(angle)^2, cos(angle)*sin(angle), cos(angle)*sin(angle), sin(angle)^2; ...
        -cos(angle)*sin(angle), cos(angle)^2, -sin(angle)^2, cos(angle)*sin(angle); ...
        -cos(angle)*sin(angle), -sin(angle)^2, cos(angle)^2, cos(angle)*sin(angle); ...
        sin(angle)^2, -cos(angle)*sin(angle), -cos(angle)*sin(angle), cos(angle)^2]);
    mat = math(angle);

    difkerh = memoize(@(x) cat(3, difkernel(x), difkernel(x)'));
    difker = difkerh(kwargs.diffilt);

    sz = size(u);

    % fill missing
    u = imfilt(u, filt = 'fillmiss', method = kwargs.fillmiss, zero2nan = true);
    w = imfilt(w, filt = 'fillmiss', method = kwargs.fillmiss, zero2nan = true);

    % prefiltering
    u = imfilt(u, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);
    w = imfilt(w, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);

    switch kwargs.component
        case 'dudl'
            ind = 1;
        case 'dudn'
            ind = 2;
        case 'dwdl'
            ind = 3;
        case 'dwdn'
            ind = 4;
        case 'all'
            ind = 1:4;
    end

    % differentiation
    dudx = imfilter(u, difker(:,:,1), 'symmetric'); dudz = imfilter(u, difker(:,:,2), 'symmetric');
    dwdx = imfilter(w, difker(:,:,1), 'symmetric'); dwdz = imfilter(w, difker(:,:,2), 'symmetric');

    % rotate
    temp = [dudx(:), dudz(:), dwdx(:), dwdz(:)]*mat;

    % slice
    temp = temp(:, ind);

    if ~isempty(kwargs.pow); temp = temp.^kwargs.pow; end

    if isscalar(ind)
        temp = reshape(temp(:, 1), sz);
        temp = imfilt(temp, filt = kwargs.postfilt, filtker = kwargs.postfiltker, padval = kwargs.padval);
        varargout{1} = temp;
    else
        varargout = cell(1, 4);
        temp = cellfun(@(n) reshape(temp(:, n), sz), num2cell(ind), UniformOutput = false);
        [varargout{:}] = deal(temp{:});
    end

    % postfiltering
    % [varargout{:}] = cellfun(@(x) imfilt(x{1}, filt = kwargs.postfilt, filtker = kwargs.postfiltker, padval = kwargs.padval), ...
    %     varargout, UniformOutput = false);

end