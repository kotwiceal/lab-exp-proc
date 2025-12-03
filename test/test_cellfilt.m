%% data 1D, filt 1D, gaussian
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
yf = cellfilt('gaussian',y,kernel=10);
cellplot('plot',x,cat(2,y,yf))
%% data 2D, filt 1D, gaussian
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2);
yf = cellfilt('gaussian',y,kernel=15,padval='symmetric');
cellplot('plot',x,cat(2,y,yf))
%% data 3D, filt 1D, gaussian
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2, y+3);
y = permute(y, [2, 3, 1]);
yf = cellfilt('gaussian',y,kernel=15,ndim=3,padval='symmetric');
yf = permute(yf, [2, 1]);
y = permute(y, [3, 1, 2]);
cellplot('plot',x,cat(2,y,yf))
%% data 1D, filt 1D, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
yf = cellfilt('median',y,kernel=10,padval='symmetric');
cellplot('plot',x,cat(2,y,yf))
%% data 2D, filt 1D, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2);
yf = cellfilt('median',y,kernel=15);
cellplot('plot',x,cat(2,y,yf'))
%% data 3D, filt 1D, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2, y+3);
y = permute(y, [2, 3, 1]);
yf = cellfilt('median',y,kernel=15,ndim=3);
yf = permute(yf, [2, 1]);
y = permute(y, [3, 1, 2]);
cellplot('plot',x,cat(2,y,yf))
%% data 1D, filt 1D, fillmiss
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
yf = cellfilt('fillmiss',y,ndim=1);
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 2D, filt 1D, fillmiss
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
y = cat(2, y, y + 2);
yf = cellfilt('fillmiss',y,ndim=1);
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 3D, filt 1D, fillmiss
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
y = cat(2, y, y + 2, y + 3);
y = permute(y, [2, 3, 1]);
yf = cellfilt('fillmiss',y,padval='symmetric',ndim=3);
y = permute(y, [3, 1, 2]);
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 1D, filt 1D, fillmiss, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],20,1)) = nan;
yf = cellfilt({'fillmiss','median'},y,ndim={1,[]},kernel={[],15});
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 1D, filt 1D, fillmiss, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],20,1)) = nan;
yf = cellfilt({'fillmiss','median'},y,ndim=1,kernel=15);
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 2D, filt 1D, fillmiss, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
y = cat(2, y, y + 2);
yf = cellfilt({'fillmiss','median'},y,ndim=1,kernel=15);
cellplot('plot',x,cat(2,y,yf'),axpos=nan)
%%
%
%
%
%% data 2D, filt 2D, fillmiss, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
zf = cellfilt({'fillmiss','median'},z,ndim=[1,2],kernel=[15,15]);
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 2D, filt 2D, fillmiss, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
zf = cellfilt({'fillmiss','median'},z,ndim=[1,2],kernel=[15,15],padval=0);
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 2D, filt 2D, fillmiss, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
zf = cellfilt({'fillmiss','median'},z,ndim=[1,2],kernel=[15,15],padval={0,2});
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, fillmiss, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
z = cat(3, z, z + 1);
zf = cellfilt({'fillmiss','median'},z,ndim=[1,2],kernel=[15,15]);
zf = permute(zf, [2, 3, 1]);
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% double data 2D, filt 2D, fillmiss, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
[zf1, zf2] = cellfilt({'fillmiss','median'},z,z+1,ndim=[1,2],kernel=[15,15]);
cellplot('contourf',x,y,cat(3,z,zf1,zf2),linestyle='none',axpos=nan,colorbar='on')
%%