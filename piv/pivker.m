function varargout = pivker(x, y, kwargs)
    %% Sliding window kernel to calculate local peeks of cross-correlation matrix for PIV method. 

    arguments
        x (:,:,:)
        y (:,:,:)
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'fft', 'normfft'})} = 'fft'
        kwargs.centre (1,1) logical = true
        kwargs.findlocmax (1,:) char {mustBeMember(kwargs.findlocmax, {'morph', 'max'})} = 'morph'
        kwargs.subpixint (1,:) {mustBeMember(kwargs.subpixint, {'none', 'gaussian', 'parabolic', 'centroid', 'gaussian2d', 'gaussian2dt'})} = 'gaussian2d'
        kwargs.weight (:,:) double = []
        kwargs.msz (1,:) double = []
        kwargs.padding (1,2) cell = {[],[]}
    end

    if kwargs.centre
        x = x - mean(x, [1, 2]);
        y = y - mean(y, [1, 2]);
    end

    if ~isempty(kwargs.weight)
        x = x.*kwargs.weight;
        y = y.*kwargs.weight;
    end

    if ~isempty(kwargs.padding{1})
        x = padarray(x, kwargs.padding{1}, 0, 'both');
    end
    if ~isempty(kwargs.padding{2})
        y = padarray(y, kwargs.padding{2}, 0, 'both');
    end

    switch kwargs.method
        case 'fft'
            method = @(x,y) abs(mean(fftshift(fftshift(ifft2(fft2(x).*conj(fft2(y))),1),2),3));
        case 'normfft'
            method = @(x,y) abs(mean(fftshift(fftshift( ifft2( fft2(x).*conj(fft2(y))./sqrt(abs(fft2(x)).^2.*abs(fft2(y)).^2) ), 1),2),3));
    end

    % calculate cross-correlation maxtix
    R = method(x,y); sz = size(R);
    % unbiased correction of cross-correlation maxtix
    % R = R.*rescale(1-triang(sz(1)).*triang(sz(2))',0.5,1);
    % R = R.*(triang(sz(1)).*triang(sz(2))'-0.5);
    % find local maxima
    X = pivfindlocmax(R, method = kwargs.findlocmax, msz = kwargs.msz);

    if isempty(X)
        vec = nan(4,2);
        amp = nan(4,1);
    else
        % delete boundary points
        index = (X(:,1) == 1) | (X(:,1) == sz(1)) | (X(:,2) == 1) | (X(:,2) == sz(2));
        X(index,:) = [];
        if isempty(X)
            vec = nan(4,2);
            amp = nan(4,1);
        else
            % calculate subpixel offset
            subpixoff = [0.5,0.5];
            subpixoff(logical(rem(sz,2))) = 1;
            % subpixoff(logical(rem(sz,2))) = 0;
            % subpixel interpolation
            [dX, amp] = pivsubpixint(R,X,kwargs.subpixint);
            % calculate displacement
            X = X + dX - sz/2 - subpixoff;
            % sort displacement by peaks amplitude
            [amp, index] = sort(amp,'descend');
            X = X(index,:);
            % restrict peaks count
            if size(X,1) > 4
                X = X(1:4,:);
                amp = amp(1:4);
            else
                X = padarray(X, 4-size(X, 1), nan, 'post');
                amp = padarray(amp, 4-size(amp, 1), nan, 'post');
            end
            vec = X;
        end
    end

    varargout{1} = [vec, amp];
end