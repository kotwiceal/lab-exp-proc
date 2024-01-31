function data = loadpiv(kwargs)
%% Load .vc7 dataset by specified filenames.
%% The function takes following arguments:
%   folder:             [char array]
%   filenames:          [k×l string]
%   subfolders:         [1×1 logical]
%   parallel:           [1×1 logical]
%   components:         [char array]
%% The function returns following results:
% data = 
%   struct with fields:
% 
%     x: [n×m double]
%     y: [n×m double]
%     u: [n×m×k×l double]
%     v: [n×m×k×l double]
% or
% data = 
%   struct with fields:
% 
%     x: [n×m double]
%     z: [n×m double]
%     u: [n×m×k×l double]
%     w: [n×m×k×l double]
%% Examples:
%% load vector fields from specified folder
% filenames = get_pather('\LVExport\u25mps\y_00');
% data = import_vc7(filenames);
%% load vector fields from specified folder with subfolders
% filenames = get_pather('\LVExport\u25mps\', sub = true);
% data = loadpiv(filenames);

    arguments
        kwargs.folder (1,:) char = []
        kwargs.filenames double = []
        kwargs.subfolders logical = false
        kwargs.parallel logical = false
        kwargs.components (1,:) char {mustBeMember(kwargs.components, {'x-y,u-v', 'x-z,u-w'})} = 'x-z,u-w'
        
    end

    if ~isempty(kwargs.folder)
        kwargs.filenames = get_pather(kwargs.folder, extension = 'vc7', subfolders = kwargs.subfolders);
    end

    sz = size(kwargs.filenames);

    imx = readimx(char(kwargs.filenames(1, 1)));
    nx = imx.Nx; nz = imx.Ny;
    
    [ax1, ax2] = meshgrid(1:nx, 1:nz); vel1 = zeros([nz, nx, sz]); vel2 = zeros([nz, nx, sz]);
    ax1 = ax1 * imx.ScaleX(1) * imx.Grid + imx.ScaleX(2);
    ax2 = ax2 * imx.ScaleY(1) * imx.Grid + imx.ScaleY(2);

    if kwargs.parallel
        parfor i = 1:prod(sz)
            imx = readimx(char(kwargs.filenames(i)));
            vel1(:, :, i) = imx.Data(:, 1:nz)' * sign(imx.ScaleX(1)) * imx.ScaleI(1);
            vel2(:, :, i) = imx.Data(:, nz+1:2*nz)' * sign(imx.ScaleY(1)) * imx.ScaleI(1);  
        end
    else
        for i = 1:prod(sz)
            imx = readimx(char(kwargs.filenames(i)));
            vel1(:, :, i) = imx.Data(:, 1:nz)' * sign(imx.ScaleX(1)) * imx.ScaleI(1);
            vel2(:, :, i) = imx.Data(:, nz+1:2*nz)' * sign(imx.ScaleY(1)) * imx.ScaleI(1);  
        end
    end

    vel1 = reshape(vel1, [size(vel1, [1, 2]), sz]);
    vel2 = reshape(vel2, [size(vel2, [1, 2]), sz]);

    switch kwargs.components
        case 'x-y,u-v'
            data.x = ax1; data.y = ax2; data.u = vel1; data.v = vel2;
        case 'x-z,u-w'
            data.x = ax1; data.z = ax2; data.u = vel1; data.w = vel2;
    end

end