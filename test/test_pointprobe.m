%% contour, no grid, drawpoint/1, manual position, marker no grid
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
pointprobe('contour',[1,2],z,d);
%% contour, grid, drawpoint/1, manual position, marker no grid
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
pointprobe('contour',[1,2],x,y,z,d);
%% contour, grid, drawpoint/2, manual position, marker no grid
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
pointprobe('contour',[1,2],x,y,z,d,number=2);
%% contour, grid, drawpoint/2, manual position, marker with grid
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
pointprobe('contour',[1,2],x,y,z,m,d,number=2);
%% contour/2, grid, drawpoint/2, manual position, marker with grid
clc
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
pointprobe('contour',[1,2],{x,x+1},{y,y+1},{z,z2},m,d,number=2);
%% contour/2, grid, drawpoint/2, manual position, marker with grid
clc
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
pointprobe('contour',[1,2],{x,x+1},{y,y+1},{z,z2},m,d,target=[1,2]);
%%