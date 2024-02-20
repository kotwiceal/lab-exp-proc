function varargout = dirgrad(u, w, angle, kwargs)
%% Process a directed gradient of multidimensional data
%% The function takes following arguments:
%   u:              [n×m×... double]    - first vector component
%   w:              [n×m×... double]    - second vector component
%   angle:          [1×1 double]        - angle rotation [rad];
%   component:      [char array]        - returned directed derivatives
%   diffilter:      [char array]        - difference schema
%   prefilt:        [char array]        - smooth prefiltering
%   prefiltker:     [1×2 double]        - kernel of smooth filter
%
%% The function returns following results:
%   dudl: [l×n×... double]
%   dwdl: [l×n×... double]
%   dudn: [l×n×... double]
%   dwdn: [l×n×... double]
%% Example
% 1. Calculate a longitudinal derivative of transverse velocity component in rotated coordinate system
% data.dwdl = dirgrad(data.u, data.w, deg2rad(-22), component = 'dwdl', diffilter = '4ord');

    arguments
        u double
        w double
        angle double
        kwargs.component (1,:) char {mustBeMember(kwargs.component, {'dudl', 'dudn', 'dwdl', 'dwdn', 'all'})} = 'dwdl'
        kwargs.diffilter (1,:) char {mustBeMember(kwargs.diffilter, {'sobel', '4ord', '4ordgauss', '2ord'})} = 'sobel'
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3]
    end

    mat = [cos(angle)^2, cos(angle)*sin(angle), cos(angle)*sin(angle), sin(angle)^2; ...
        -cos(angle)*sin(angle), cos(angle)^2, -sin(angle)^2, cos(angle)*sin(angle); ...
        -cos(angle)*sin(angle), -sin(angle)^2, cos(angle)^2, cos(angle)*sin(angle); ...
        sin(angle)^2, -cos(angle)*sin(angle), -cos(angle)*sin(angle), cos(angle)^2];

    sz = size(u); u = u(:, :, :); w = w(:, :, :);

    % velocity prefiltering
    u = imagfilter(u, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    w = imagfilter(w, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

    % derivation
    Gx = difkernel(kwargs.diffilter); Gz = Gx';
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