%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)x,[1,2],x,y,z,m,d,...
    draw='drawpoint',number=2)
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)x,[1,2],x,y,z,m,d,...
    draw='drawpoint',number=2,target=[1,1])
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32,23]);
cellprobe('contour','contourf',@(x)x,[1,2],x,y,z,d,...
    draw='drawpoint',number=1)
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)x,[1,2],{x,x+1},{y,y+1},{z,z2},m,d,...
    draw='drawpoint',number=2)
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)-x,[1,2],{x,x+1},{y,y+1},{z,z2},{m,m},{d,d+3},...
    draw='drawpoint',number=1,target=[1,2])
%%