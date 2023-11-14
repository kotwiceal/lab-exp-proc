function data = dirgrad(data, angle, component)
%% Process a directed gradient of multidimensional data.
%% The function takes following arguments:
%   data: 
%       struct with fields:
%           u: [n×mx... double]
%           w: [n×m×... double]
%   angle:      [double]        - angle rotation [rad];
%   component:  [char array]    - returned directed derivatives
%
%% The function returns following results:
%   data: 
%       struct with fields:
%           u: [l×n×... double]
%           w: [l×n×... double]
%           dudl: [l×n×... double]
%           dwdl: [l×n×... double]
%           dudn: [l×n×... double]
%           dwdn: [l×n×... double]

    mat = [cos(angle)^2, cos(angle)*sin(angle), cos(angle)*sin(angle), sin(angle)^2; ...
        -cos(angle)*sin(angle), cos(angle)^2, -sin(angle)^2, cos(angle)*sin(angle); ...
        -cos(angle)*sin(angle), -sin(angle)^2, cos(angle)^2, cos(angle)*sin(angle); ...
        sin(angle)^2, -cos(angle)*sin(angle), -cos(angle)*sin(angle), cos(angle)^2];
    Gx = fspecial('sobel'); Gz = Gx';
    dudx = imfilter(data.u, Gx); dudz = imfilter(data.u, Gz);
    dwdx = imfilter(data.w, Gx); dwdz = imfilter(data.w, Gz);
    vr = mat' * [dudx(:), dudz(:), dwdx(:), dwdz(:)]';
    sz = size(data.u);
    switch component
        case 'dudl'
            data.dudl = reshape(vr(1, :), sz);
        case 'dudn'
            data.dudn = reshape(vr(2, :), sz);
        case 'dwdl'
            data.dwdl = reshape(vr(3, :), sz);
        case 'dwdn'
            data.dwdn = reshape(vr(4, :), sz);
        case 'all'
            data.dudl = reshape(vr(1, :), sz);
            data.dudn = reshape(vr(2, :), sz);
            data.dwdl = reshape(vr(3, :), sz);
            data.dwdn = reshape(vr(4, :), sz);
    end
end