function result = vortind(u, w, kwargs)
    %% Process a vortex identification criteria

    arguments
        u double % first vector component
        w double % second vector component
        % type of vortex identification criteria
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'q', 'l2', 'd'})} = 'q'
        % differentiation kernel
        kwargs.diffilt (1,:) char {mustBeMember(kwargs.diffilt, {'sobel', '4ord', '4ordgauss', '2ord'})} = 'sobel'
        % threshold type
        kwargs.threshold (1,:) char {mustBeMember(kwargs.threshold, {'none', 'neg', 'pos'})} = 'none'
        kwargs.pow double = [] % raise result to the power
        kwargs.abs logical = false % absolute value of result
        kwargs.eigord double = 1 % eigenvalue odrer
        % prefilter kernel
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3] % prefilter kernel size
    end

    % velocity prefiltering
    u = imfilt(u, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    w = imfilt(w, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

    % derivation
    Gx = difkernel(kwargs.diffilt); Gz = Gx';
    dudx = imfilter(u, Gx); dudz = imfilter(u, Gz);
    dwdx = imfilter(w, Gx); dwdz = imfilter(w, Gz);

    % gradient prefiltering
    dudx = imfilt(dudx, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    dudz = imfilt(dudz, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    dwdx = imfilt(dwdx, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    dwdz = imfilt(dwdz, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

    gradvel = cat(ndims(u)+1, dudx, dudz, dwdx, dwdz);
    gradvel = reshape(gradvel, [size(u), 2, 2]);
    gradvel = permute(gradvel, [ndims(gradvel)-1, ndims(gradvel), 1:ndims(gradvel)-2]);
    
    clear dudx dudz dwdx dwdz

    switch kwargs.type
        case 'q'
            symmat = 1/2*(gradvel+pagetranspose(gradvel));
            skewmat = 1/2*(gradvel-pagetranspose(gradvel));
            
            det2d = @(mat) squeeze(mat(1,1,:).*mat(2,2,:)-mat(1,2,:).*mat(2,1,:));
            
            symmatdet = det2d(symmat);
            symmatdet = reshape(symmatdet, size(u));
            
            clear symmat
        
            skewmatdet = det2d(skewmat);
            skewmatdet = reshape(skewmatdet, size(u));
        
            clear skewmat
            
            % result = abs(skewmatdet) - abs(symmatdet);
            result =skewmatdet.^2 - symmatdet.^2;
        case 'l2'
            symmat = 1/2*(gradvel+pagetranspose(gradvel));
            skewmat = 1/2*(gradvel-pagetranspose(gradvel));

            mat = pagemtimes(symmat, symmat) + pagemtimes(skewmat, skewmat);

            clear symmat skewmat

            e = squeeze(pageeig(mat));
            result = reshape(e(kwargs.eigord,:), size(u));
        case 'd'
            det2d = @(mat) squeeze(mat(1,1,:).*mat(2,2,:)-mat(1,2,:).*mat(2,1,:));
            tr2d = @(mat) squeeze(mat(1,1,:)+mat(2,2,:));
            
            result = tr2d(gradvel).^2-4*det2d(gradvel);
            result = reshape(result, size(u));
        otherwise
            result = [];
    end

    switch kwargs.threshold
        case 'neg'
            result(result<0) = 0;
        case 'pos'
            result(result>0) = 0;
    end

    if ~isempty(kwargs.pow)
        result = result.^kwargs.pow;
    end

    if kwargs.abs
        result = abs(result);
    end

end