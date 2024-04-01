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
        % prefilter kernel
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3] % prefilter kernel size
    end

    mat = [cos(angle)^2, cos(angle)*sin(angle), cos(angle)*sin(angle), sin(angle)^2; ...
        -cos(angle)*sin(angle), cos(angle)^2, -sin(angle)^2, cos(angle)*sin(angle); ...
        -cos(angle)*sin(angle), -sin(angle)^2, cos(angle)^2, cos(angle)*sin(angle); ...
        sin(angle)^2, -cos(angle)*sin(angle), -cos(angle)*sin(angle), cos(angle)^2];

    sz = size(u); u = u(:, :, :); w = w(:, :, :);

    % velocity prefiltering
    u = imfilt(u, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    w = imfilt(w, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

    % derivation
    Gx = difkernel(kwargs.diffilt); Gz = Gx';
    dudx = imfilter(u, Gx); dudz = imfilter(u, Gz);
    dwdx = imfilter(w, Gx); dwdz = imfilter(w, Gz);
        
    % rotate
    vr = mat' * [dudx(:), dudz(:), dwdx(:), dwdz(:)]';
    switch kwargs.component
        case 'dudl'
            varargout{1} = reshape(vr(1, :), sz);
        case 'dudn'
            varargout{1} = reshape(vr(2, :), sz);
        case 'dwdl'
            varargout{1} = reshape(vr(3, :), sz);
        case 'dwdn'
            varargout{1} = reshape(vr(4, :), sz);
        case 'all'
            varargout{1} = reshape(vr(1, :), sz);
            varargout{2} = reshape(vr(2, :), sz);
            varargout{3} = reshape(vr(3, :), sz);
            varargout{4} = reshape(vr(4, :), sz);
    end
end