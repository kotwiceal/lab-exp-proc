function varargout = dirgrad(u, w, angle, named)
%% Process a directed gradient of multidimensional data
%% The function takes following arguments:
%   u:              [n×m×... double]    - first vector component
%   w:              [n×m×... double]    - second vector component
%   angle:          [1×1 double]        - angle rotation [rad];
%   component:      [char array]        - returned directed derivatives
%   diffilter:      [char array]        - difference schema
%   prefilter:      [char array]        - smooth prefiltering
%   prefiltkernel:  [1×2 double]        - kernel of smooth filter
%
%% The function returns following results:
%   dudl: [l×n×... double]
%   dwdl: [l×n×... double]
%   dudn: [l×n×... double]
%   dwdn: [l×n×... double]
%% Example
% data.dwdl = dirgrad(data.un, data.wn, deg2rad(-22), component = 'dwdl', diffilter = '4ord');

    arguments
        u double
        w double
        angle double
        named.component (1,:) char {mustBeMember(named.component, {'dudl', 'dudn', 'dwdl', 'dwdn', 'all'})} = 'dwdl'
        named.diffilter (1,:) char {mustBeMember(named.diffilter, {'sobel', '4ord', '4ordgauss', '2ord'})} = 'sobel'
        named.prefilter (1,:) char {mustBeMember(named.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        named.prefiltkernel double = [3, 3]
    end

    mat = [cos(angle)^2, cos(angle)*sin(angle), cos(angle)*sin(angle), sin(angle)^2; ...
        -cos(angle)*sin(angle), cos(angle)^2, -sin(angle)^2, cos(angle)*sin(angle); ...
        -cos(angle)*sin(angle), -sin(angle)^2, cos(angle)^2, cos(angle)*sin(angle); ...
        sin(angle)^2, -cos(angle)*sin(angle), -cos(angle)*sin(angle), cos(angle)^2];

    sz = size(u); u = u(:, :, :); w = w(:, :, :);

    switch named.prefilter
        case 'average'
            kernel = fspecial(named.prefilter, named.prefiltkernel);
            u = imfilter(u, kernel); w = imfilter(w, kernel);

        case 'gaussian'
            kernel = fspecial(named.prefilter, named.prefiltkernel);
            u = imfilter(u, kernel); w = imfilter(w, kernel);

        case 'median'
            kernel = named.prefiltkernel;
            for i = 1:prod(sz(3:end))
                u(:, :, i) = medfilt2(u(:, :, i), kernel);
                w(:, :, i) = medfilt2(w(:, :, i), kernel);
            end

        case 'wiener'
            kernel = named.prefiltkernel;
            for i = 1:prod(sz(3:end))
                u(:, :, i) = wiener2(u(:, :, i), kernel);
                w(:, :, i) = wiener2(w(:, :, i), kernel);
            end
    end

    Gx = difkernel(named.diffilter); Gz = Gx';

    dudx = imfilter(u, Gx); dudz = imfilter(u, Gz);
    dwdx = imfilter(w, Gx); dwdz = imfilter(w, Gz);
        
    vr = mat' * [dudx(:), dudz(:), dwdx(:), dwdz(:)]';
    switch named.component
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