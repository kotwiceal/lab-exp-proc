%% data 1D, filt 1D, gaussian
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
yf = ndfilt(y,filt='gaussian',filtker=10,padval='symmetric');
cellplot('plot',x,cat(2,y,yf))
%% data 2D, filt 1D, gaussian
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2);
yf = ndfilt(y,filt='gaussian',filtker=15,padval='symmetric');
cellplot('plot',x,cat(2,y,yf))
%% data 3D, filt 1D, gaussian
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2, y+3);
y = permute(y, [2, 3, 1]);

yf = ndfilt(y,filt='gaussian',filtker=15,padval='symmetric',filtdim=3);
yf = permute(yf, [2, 1]);
y = permute(y, [3, 1, 2]);
cellplot('plot',x,cat(2,y,yf))
%% data 1D, filt 1D, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
yf = ndfilt(y,filt='median',filtker=10,padval='symmetric');
cellplot('plot',x,cat(2,y,yf))
%% data 2D, filt 1D, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2);
yf = ndfilt(y,filt='median',filtker=15,padval='symmetric');
cellplot('plot',x,cat(2,y,yf))
%% data 3D, filt 1D, median
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y = cat(2, y, y+2, y+3);
y = permute(y, [2, 3, 1]);

yf = ndfilt(y,filt='median',filtker=15,padval='symmetric',filtdim=3);
yf = permute(yf, [2, 1]);
y = permute(y, [3, 1, 2]);
cellplot('plot',x,cat(2,y,yf))
%% data 1D, filt 1D, fillmiss
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
yf = ndfilt(y,filt='fillmiss',filtker=10,padval='symmetric',filtdim=1);
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 2D, filt 1D, fillmiss
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
y = cat(2, y, y + 2);
yf = ndfilt(y,filt='fillmiss',filtker=15,padval='symmetric');
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 3D, filt 1D, fillmiss
x = linspace(0,1)';
y = sin(10*x)+0.5*rand(size(x));
y(randi([1, numel(x)],50,1)) = nan;
y = cat(2, y, y + 2, y + 3);
y = permute(y, [2, 3, 1]);
yf = ndfilt(y,filt='fillmiss',filtker=15,padval='symmetric',filtdim=3);
y = permute(y, [3, 1, 2]);
cellplot('plot',x,cat(2,y,yf),axpos=nan)
%% data 2D, filt 2D, gaussian
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
zf = ndfilt(z,filt='gaussian',filtker=[10,10],padval='symmetric');
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, gaussian
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z = cat(3, z, z + 1);
zf = ndfilt(z,filt='gaussian',filtker=[10,10],padval='symmetric');
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, gaussian
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z = cat(3, z, z + 1);
z = permute(z, [2, 3, 1]);
zf = ndfilt(z,filt='gaussian',filtker=[10,10],padval='symmetric',filtdim=[1,3]);
zf = permute(zf, [1, 3, 2]);
z = permute(z, [1, 3, 2]);
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 2D, filt 2D, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
zf = ndfilt(z,filt='median',filtker=[10,10],padval='symmetric');
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z = cat(3, z, z + 1);
zf = ndfilt(z,filt='median',filtker=[10,10],padval='symmetric');
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, median
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z = cat(3, z, z + 1);
z = permute(z, [2, 3, 1]);
zf = ndfilt(z,filt='median',filtker=[10,10],padval='symmetric',filtdim=[1,3]);
zf = permute(zf, [1, 3, 2]);
z = permute(z, [1, 3, 2]);
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 2D, filt 2D, fillmiss
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
zf = ndfilt(z,filt='fillmiss',filtker=[10,10],padval='symmetric');
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, fillmiss
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
z = cat(3, z, z + 1);
zf = ndfilt(z,filt='fillmiss',filtker=[10,10],padval='symmetric');
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)
%% data 3D, filt 2D, fillmiss
[x,y] = meshgrid(linspace(0,1),linspace(1,2));
z = sin(10*x+20*y)+0.5*rand(size(x));
z(randi([1, numel(x)],200,1)) = nan;
z = cat(3, z, z + 1);
z = permute(z, [2, 3, 1]);
zf = ndfilt(z,filt='fillmiss',filtker=[10,10],padval='symmetric',filtdim=[1,3]);
zf = permute(zf, [1, 3, 2]);
z = permute(z, [1, 3, 2]);
cellplot('contourf',x,y,cat(3,z,zf),linestyle='none',axpos=nan)