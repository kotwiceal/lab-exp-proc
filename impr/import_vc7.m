function data = import_vc7(varargin)
%% Load .vc7 dataset by specified filenames.
%% The function takes following arguments:
% pathes: [k×l string array]
%% The function returns following results:
% data = 
%   struct with fields:
% 
%     x: [n×m double]
%     z: [n×m double]
%     u: [n×m×k×l double]
%     w: [n×m×k×l double]

    data = []; pathes = []; option = [];
    switch size(varargin, 2)
        case 1
            pathes = varargin{1};
        case 2
            pathes = varargin{1};
            option = varargin{2};
        otherwise
            return;
    end
    
    imx = readimx(char(pathes(1, 1)));
    nx = imx.Nx; nz = imx.Ny;
    
    [x, z] = meshgrid(1:nx, 1:nz); u = zeros([nz, nx, size(pathes)]); w = zeros([nz, nx, size(pathes)]);
    x = x * imx.ScaleX(1) * imx.Grid + imx.ScaleX(2);
    z = z * imx.ScaleY(1) * imx.Grid + imx.ScaleY(2);

    if (size(varargin, 2) == 1)
        for i = 1:size(pathes(:), 1)
            imx = readimx(char(pathes(i)));
            if (char(pathes(i)))
                u(:, :, i) = imx.Data(:, 1:nz)' * sign(imx.ScaleX(1)) * imx.ScaleI(1);
                w(:, :, i) = imx.Data(:, nz+1:2*nz)' * sign(imx.ScaleY(1)) * imx.ScaleI(1);  
            end
        end
    else
        if (varargin{2} == 'par')
            parfor i = 1:size(pathes(:), 1)
                imx = readimx(char(pathes(i)));
                u(:, :, i) = imx.Data(:, 1:nz)' * sign(imx.ScaleX(1)) * imx.ScaleI(1);
                w(:, :, i) = imx.Data(:, nz+1:2*nz)' * sign(imx.ScaleY(1)) * imx.ScaleI(1);  
            end
        end
    end

    u = reshape(u, [size(u, [1, 2]), size(pathes)]);
    w = reshape(w, [size(u, [1, 2]), size(pathes)]);
    data.x = x; data.z = z; data.u = u; data.w = w;
end