
%% contour, 2D double array, no grid
clc
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z = z.*shiftdim(rand(1,20),-1);
d = z.*shiftdim(rand(1,10),-2);
pointprobe('contour',{x,[]},{y,d},{z,[]},target=1,dims=[1,2])
%%
clc
data = {rand(10,25,35,15)};
%%
[data, dg] = wraparrbycell(rand(10,25,35), dims = [2,3]);
numel(data)