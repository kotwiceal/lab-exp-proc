function varargout = dirgrad(u, w, angle, named)
%% Process a directed gradient of multidimensional data
%% The function takes following arguments:
%   u:          [n×mx... double]    - first vector component
%   w:          [n×m×... double]    - second vector component
%   angle:      [double]            - angle rotation [rad];
%   component:  [char array]        - returned directed derivatives
%
%% The function returns following results:
%   dudl: [l×n×... double]
%   dwdl: [l×n×... double]
%   dudn: [l×n×... double]
%   dwdn: [l×n×... double]

    arguments
        u double
        w double
        angle double
        named.component char = 'dwdl'
    end

    mat = [cos(angle)^2, cos(angle)*sin(angle), cos(angle)*sin(angle), sin(angle)^2; ...
        -cos(angle)*sin(angle), cos(angle)^2, -sin(angle)^2, cos(angle)*sin(angle); ...
        -cos(angle)*sin(angle), -sin(angle)^2, cos(angle)^2, cos(angle)*sin(angle); ...
        sin(angle)^2, -cos(angle)*sin(angle), -cos(angle)*sin(angle), cos(angle)^2];
    Gx = fspecial('sobel'); Gz = Gx';
    dudx = imfilter(u, Gx); dudz = imfilter(u, Gz);
    dwdx = imfilter(w, Gx); dwdz = imfilter(w, Gz);
    vr = mat' * [dudx(:), dudz(:), dwdx(:), dwdz(:)]';
    sz = size(u);
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