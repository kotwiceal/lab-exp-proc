%% data 2D, no grid, slice dimenstion [1,2], none fill, bounds shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
[xr,yr,zr] = maskcutdata([5,10;10,75],z,dims=[1,2],fill='none',shape='bounds');
disp([size(xr);size(yr);size(zr)])
cellplot('contourf',{x,xr},{y,yr},{z,zr},linestyle='none',axis={'equal','square'})
%% data 2D, grid, slice dimenstion [1,2], none fill, bounds shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
[xr,yr,zr] = maskcutdata([0.1,1.25;0.5,1.75],x,y,z,fill='none',shape='bounds');
disp([size(xr);size(yr);size(zr)])
cellplot('contourf',{x,xr},{y,yr},{z,zr},linestyle='none',axis={'equal','square'})
%% data 3D, no grid, slice dimenstion [1,2], none fill, trim shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
z = cat(3, z, 2*z-1);
[xr,yr,zr] = maskcutdata([5,10;10,10;10,75;5,75],z,dims=[1,2],fill='none',shape='trim');
disp([size(xr);size(yr);size(zr)])
cellplot({'contourf','plot3'},{x,xr},{y,yr},{z,zr},linestyle={'none','-'},axis={'equal','square'},...
    view={[0,90],[45,45]})
%% data 3D, grid, slice dimenstion [1,2], none fill, trim shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
z = cat(3, z, 2*z-1);
[xr,yr,zr] = maskcutdata([0.1,1.25;0.5,1.25;0.5,1.75;0.1,1.75],x,y,z,fill='none',shape='trim');
disp([size(xr);size(yr);size(zr)])
cellplot({'contourf','plot3'},{x,xr},{y,yr},{z,zr},linestyle={'none','-'},axis={'equal','square'},...
    view={[0,90],[45,45]})
%% data 2D, no grid, slice dimenstion [1,2], outnan fill, bounds shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
[xr,yr,zr] = maskcutdata([5,10;10,75],z,dims=[1,2],fill='outnan',shape='bounds');
disp([size(xr);size(yr);size(zr)])
cellplot('contourf',{x,xr},{y,yr},{z,zr},linestyle='none',axis={'equal','square'})
%% data 2D, grid, slice dimenstion [1,2], outnan fill, bounds shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
[xr,yr,zr] = maskcutdata([0.1,1.25;0.5,1.75],x,y,z,fill='outnan',shape='bounds');
disp([size(xr);size(yr);size(zr)])
cellplot('contourf',{x,xr},{y,yr},{z,zr},linestyle='none',axis={'equal','square'})
%% data 2D, no grid, slice dimenstion [1,2], innan fill, trim shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
[xr,yr,zr] = maskcutdata([5,10;10,10;10,75;5,75],z,dims=[1,2],fill='innan',shape='trim');
disp([size(xr);size(yr);size(zr)])
cellplot('contourf',{x,xr},{y,yr},{z,zr},linestyle='none',axis={'equal','square'})
%% data 2D, grid, slice dimenstion [1,2], innan fill, trim shape
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y);
[xr,yr,zr] = maskcutdata([0.1,1.25;0.5,1.25;0.5,1.75;0.1,1.75],x,y,z,fill='innan',shape='trim');
disp([size(xr);size(yr);size(zr)])
cellplot('contourf',{x,xr},{y,yr},{z,zr},linestyle='none',axis={'equal','square'})