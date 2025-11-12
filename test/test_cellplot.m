%% plot, 1D double array, no grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',x,axis='square',xlabel='t',ylabel='x');
%% plot, 1D double array, grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',t,x,axis='square',xlabel='t',ylabel='x');
%% plot, 2D double array, no grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',x,axis='square',xlabel='t',ylabel='x');
%% plot, 2D double array, grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t)); 
x = cat(2, x, x + 1, x + 2);
cellplot('plot',x,axis='square',xlabel='t',ylabel='x',legend='on');
%% plot, 2D double array, grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t)); 
x = cat(2, x, x + 1, x + 2);
cellplot('plot',t,x,axis='square',xlabel='t',ylabel='x',legend='on');
%% plot, 2D cell array, no grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',{x, x + 1, x + 2},axis='square',xlabel='t',ylabel='x',...
    legend='on');
%% plot, 2D cell array, grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',{t, t, t},{x, x + 1, x + 2},axis='square',xlabel='t',...
    ylabel='x',legend='on');
%% plot, 2D cell array, grid
t = linspace(0,1)'; x = sin(10*t)+0.5*rand(size(t)); 
x = cat(2, x, x + 1, x + 2);
cellplot('plot',t,x,axis='square',xlabel='t',ylabel='x',legend='on');
%% contour, 2D double array, no grid
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',z,xlabel='x',ylabel='y',axis='image',title='z(x,y)',...
    subtitle='node space')
%% contour, 2D double array, grid
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,xlabel='x',ylabel='y',axis='image',title='z(x,y)',...
    subtitle='real space')
%% contour, 3D double array, no grid
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x)); z = cat(3, z, z + 1);
cellplot('contour',z,xlabel='x',ylabel='y',axis='image',title='z(x,y)',...
    subtitle='node space')
%% contour, 3D double array, grid
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x)); z = cat(3, z, z + 1);
x = cat(3, x, x + 1); y = cat(3, y, y + 1);
cellplot('contour',x,y,z,xlabel='x',ylabel='y',axis='image',...
    title='z(x,y)',subtitle='real space')
%% contour, 3D cell array, no grid
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',{z,z+1},xlabel='x',ylabel='y',axis='image',...
    title='z(x,y)',subtitle='node space',colorbar='on')
%% contour, 3D cell array, grid
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',{x,x+1},{y,y+1},{z,z+1},xlabel='x',ylabel='y',...
    axis='image',title='z(x,y)',subtitle='real space',colorbar='on')
%% plot, 1D double array, no grid + contour, 2D double array, no grid
t = linspace(0,1)'; x1 = sin(10*t)+0.5*rand(size(t));
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot({'plot','contour'},{[],[]},{x1,[]},{[],z},axis='square',...
    xlabel={'t','x'},ylabel={'x','y'},colorbar={'off','on'});
%% plot, 1D double array, grid + contour, 2D double array, grid
t = linspace(0,1)'; x1 = sin(10*t)+0.5*rand(size(t));
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot({'plot','contour'},{t,x},{x1,y},{[],z},axis='square',...
    xlabel={'t','x'},ylabel={'x','y'},colorbar={'off','on'},legend='on',...
    lbackgroundalpha={1,0.1});
%% contour, 2D double array, grid, customize appearance
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,axis='square',...
    xlabel='x',ylabel='y',colorbar='on',legend='on',...
    lbackgroundalpha=0.75,labelcolor='w',ltitle='z(x,y)');
%% create multiple axes
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,axis='square',...
    xlabel='x',ylabel='y',colorbar='on',legend='on',...
    lbackgroundalpha=0.75,labelcolor='w',ltitle='z(x,y)');
t = linspace(0,1,25)'; x = sin(10*t)+0.5*rand(size(t));
[~, axs, ~] = cellplot('plot',x,axis='square',xlabel='t',ylabel='x',parent=gcf().Children);
%% append to last axis
t = linspace(0,1,25)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',x,axis='square',xlabel='t',ylabel='x',parent=axs);
%% roi
%% drawpolygon/3, manual position
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw='drawpolygon',number=3,rcolororder='on',...
    rlinealign='on',ralpha=0.1,rlinewidth=0.5);
%% drawpolygon/2, cell position/1
pos = {{[0.2,0.2;0.4,0.2;0.3,0.4]}};
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw='drawpolygon',number=3,rcolororder='on',...
    rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos);
%% drawpolygon/3, array position/1
pos = [0.2,0.2;0.4,0.2;0.3,0.4];
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw='drawpolygon',number=3,rcolororder='on',...
    rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos);
%% drawpolygon/3, cell position/3
pos = {{[0.2,0.2;0.4,0.2;0.3,0.4], [0.2,0.2;0.4,0.2;0.3,0.4]+0.2, ...
    [0.2,0.2;0.4,0.2;0.3,0.4]+0.3}};
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw='drawpolygon',number=3,rcolororder='on',...
    rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos,rnumlabel='on');
%% drawpoint/2+drawpolygon/3, manual position
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw={'drawpoint','drawpolygon'},...
    rcolororder='on',rlinealign='on',ralpha=0.1,rlinewidth=0.5);
%% drawpoint/2+drawpolygon/3, manual position, specify number
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw={'drawpoint','drawpolygon'},number=[2,3],...
    rcolororder='on',rlinealign='on',ralpha=0.1,rlinewidth=0.5);
%% drawpoint/2+drawpolygon/3, cell position/2 with empty mask, specify number
pos = {{[0.2,0.2]}, {[]}};
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw={'drawpoint','drawpolygon'},number=[2,3],...
    rcolororder='on',rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos);
%% drawpoint/2+drawpolygon/3, cell position/2, specify number
pos = {{[0.1,0.7]}, {[0.2,0.2;0.4,0.2;0.3,0.4]}};
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw={'drawpoint','drawpolygon'},number=[2,3],...
    rcolororder='on',rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos);
%% drawpoint/2+drawpolygon/3, cell position/2
pos = {{[0.1,0.7]}, {[0.2,0.2;0.4,0.2;0.3,0.4]}};
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw={'drawpoint','drawpolygon'},...
    rcolororder='on',rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos);
%% drawpoint/2+drawpolygon/3, cell position/2
pos = {{[0.1,0.7], [0.2,0.8]}, {[0.2,0.2;0.4,0.2;0.3,0.4], [0.2,0.2;0.4,0.2;0.3,0.4]+0.2}};
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
cellplot('contour',x,y,z,draw={'drawpoint','drawpolygon'},...
    rcolororder='on',rlinealign='on',ralpha=0.1,rlinewidth=0.5,rposition=pos);
%%