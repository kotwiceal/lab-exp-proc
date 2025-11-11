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
%%



%% roi
%% plot, 1D double array, no grid, roi drawxrange
t = linspace(0,1,25)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',x,axis='square',xlabel='t',ylabel='x',draw='drawxrange');
%%
[x, y] = meshgrid(linspace(0,1),linspace(0,1));
z = sin(10*x+5*y)+0.5*rand(size(x));
[plts, axs, rois] = cellplot('contour',x,y,z,axis='square',...
    xlabel='x',ylabel='y',colorbar='on',legend='on',...
    lbackgroundalpha=0.75,labelcolor='w',ltitle='z(x,y)');
fig = gcf;
tl = fig.Children;
t = linspace(0,1,25)'; x = sin(10*t)+0.5*rand(size(t));
cellplot('plot',x,axis='square',xlabel='t',ylabel='x',draw='drawxrange',parent=tl);
%% drawpoint
clc
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
[plts, axs, rois] = cellplot('contour',x,y,z,axis='square',...
    xlabel='x',ylabel='y',colorbar='on',legend='on',...
    lbackgroundalpha=0.75,labelcolor='w',ltitle='z(x,y)',...
    draw={'drawpoint','drawrectangle'},...
    number={2,3},target={1,1},rcolororder='off',rlinealign={'off','on'});
%% drawpolygon
clc
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
[plts, axs, rois] = cellplot('contour',x,y,z,axis='square',...
    xlabel='x',ylabel='y',colorbar='on',legend='on',...
    lbackgroundalpha=0.75,labelcolor='w',ltitle='z(x,y)',...
    draw={'drawpolygon'},...
    number={3},target={1},rcolororder='off');
%%
clc
[plts, axs, rois] = cellplot('contour',x,y,z,axis='square',...
    xlabel='x',ylabel='y',colorbar='on',legend='on',...
    lbackgroundalpha=0.75,labelcolor='w',ltitle='z(x,y)');
drawpoint(Position=[0.5,0.5]);
% drawpoint(Position=[0.5,0.5]);
% drawpoint(Position=[0.5,0.5]);
drawrectangle(Position=[0.5,0.5,1,1]);
% drawrectangle(Position=[0.5,0.5,1,1]);
number = [2, 3]';
% number = [0, 0]';
rois = flip(findobj(gca, 'Type','images.roi'))
% arrayfun(@(r) cellfun(@(n) copyobj(r, gca)), rois, UniformOutput = false)
arrayfun(@(r,n) cellfun(@(n) copyobj(r, gca), num2cell(1:n-1)), rois, number, UniformOutput = false)
rois = flip(findobj(gca, 'Type','images.roi'))
%%
clc
cellplot('contour',rand(3,2,1),rand(3,2,1),rand(3,2,4))
%%
clc
cellplot('contour',[],[],rand(3,2,4))
%%
clc
cellplot('contourf',[],rand(3,2,4))
%%
clc
cellplot({'contour','plot'},[],{rand(10,10,2),rand(10,10,3)})
%%
clc
cellplot({'contour','plot'},{rand(10,10,2),rand(10,10,3)},{rand(10,10,2), []})
%%
clc
cellplot({'contour'},{rand(10,10,2),rand(10,10,3)})
%%
clc
cellplot('contour',{rand(10,10,2),rand(10,10,3)})
%%
clc
cellplot('contour',{rand(10,10,2),rand(10,10,3)})
%%



%%
clc
cellplot('plot',[nan,nan],{rand(10,10),rand(20,5)})
%%
clc
cellplot('plot',[nan,1],{rand(10,10),rand(20,5)})
%%
clc
cellplot('plot',[0,0],{rand(10,10),rand(20,5)})
%%
clc
cellplot('plot',[0,1],{rand(10,10),rand(20,5)})
%%
clc
cellplot('contourf',[],{rand(10,10,3),rand(20,5)})
%%
clc
cellplot({'contourf','plot'},[nan,0],{rand(10,10,3),rand(20,5)})
%%
clc
cellplot({'contourf','plot','contourf'},[0,0,0],{rand(10,10,3),rand(20,5),rand(10,10,3)})
%%
clc
[plts, axs] = cellplot({'contourf','plot','contour'},{rand(10,10,3),rand(20,5),rand(10,10,3)},merge=true)
%%
%%
clc
[plts, axs] = cellplot({'contourf','plot','contourf'},[],{rand(10,10,3),rand(20,5),rand(10,10,3)},...
    draw='drawpoint')
%%
clc
[plts, axs, rois] = cellplot('contourf',[1,1,1],{rand(10,10),2*rand(20,20),3*rand(30,30)},...
    draw='drawrectangle',target={3},number={1})

%%
clc
[plts, axs, rois] = cellplot('contourf',[1,1,1],{rand(10,10),2*rand(20,20),3*rand(30,30)},...
    draw='drawpolygon',target={3},number={1})
%%
clc
[plts, axs, rois] = cellplot('contourf',[1,1,1],{rand(10,10),2*rand(20,20),3*rand(30,30)},...
    draw='drawrectangle',target={3},number={1})
%%
data = rand(20,10,10,20);
%%
r=drawrectangle
%%
clc
size(roislicedata(rois{1}{1}, data, [2,3], shape = 'trim', fill = 'nan'))
%%
%%
data = reshape(1:400,10,10,2);
%%
clc
roislicedata(data, rois{1}{1}, [1,2])
%%
clc
data = rand(10,20,20,10);
data(1:10,[1,2,4,5,20],[],1:2)
size(data)
%%
data = rand(20,10,10,20);
sz = size(data);
r = rois{1}{1}
roidim = [2,3]

sz = cellfun(@(x) 1:x, num2cell(sz), UniformOutput = false);
sz(roidim) = cellfun(@(x) min(x):max(x), r.UserData.subind, UniformOutput = false);
ds = data(sz{:});
%%


%%
cellplot('contourf',[nan,nan],{rand(10,10,2),rand(10,10,3)})
r = drawrectangle
clearAllMemoizedCaches
a=ans(end)
%%
clc
% clearAllMemoizedCaches
size(roislicedata(r, 2, data, [2,3], shape = 'trim', fill = 'nan'))
%%
size(roislicedata(r, a, data, [2,3], shape = 'trim', fill = 'nan'))


%%
clc
cellplot({'contourf','plot','contourf'},[0,0,0],{rand(10,10,3),rand(20,5),rand(10,10,3)},...
    xlabel={'x1', 'x2', 'x3'},ylabel={'y1','y2','y3'},title='t1',...
    subtitle='st1',layer='top',colorscale={'log','linear','log'},colorbar='on',docked=false,clabel='a',...
    figstand=false,axis='equal')


%%
clc
cellplot('plot',{rand(10,10),rand(10,10)},linestyleorder={'mixedstyles','mixedstyles'})
%%
clc
cellplot({'plot','contourf'},{rand(10,10),rand(10,10,2)},axis='equal',...
    linestyle='--',axpos=[0,nan],levels=linspace(0,1,25),legend='on')
%%
clc
cellplot({'plot'},{rand(10,2)},axis='equal',...
    linestyle='--',levels=linspace(0,1,25),legend='on',displayname={{'a1','s2'}})