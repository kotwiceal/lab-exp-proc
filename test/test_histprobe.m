%% histprobe, 1D, no edges
histprobe('contour',[1,2],data.z,data.y,data.vm,data.dudt,draw='drawpoint')
%% histprobe, 1D, edges
edges = linspace(0,60);
histprobe('contour',[1,2],data.z,data.y,data.vm,edges,data.dudt,draw='drawpoint')
%%
histprobe('contour',[1,2],data.z,data.y,data.vm,{{linspace(0,60),linspace(0,1)}},...
    {{data.raw,data.dudt}},draw='drawpoint')
%%