%% 1D data, 1D plot, single tile
guiplot(rand(35,1), ax = '1-n', dims = 1)
%% 2D data, 1D plot, single tile
guiplot(rand(35,5), ax = '1-n', dims = 1)
%% 3D data, 1D plot, single tile
guiplot(rand(35,5,3), ax = '1-n', dims = 1)
%% 2D data, 1D plot, multi tile
guiplot(rand(35,35), ax = '1-1', dims = 1:2, plot = 'contourf', hold = 'off', ...
    aspect = 'image', linestyle = 'none', grid = 'on')
%% 2D data, 2D plot
guiplot(rand(35,25,3), ax = '1-1', dims = 1:2, plot = 'imagesc', aspect = 'image')
%% 1D data, 1D plot, single tile, plot, drawpoint
guiplot(rand(35,1), ax = '1-n', dims = 1, draw = 'drawpoint', number = 2)
%% 2D data, 2D plot, single tile, imagesc, drawpoint
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'imagesc', draw = 'drawpoint', aspect = 'image', hold='off')
%% 2D data, 2D plot, single tile, contourf, drawpoint
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'contourf', draw = 'drawpoint', aspect = 'image')
%% 1D data, 1D plot, single tile, plot, drawline
guiplot(rand(35,1), ax = '1-n', dims = 1, draw = 'drawline')
%% 2D data, 2D plot, single tile, imagesc, drawline
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'imagesc', draw = 'drawline')
%% 2D data, 2D plot, single tile, contourf, drawline
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'contourf', draw = 'drawline')
%% 1D data, 1D plot, single tile, drawrectangle
guiplot(rand(35,1), ax = '1-n', dims = 1, draw = 'drawrectangle')
%% 2D data, 2D plot, single tile, imagesc, drawrectangle
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'imagesc', draw = 'drawrectangle')
%% 2D data, 2D plot, single tile, contourf, drawrectangle
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'contourf', draw = 'drawrectangle')
%% 1D data, 1D plot, single tile, drawpolygon
guiplot(rand(35,1), ax = '1-n', dims = 1, draw = 'drawpolygon')
%% 2D data, 2D plot, single tile, imagesc, drawpolygon
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'imagesc', draw = 'drawpolygon')
%% 2D data, 2D plot, single tile, contourf, drawpolygon
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'contourf', draw = 'drawpolygon')
%% 1D data, 1D plot, single tile, drawpolyline
guiplot(rand(35,1), ax = '1-n', dims = 1, draw = 'drawpolyline')
%% 2D data, 2D plot, single tile, imagesc, drawpolyline
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'imagesc', draw = 'drawpolyline')
%% 2D data, 2D plot, single tile, contourf, drawpolyline
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'contourf', draw = 'drawpolyline')
%% 1D data, 2D plot, multi tile, plot, drawpoint, single roi
guiplot(rand(35,2), ax = '1-1', dims = 1, plot = 'plot', draw = 'drawpoint', roi = '1-1')
%% 1D data, 2D plot, multi tile, plot, drawpoint, multi roi
guiplot(rand(35,2), ax = '1-1', dims = 1, plot = 'plot', draw = 'drawpoint', roi = '1-n')
%% 1D data, 2D plot, single tile, plot, drawpoint, multi roi
guiplot(rand(35,2), ax = '1-n', dims = 1, plot = 'plot', draw = 'drawpoint', roi = '1-n')
%% 2D data, 2D plot, single tile, contourf, drawpoint
guiplot(rand(35,100), ax = '1-n', dims = 1:2, ...
    plot = 'contourf', draw = {'drawpoint', 'drawline'}, aspect = 'image', linestyle = 'none')
%% 2D data, 2D plot, single tile, merge contourf, drawpolygon, snap on
[x1, y1] = meshgrid(linspace(0, 1, 10));
z1 = sin(10*x1-5*y1);
[x2, y2] = meshgrid(linspace(0.5, 1.5, 10));
z2 = sin(10*x2-5*y2);
guiplot({x1,x2}, {y1,y2}, {z1,z2}, ax = '1-n', ...
    plot = 'contourf', draw = {'drawpolygon', 'drawrectangle', 'drawpoint'}, aspect = 'image', linestyle = 'none', ...
    number = {[1, 1], [1, 1], [1, 1]})
%% 2D data, 2D plot, single tile, merge contourf, drawpolygon, snap on, position on
[x1, y1] = meshgrid(linspace(0, 1, 10));
z1 = sin(10*x1-5*y1);
[x2, y2] = meshgrid(linspace(0.5, 1.5, 10));
z2 = sin(10*x2-5*y2);
guiplot({x1,x2}, {y1,y2}, {z1,z2}, ax = '1-n', ...
    plot = 'contourf', draw = {'drawrectangle'}, aspect = 'image', linestyle = 'none', ...
    number = {2, 1}, position={{[0.2,0.2,0.1,0.1], [0.6,0.6,0.1,0.1]}})
%% 2D data, 2D plot, single tile, merge contourf, drawpolygon, snap on, position on
[x1, y1] = meshgrid(linspace(0, 1, 10));
z1 = sin(10*x1-5*y1);
[x2, y2] = meshgrid(linspace(0.5, 1.5, 10));
z2 = sin(10*x2-5*y2);
guiplot({x1,x2}, {y1,y2}, {z1,z2}, ax = '1-1', ...
    plot = 'contourf', draw = {'drawrectangle'}, aspect = 'image', linestyle = 'none', ...
    number = {2, 1}, position={{[0.2,0.2,0.1,0.1], [0.6,0.6,0.1,0.1]}},...
    xlabel='x, mm', ylabel={'y1, mm', 'y2, mm'})
%% 2D data, 2D plot, single tile, merge contourf, drawpolygon, snap on, position off
[x1, y1] = meshgrid(linspace(0, 1, 10));
z1 = sin(10*x1-5*y1);
[x2, y2] = meshgrid(linspace(0.5, 1.5, 10));
z2 = sin(10*x2-5*y2);
guiplot({x1,x2}, {y1,y2}, {z1,z2}, ax = '1-n', ...
    plot = 'contourf', draw = {'drawrectangle','drawrectangle'}, aspect = 'image', linestyle = 'none', ...
    xlabel='x, mm', ylabel='y, mm',target={2,1},number={3,2},position={{[0.5,0.5,0.1,0.1]}, {[0.3,0.3,0.1,0.1]}})