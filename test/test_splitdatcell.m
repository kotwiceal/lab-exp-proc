%% 1D plot, 1D data, generate grid
clc
v = rand(3,1);
[x, v] = splitdatcell(v, dims = 1)
%% 1D plot, 2D data, generate grid
clc
v = rand(3,2);
[x, v] = splitdatcell(v, dims = 1)
%% 1D plot, 3D data, generate grid
clc
v = rand(3,2,2);
[x, v] = splitdatcell(v, dims = 1)
%% 1D plot, 4D data, generate grid
clc
v = rand(3,2,2,2);
[x, v] = splitdatcell(v, dims = 1)
%% 2D plot, 2D data, generate grid
clc
v = rand(3,3);
[x, y, v] = splitdatcell(v, dims = 1:2)
%% 2D plot, 3D data, generate grid
clc
v = rand(3,3,2);
[x, y, v] = splitdatcell(v, dims = 1:2)
%% 2D plot, 4D data, generate grid
clc
v = rand(3,3,2,2);
[x, y, v] = splitdatcell(v, dims = 1:2)
%% 3D plot, 3D data, generate grid
clc
v = rand(3,3,3);
[x, y, z, v] = splitdatcell(v, dims = 1:3)
%% 3D plot, 4D data, generate grid
clc
v = rand(3,3,3,2);
[x, y, z, v] = splitdatcell(v, dims = 1:3)
%% 3D plot, 5D data, generate grid
clc
v = rand(3,3,3,2,2);
[x, y, z, v] = splitdatcell(v, dims = 1:3)
%% custom grid
%% 1D plot, 1D data, custom grid
clc
x = rand(3,1);
v = rand(3,1);
[x, v] = splitdatcell(x, v, dims = 1)
%% 1D plot, 2D data, custom grid
clc
x = rand(3,1);
v = rand(3,2);
[x, v] = splitdatcell(x, v, dims = 1)
%% 1D plot, 3D data, custom grid
clc
x = rand(3,1);
v = rand(3,2,2);
[x, v] = splitdatcell(x, v, dims = 1)
%% 1D plot, 4D data, custom grid
clc
x = rand(3,1);
v = rand(3,2,2,2);
[x, v] = splitdatcell(x, v, dims = 1)
%% 2D plot, 2D data, custom grid
clc
[x, y] = meshgrid(rand(1,3));
v = rand(3,3);
[x, y, v] = splitdatcell(x, y, v, dims = 1:2)
%% 2D plot, 3D data, custom grid
clc
[x, y] = meshgrid(rand(1,3));
v = rand(3,3,2);
[x, y, v] = splitdatcell(x, y, v, dims = 1:2)
%% 2D plot, 4D data, custom grid
clc
[x, y] = meshgrid(rand(1,3));
v = rand(3,3,2,2);
[x, y, v] = splitdatcell(x, y, v, dims = 1:2)
%% 3D plot, 3D data, custom grid
clc
[x, y, z] = ndgrid(rand(3,1), rand(3,1), rand(3,1));
v = rand(3,3,3);
[x, y, z, v] = splitdatcell(x, y, z, v, dims = 1:3)
%% 3D plot, 4D data, custom grid
clc
[x, y, z] = ndgrid(rand(3,1), rand(3,1), rand(3,1));
v = rand(3,3,3,2);
[x, y, z, v] = splitdatcell(x, y, z, v, dims = 1:3)
%% 3D plot, 5D data, custom grid
clc
[x, y, z] = ndgrid(rand(3,1), rand(3,1), rand(3,1));
v = rand(3,3,3,2,2);
[x, y, z, v] = splitdatcell(x, y, z, v, dims = 1:3)
%% custom pair-data grid
%% 1D plot, 2D data, custom pair-data grid
clc
x = rand(3,2);
v = rand(3,2);
[x, v] = splitdatcell(x, v, dims = 1)
%% 1D plot, 3D data, custom pair-data grid
clc
x = rand(3,2,3);
v = rand(3,2,3);
[x, v] = splitdatcell(x, v, dims = 1)
%% 2D plot, 3D data, custom pair-data grid
clc
[x, y] = meshgrid(rand(1,3));
x = cat(3, x, x);
y = cat(3, y, y);
v = rand(3,3,2);
[x, y, v] = splitdatcell(x, y, v, dims = 1:2)
%% cell notation input
%% 1D plot, 1D cell data, generate grid
clc
v = rand(3,1);
arg = {v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 2D cell data, generate grid
clc
v = rand(3,2);
arg = {v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 3D cell data, generate grid
clc
v = rand(3,2,2);
arg = {v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 1D data, custom grid
clc
x = rand(3,1);
v = rand(3,1);
arg = {x, v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 2D data, custom grid
clc
x = rand(3,1);
v = rand(3,2);
arg = {x, v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 3D data, custom grid
clc
x = rand(3,1);
v = rand(3,2,2);
arg = {x, v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% cell notation input-output
%% 1D plot, 1D cell data, generate grid
clc
v = rand(3,1);
arg = {v};
res = cell(2,1);
[res{:}] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 2D cell data, generate grid
clc
v = rand(3,2);
arg = {v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 3D cell data, generate grid
clc
v = rand(3,2,2);
arg = {v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 1D data, custom grid
clc
x = rand(3,1);
v = rand(3,1);
arg = {x, v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 2D data, custom grid
clc
x = rand(3,1);
v = rand(3,2);
arg = {x, v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% 1D plot, 3D data, custom grid
clc
x = rand(3,1);
v = rand(3,2,2);
arg = {x, v};
[x, v] = splitdatcell(arg{:}, dims = 1)
%% test
[x, v] = splitdatcell((1:35)', rand(35, 4), dims = 1)