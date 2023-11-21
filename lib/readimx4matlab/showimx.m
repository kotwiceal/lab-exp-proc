function [lhs1,lhs2,lhs3,lhs4,lhs5,lhs6,lhs7]=showimx(A, frame)
% CALL:      [lhs1,lhs2,lhs3,lhs4,lhs5,lhs6,lhs7]=showimx(A, frame);
%
% FUNCTION:  Displaying data of LaVision's IMX structure
%            (one vector field, all image frames or only single image frame)
%
% ARGUMENTS: A  = IMX-structure created by READIMX/READIM7 function
%
% RETURN:    in case of images (image type=0):
%               lhs1 = scaled x-coordinates
%               lhs2 = scaled y-coordinates
%               lhs3 = scaled image intensities
%            in case of 2D vector fields (A.IType = 1,2 or 3):
%               lhs1 = scaled x-coordinates
%               lhs2 = scaled y-coordinates
%               lhs3 = scaled vx-components of vectors
%               lhs4 = scaled vy-components of vectors
%               lhs5 = vector choice field 
%            in case of 3D vector fields (A.IType = 4 or 5):
%               lhs1 = scaled x-coordinates
%               lhs2 = scaled y-coordinates
%               lhs3 = scaled z-coordinates
%               lhs4 = scaled vx-components of vectors
%               lhs5 = scaled vy-components of vectors
%               lhs6 = scaled vz-components of vectors
%               lhs7 = vector choice field
if nargin==0,
	help showimx, return
elseif nargin<2
    frame = -1;
elseif ~isscalar(frame)
    frame = -1;
else
    frame = floor(frame);
end
if ~isfield(A,'DaVis'),
	help showimx, return
end
%Check image type and data format
nx = size(A.Data,1);
nz = A.Nz;
ny = A.Ny;
%set data range
baseRangeX = 1:nx; 
baseRangeY = 1:ny;
baseRangeZ = 1:nz;
%initialize left handside values
lhs1 = double( (baseRangeX-0.5)*A.Grid*A.ScaleX(1)+A.ScaleX(2) ); % x-range
lhs2 = double( (baseRangeY-0.5)*A.Grid*A.ScaleY(1)+A.ScaleY(2) ); % y-range
lhs3 = double(0);
lhs4 = double(0);
lhs5 = double(0);
lhs6 = double(0);
lhs7 = double(0);
if A.IType<=0, % grayvalue image format
    % Calculate frame range
    if frame>0 & frame<A.Nf,  baseRangeY = baseRangeY + frame*ny;  end
    lhs3 = double(A.Data(:,baseRangeY)');
    % Display image
	imagesc(lhs1,lhs2,lhs3);
elseif A.IType==2, % simple 2D vector format: (vx,vy)
	% Calculate vector position and components
	[lhs1,lhs2] = ndgrid(lhs1,lhs2);
	lhs3 = double(A.Data(:,baseRangeY   ))*A.ScaleI(1)+A.ScaleI(2);
	lhs4 = double(A.Data(:,baseRangeY+ny))*A.ScaleI(1)+A.ScaleI(2);
    if A.ScaleY(1)<0.0, lhs4 = -lhs4;  end
	quiver(lhs1,lhs2,lhs3,lhs4);
elseif (A.IType==3 | A.IType==1) , % normal 2D vector format + peak: sel+4*(vx,vy) (+peak)
	% Calculate vector position and components
    [lhs1,lhs2] = ndgrid(lhs1,lhs2);
    lhs3 = lhs1*0;
    lhs4 = lhs2*0;
    % Get choice
    maskData = double(A.Data(:,baseRangeY));
	% Build best vectors from choice field
	for i = 0:5,
		mask = ( maskData ==(i+1) );
		if (i<4) % get best vectors
			dat = double(A.Data(:,baseRangeY+(2*i+1)*ny));
			lhs3(mask) = dat(mask);
			dat = double(A.Data(:,baseRangeY+(2*i+2)*ny));
			lhs4(mask) = dat(mask);
		else    % get interpolated vectors
			dat = double(A.Data(:,baseRangeY+7*ny));
			lhs3(mask) = dat(mask);
			dat = double(A.Data(:,baseRangeY+8*ny));
			lhs4(mask) = dat(mask);
		end
    end
	lhs3 = lhs3*A.ScaleI(1)+A.ScaleI(2);
	lhs4 = lhs4*A.ScaleI(1)+A.ScaleI(2);
    %Display vector field
    if A.ScaleY(1)<0.0, lhs4 = -lhs4;  end
	quiver(lhs1,lhs2,lhs3,lhs4);
elseif A.IType==4,
	% Calculate vector position and components
    lhs3 = double((baseRangeZ-0.5)*A.Grid*A.ScaleZ(1)+A.ScaleZ(2));
	[lhs1,lhs2,lhs3] = ndgrid(lhs1,lhs2,lhs3);
    lhs4 = double(zeros([nx ny nz])); lhs5 = lhs4;  lhs6 = lhs4;
    blockSize = ny*nz;
    for i=1:nz,
        lhs4(:,:,i)=double( A.Data(:,baseRangeY+(i-1)*ny) );
        lhs5(:,:,i)=double( A.Data(:,baseRangeY+(i-1)*ny+blockSize) );
        lhs6(:,:,i)=double( A.Data(:,baseRangeY+(i-1)*ny+2*blockSize) );
    end
	lhs4 = lhs4*A.ScaleI(1)+A.ScaleI(2);
	lhs5 = lhs5*A.ScaleI(1)+A.ScaleI(2);
	lhs6 = lhs6*A.ScaleI(1)+A.ScaleI(2);
    if A.ScaleY(1)<0.0, lhs5 = -lhs5;  end
    disp('Info: for display call [x,y,z,u,v,w]=showimx(A); quiver3(x,y,z,u,v,w);')
    return;
	%quiver3(lhs1,lhs2,lhs3, lhs4,lhs5,lhs6);
elseif (A.IType==5 | A.IType==6),
	% Prepare data
    blockSize = ny*nz;
    lhs4 = double(zeros(nx, blockSize)); % U
    lhs5 = double(zeros(nx, blockSize)); % V
    lhs6 = double(zeros(nx, blockSize)); % W
    % Block decomposition. We assume 13 or more blocks [ch, u1,v1,w1, u2,v2,w2, u3,v3,w3, u4,v4,w4, pr(optional)]
    blockRangeY = 1:blockSize;
    % Get 2D choice block field 
    lhs7 = double(A.Data(:,blockRangeY));
	% Build flat vector fields from choice
	for i = 0:5,
		mask = ( lhs7 == (i+1) );
        if (max(max(mask))==0), continue, end
        if (i<4)
            dat = double(A.Data(:,blockRangeY+(i*3+1)*blockSize));
            lhs4(mask) = dat(mask);
            dat = double(A.Data(:,blockRangeY+(i*3+2)*blockSize));
            lhs5(mask) = dat(mask);
            dat = double(A.Data(:,blockRangeY+(i*3+3)*blockSize));
            lhs6(mask) = dat(mask);
        else
            dat = double(A.Data(:,blockRangeY+10*blockSize));
            lhs4(mask) = dat(mask);
            dat = double(A.Data(:,blockRangeY+11*blockSize));
            lhs5(mask) = dat(mask);
            dat = double(A.Data(:,blockRangeY+12*blockSize));
            lhs6(mask) = dat(mask);
        end
    end
   % Compile (x,y,z) positions
    lhs3 = double( (baseRangeZ-0.5)*A.Grid*A.ScaleZ(1)+A.ScaleZ(2) );
 	[lhs1,lhs2,lhs3] = ndgrid(lhs1,lhs2,lhs3);
    % Compile (u,v,w) vectors (by reshaping block results)
    lhs4=reshape(lhs4,nx,ny,nz);
    lhs5=reshape(lhs5,nx,ny,nz);
    lhs6=reshape(lhs6,nx,ny,nz);
    lhs7=reshape(lhs7,nx,ny,nz);
    % Scale vectors
 	lhs4 = lhs4*A.ScaleI(1)+A.ScaleI(2);
 	lhs5 = lhs5*A.ScaleI(1)+A.ScaleI(2);
 	lhs6 = lhs6*A.ScaleI(1)+A.ScaleI(2);
    if A.ScaleY(1)<0.0, lhs5 = -lhs5;  end
    disp('Info: for display call [x,y,z,u,v,w]=showimx(A); quiver3(x,y,z,u,v,w);')
    return;
	%quiver3(lhs1,lhs2,lhs3, lhs4,lhs5,lhs6);
end
% Set label, axis and figure properties
xlabel([A.LabelX ' ' A.UnitX]);
ylabel([A.LabelY ' ' A.UnitY]);
title ([A.LabelI ' ' A.UnitI]);
set(gcf,'Name',A.Source);
if A.IType>0, set(gcf,'color','w'); end
set(gca,'color',[.9 .9 .9]);
if A.ScaleY(1)>=0.0,
    axis ij;
else
    axis xy;
end
