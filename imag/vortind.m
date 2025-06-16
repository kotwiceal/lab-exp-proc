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
        kwargs.fillmiss (1,:) char {mustBeMember(kwargs.fillmiss, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        % prefilter kernel
        kwargs.prefilt (1,:) char {mustBeMember(kwargs.prefilt, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'none'
        kwargs.prefiltker double = [3, 3] % prefilter kernel size
        % portfilter type
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'none', 'gaussian', 'average', 'median', 'wiener'})} = 'none'
        kwargs.postfiltker (1,:) double = [15, 15] % postfilter kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = 'symmetric' % padding value
    end

    sz = size(u);
    difkerh = memoize(@(x) cat(3, difkernel(x), difkernel(x)'));
    difker = difkerh(kwargs.diffilt);

    % velocity fill missing
    u = imfilt(u, filt = 'fillmiss', method = kwargs.fillmiss, zero2nan = true);
    w = imfilt(w, filt = 'fillmiss', method = kwargs.fillmiss, zero2nan = true);

    % velocity prefiltering
    u = imfilt(u, filt = kwargs.prefilt, filtker = kwargs.prefiltker);
    w = imfilt(w, filt = kwargs.prefilt, filtker = kwargs.prefiltker);

    % differentiation
    dudx = imfilter(u, difker(:,:,1), 'symmetric'); dudz = imfilter(u, difker(:,:,2), 'symmetric');
    dwdx = imfilter(w, difker(:,:,1), 'symmetric'); dwdz = imfilter(w, difker(:,:,2), 'symmetric');

    % gradient prefiltering
    dudx = imfilt(dudx, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);
    dudz = imfilt(dudz, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);
    dwdx = imfilt(dwdx, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);
    dwdz = imfilt(dwdz, filt = kwargs.prefilt, filtker = kwargs.prefiltker, padval = kwargs.padval);

    gradvel = cat(3, dudx, dudz, dwdx, dwdz);
    gradvel = reshape(gradvel, [sz(1:2), 2, 2]);
    gradvel = permute(gradvel, [ndims(gradvel)-1, ndims(gradvel), 1:ndims(gradvel)-2]);
       
    switch kwargs.type
        case 'q'
            symmat = 1/2*(gradvel+pagetranspose(gradvel));
            skewmat = 1/2*(gradvel-pagetranspose(gradvel));

            symmatdet = det2d(symmat);
            symmatdet = reshape(symmatdet, size(u));
        
            skewmatdet = det2d(skewmat);
            skewmatdet = reshape(skewmatdet, size(u));
        
            temporary =skewmatdet.^2 - symmatdet.^2;
        case 'l2'
            symmat = 1/2*(gradvel+pagetranspose(gradvel));
            skewmat = 1/2*(gradvel-pagetranspose(gradvel));

            mat = pagemtimes(symmat, symmat) + pagemtimes(skewmat, skewmat);
    
            e = squeeze(pageeig(mat));
            temporary = reshape(e(kwargs.eigord,:), sz(1:2));
        case 'd'              
            temp = tr2d(gradvel).^2-4*det2d(gradvel);
            temporary = reshape(temp, sz(1:2));
    end

    switch kwargs.threshold
        case 'neg'
            temporary(temporary<0) = 0;
        case 'pos'
            temporary(temporary>0) = 0;
    end

    if ~isempty(kwargs.pow)
        temporary = temporary.^kwargs.pow;
    end

    if kwargs.abs
        temporary = abs(temporary);
    end

    % postfiltering
    result = imfilt(temporary, filt = kwargs.postfilt, filtker = kwargs.postfiltker, padval = kwargs.padval);

end

function y = det2d(x)
    y = squeeze(x(1,1,:).*x(2,2,:)-x(1,2,:).*x(2,1,:));
end

function y = tr2d(x)
    y = squeeze(x(1,1,:)+x(2,2,:));
end