function result = vortind(u, w, named)
%% Process a vortex identification criteria
%% The function takes following arguments:
%   u:          [n×m×... double]    - first vector component
%   w:          [n×m×... double]    - second vector component
%   type:       [char array]        - type of vortex identification criteria
%   threshold:  [logical]           - apply threshold 
%   filter:     [char array]        - difference schema
%   smooth:     [char array]        - smooth filter
%   kernel:     [double k×l]        - kernel of smooth filter
%
%% The function returns following results:
%   result:     [n×mx... double]    - vortex identification criteria

    arguments
        u double
        w double
        named.type (1,:) char {mustBeMember(named.type, {'q', 'l2', 'd'})} = 'q'
        named.difkernel (1,:) char {mustBeMember(named.difkernel, {'sobel', '4ord', '4ordgauss', '2ord'})} = 'sobel'
        named.threshold logical = true
        named.smooth (1,:) char {mustBeMember(named.smooth, {'average', 'gaussian', 'none'})} = 'gaussian'
        named.kernel double = [3, 3]
    end

    Gx = difkernel(named.difkernel); Gz = Gx';

    dudx = imfilter(u, Gx); dudz = imfilter(u, Gz);
    dwdx = imfilter(w, Gx); dwdz = imfilter(w, Gz);

    % prefiltering
    switch named.smooth
        case 'none'
        otherwise
            try
                kernel = fspecial(named.smooth, named.kernel);
                dudx = imfilter(dudx, kernel); dudz = imfilter(dudz, kernel);
                dwdx = imfilter(dwdx, kernel); dwdz = imfilter(dwdz, kernel);
            catch
            end
    end

    gradvel = cat(ndims(u)+1, dudx, dudz, dwdx, dwdz);

    gradvel = reshape(gradvel, [size(u), 2, 2]);
    gradvel = permute(gradvel, [ndims(gradvel)-1, ndims(gradvel), 1:ndims(gradvel)-2]);
    
    clear dudx dudz dwdx dwdz

    switch named.type
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
            
            result = abs(skewmatdet) - abs(symmatdet);
        case 'l2'
            symmat = 1/2*(gradvel+pagetranspose(gradvel));
            skewmat = 1/2*(gradvel-pagetranspose(gradvel));

            mat = pagemtimes(symmat, symmat) + pagemtimes(skewmat, skewmat);

            clear symmat skewmat

            e = squeeze(pageeig(mat));
            result = reshape(e(1,:), size(u));
        case 'd'
            det2d = @(mat) squeeze(mat(1,1,:).*mat(2,2,:)-mat(1,2,:).*mat(2,1,:));
            tr2d = @(mat) squeeze(mat(1,1,:)+mat(2,2,:));
            
            result = tr2d(gradvel).^2-4*det2d(gradvel);
            result = reshape(result, size(u));
        otherwise
            result = [];
    end

    if named.threshold
        result(result<0) = 0;
    end

end