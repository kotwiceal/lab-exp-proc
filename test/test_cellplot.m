%%
clc
cellplot({'contour','plot'},{rand(10,10,1),rand(10,10,1),rand(10,10,4)})
%%
clc
cellplot({'contour','contour'},rand(3,2,2),{[],[],rand(4,5,3)})
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
[plts, axs] = cellplot({'contourf','plot','contourf'},[],{rand(10,10,3),rand(20,5),rand(10,10,3)})
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