%% 1D plot, 1D data, generate grid
clc
v = rand(100,1);
[x, v] = splitdatcell(v, dims = 1);

clf
plotdatcell(x, v, target = gca, plot = 'plot')
%% 1D plot, 2D data, generate grid
clc
v = rand(3,2);
[x, v] = splitdatcell(v, dims = 1);

clf
plotdatcell(x, v, target = gca, plot = 'plot')
%% 1D plot, 3D data, generate grid
clc
v = rand(3,2,2);
[x, v] = splitdatcell(v, dims = 1)

clf
plotdatcell(x, v, target = gca, plot = 'plot')
%% 2D plot, 2D data, generate grid, axis
clc
v = rand(3,3);
[x, y, v] = splitdatcell(v, dims = 1:2);

clf
plotdatcell(x, y, v, target = gca, plot = 'contourf')
%% 2D plot, 3D data, generate grid, axis
clc
v = rand(25,25,2);
[x, y, v] = splitdatcell(v, dims = 1:2);

clf
plotdatcell(x, y, v, target = gca, plot = 'contourf')
%% 2D plot, 2D data, generate grid, axis
clc
v = rand(3,3);
[x, y, v] = splitdatcell(v, dims = 1:2);

clf
plotdatcell(v, target = gca, plot = 'imagesc',aspect='image')
%% 2D plot, 3D data, generate grid, tile
clc
v = rand(64,64,3);
[x, y, v] = splitdatcell(v, dims = 1:2);

clf; tl = tiledlayout('flow');
plotdatcell(v, target = tl, plot = 'imagesc', hold='on',aspect='image',xlabel='x',ylabel='y')