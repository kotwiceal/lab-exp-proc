%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)x{:},[1,2],x,y,z,m,d,...
    draw='drawpoint',rnumber=2)
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)x{:},[1,2],x,y,z,m,d,...
    draw='drawpoint',rnumber=2,target=[1,1])
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32,23]);
cellprobe('contour','contourf',@(x)x{:},[1,2],x,y,z,d,...
    draw='drawpoint',rnumber=1)
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)x{:},[1,2],{x,x+1},{y,y+1},{z,z2},m,d,...
    draw='drawpoint',rnumber=2)
%% drawpoint
[x, y] = meshgrid(linspace(0,1,25),linspace(0,1,25));
z = sin(10*x+5*y)+0.5*rand(size(x));
z2 = sin(0.5*x+5*y)+0.5*rand(size(x));
d = rand([size(z,[1,2]),32]);
m = linspace(0,1,size(d,3))';
cellprobe('contour','plot',@(x)-x{:},[1,2],{x,x+1},{y,y+1},{z,z2},{m,m},{d,d+3},...
    draw='drawpoint',rnumber=1,target=[1,2])
%% experimental data
%% cellprobe, histcounts, no edges 
funcs = @(x) histcounts(x{:},100,'Normalization','pdf');
cellprobe('contourf','plot',funcs,[1,2],[],[],data.vm,data.dudt,...
    draw='drawpoint')
%% cellprobe, histcounts, no edges 
funcs = @(x) histcounts(x{:},100,'Normalization','pdf');
cellprobe('contourf','plot',funcs,[1,2],data.vm,data.dudt,...
    draw='drawpoint')
%% cellprobe, histcounts, no edges 
funcs = @(x) histcounts(x{:},100,'Normalization','pdf');
cellprobe('contourf','plot',funcs,[1,2],data.z,data.y,data.vm,data.dudt,...
    draw='drawpoint')
%% cellprobe, histcounts, edges 
edges = linspace(0,1,200);
funcs = @(x) histcounts(x{:},edges,'Normalization','pdf');
edges = edges(2:end)-diff(edges)/2;
cellprobe('contourf','plot',funcs,[1,2],data.z,data.y,data.vm,edges,data.dudt,...
    draw='drawpoint')
%% cellprobe, histcounts2, no edges 
funcs = @(x) histcounts2(x{:},[100,100],'Normalization','pdf');
cellprobe('contourf','contourf',funcs,[1,2],data.z,data.y,data.vm,...
    {{data.dudt,data.raw}},draw='drawpoint')
%% cellprobe, histcounts2, edges 
edges1 = linspace(0,1,200);
edges2 = linspace(0,60,200);
funcs = @(x) histcounts2(x{:},edges1,edges2,'Normalization','pdf');
edges1 = edges1(2:end)-diff(edges1)/2;
edges2 = edges2(2:end)-diff(edges2)/2;
[edges1, edges2] = meshgrid(edges1, edges2);
cellprobe('contourf','contourf',funcs,[1,2],data.z,data.y,data.vm,...
    {{edges1, edges2}},{{data.dudt,data.raw}},draw='drawpoint')
%% cellprobe, histcounts2, edges 
edges1 = linspace(0,1,200);
edges2 = linspace(0,60,200);
funcs = @(x) histcounts2(x{:},edges1,edges2,'Normalization','pdf');
edges1 = edges1(2:end)-diff(edges1)/2;
edges2 = edges2(2:end)-diff(edges2)/2;
[edges1, edges2] = meshgrid(edges1, edges2);
cellprobe('contourf','contourf',funcs,[1,2],data.z,data.y,data.vm,...
    {{edges1, edges2},{edges1, edges2}},{{data.dudt,data.raw},{data.dudt,data.raw}},draw='drawpoint')
%%
% cellprobe(dplot,vararin,pplot,vararin,options)
% cellprobe(dplot,d1,d2,d3,pplot,p1,p2,p3,options)