function result = vortind(u, w, kwargs)
%% Process a vortex identification criteria
%% The function takes following arguments:
%   u:              [n×m×... double]    - first vector component
%   w:              [n×m×... double]    - second vector component
%   type:           [char array]        - type of vortex identification criteria
%   threshold:      [char array]        - apply threshold 
%   pow:            [1×1 double]        - raise to the power of processing value
%   abs:            [1×1 logical]       - absolute value
%   eigord:         [1×1 double]        - eigen-value order
%   diffilter:      [char array]        - difference schema
%   prefilter:      [char array]        - smooth filter
%   prefiltker:     [1×2 double]        - kernel of smooth filter
%
%% The function returns following results:
%   result:     [n×mx... double]    - vortex identification criteria

    arguments
        u double
        w double
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'q', 'l2', 'd'})} = 'q'
        kwargs.diffilter (1,:) char {mustBeMember(kwargs.diffilter, {'sobel', '4ord', '4ordgauss', '2ord'})} = 'sobel'
        kwargs.threshold (1,:) char {mustBeMember(kwargs.threshold, {'none', 'neg', 'pos'})} = 'none'
        kwargs.pow double = []
        kwargs.abs logical = false
        kwargs.eigord double = 1
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3]
    end

    % velocity prefiltering
    u = imagfilter(u, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    w = imagfilter(w, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

    % derivation
    Gx = difkernel(kwargs.diffilter); Gz = Gx';
    dudx = imfilter(u, Gx); dudz = imfilter(u, Gz);
    dwdx = imfilter(w, Gx); dwdz = imfilter(w, Gz);

    % gradient prefiltering
    dudx = imagfilter(dudx, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    dudz = imagfilter(dudz, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    dwdx = imagfilter(dwdx, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    dwdz = imagfilter(dwdz, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

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
            
            result = abs(skewmatdet) - abs(symmatdet);
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