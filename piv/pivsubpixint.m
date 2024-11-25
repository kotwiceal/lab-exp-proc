function [dX, amp] = pivsubpixint(R,X,type)
    %% Subpixel interpolation of cross-correlation matrix peaks for PIV method.

    % Raffel, M., Kähler, C. J., Willert, C. E., Wereley, S. T., 
    % Scarano, F., & Kompenhans, J. (2018). 
    % Particle Image Velocimetry: A Practical Guide. (3rd ed.) Springer. 
    % https://doi.org/10.1007/978-3-319-68852-7

    %% test
    % R = reshape(1:32^2,32,32);
    % X = [5, 5; 4, 4; 7, 8; 10, 20];
    % dX = pivsubpixint(R,X,'gaussian2d');

    arguments (Input)
        R (:,:) %% cross-correlation matrix
        X (:,2) % point-wise vector of peaks location
        type (1,:) char {mustBeMember(type, {'none', 'gaussian', 'parabolic', 'centroid', 'gaussian2d'})}
    end

    arguments (Output)
        dX (:,2)
        amp (:,1)
    end
    
    index = permute(reshape(sub2ind(size(R),reshape(reshape(repmat([-1,0,1],3,1),1,[])+X(:,1),[],1), ...
        reshape(reshape(repmat([-1,0,1]',1,3),1,[])+X(:,2),[],1)), ...
        [size(X,1),3,3]), [2, 3, 1]);

    R = R(index);

    switch type
        case 'gaussian'
            R = log(R);
            if ismatrix(R); R = shiftdim(R,-1); else; R = permute(R,[3,1,2]); end
        case 'gaussian2d'
            R = log(R);
        otherwise
            if ismatrix(R); R = shiftdim(R,-1); else; R = permute(R,[3,1,2]); end
    end

    switch type
        case 'gaussian'
            dX = cat(2, (R(:,1,2)-R(:,3,2))./(2*R(:,1,2)-4*R(:,2,2)+2*R(:,3,2)), ...
                (R(:,2,1)-R(:,2,3))./(2*R(:,2,1)-4*R(:,2,2)+2*R(:,2,3)));
            amp = zeros(size(X,1),1);
        case 'parabolic'
            dX = cat(2, (R(:,1,2)-R(:,3,2))/(2*R(:,1,2)-4*R(:,2,2)+2*R(:,3,2)), ...
                (R(:,2,1)-R(:,2,3))/(2*R(:,2,1)-4*R(:,2,2)+2*R(:,2,3)));
            amp = zeros(size(X,1),1);
        case 'centroid'
            dX = cat(2, ((X(:,1)-1).*R(:,1,2)+X(:,1).*R(:,2,2)+(X(:,1)+1).*R(:,3,2))./(R(:,1,2)+R(:,2,2)+R(:,3,2)), ...
                ((X(:,2)-1).*R(:,2,1)+X(:,2).*R(:,2,2)+(X(:,2)+1).*R(:,2,3))./(R(:,2,1)+R(:,2,2)+R(:,2,3)));
            amp = zeros(size(X,1),1);
        case 'gaussian2d'
            % Nobach, H., Honkanen, M. Two-dimensional Gaussian regression for 
            % sub-pixel displacement estimation in particle image velocimetry or 
            % particle position estimation in particle tracking velocimetry. 
            % Exp Fluids 38, 511–515 (2005). https://doi.org/10.1007/s00348-005-0942-3

            c = cat(3, 1/6*repmat((-1:1)', 1, 3), 1/6*repmat((-1:1), 3, 1), 1/4*(-1:1)'.*(-1:1), ...
                1/6*(3*repmat((-1:1)', 1, 3).^2-2), 1/6*(3*repmat((-1:1), 3, 1).^2-2), ...
                1/9*(5-3*repmat((-1:1), 3, 1).^2-3*repmat((-1:1)', 1, 3).^2));
            c = tensorprod(R,c,[1,2],[1,2]);
            if iscolumn(c); c = c'; end
            dX = cat(2, (c(:,3).*c(:,1)-2*c(:,2).*c(:,4))./(4*c(:,4).*c(:,5)-c(:,3).^2), ...
                (c(:,3).*c(:,2)-2*c(:,1).*c(:,5))./(4*c(:,4).*c(:,5)-c(:,3).^2));
            amp = exp(c(:,6)-c(:,4).*dX(:,1).^2-c(:,3).*dX(:,1).*dX(:,2)-c(:,5).*dX(:,2).^2);
        otherwise
            dX = zeros(size(X));
            amp = R(:,2,2);
    end

end