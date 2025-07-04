%% 2D plot, 3D data
t = shiftdim(linspace(0,1),-1);
[x, y] = meshgrid(linspace(-1,1));
z = sin(10*x-5*y-10*t);

roi = guiplot(x,y,z(:,:,1),dims=1:2,plot='contourf',...
    linestyle='none',hold='on',aspect='equal',grid='on',...
    draw='drawrectangle');


roigetdata(roi{1}{1}{1},z(:,:,:),dims=1:2)