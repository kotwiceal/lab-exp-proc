function data = imfilt(data, kwargs)
    %% Batch filtering of 2D data.

    arguments (Input)
        data
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode', 'fillmissing', 'mediancond'})} = 'gaussian'
        kwargs.filtker double = [3, 3] % kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string'})} = nan % padding value
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none' % at specifying `fillmissing`
        kwargs.zero2nan (1,1) logical = true
        kwargs.verbose (1,1) logical = true
        kwargs.mediancondvars (1,2) double = [1, 1]
    end

    arguments (Output)
        data
    end

    switch kwargs.filt
        case 'average'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker), kwargs.padval);
        case 'gaussian'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker), kwargs.padval);
        case 'median'
            data = nonlinfilt(data, method = @(x) median(x(:), 'omitmissing'), kernel = kwargs.filtker, padval = kwargs.padval, verbose = kwargs.verbose);
        case 'wiener'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = wiener2(data(:, :, i), kwargs.filtker);
            end
            data = reshape(data, sz);
        case 'wiener-median'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = wiener2(data(:, :, i), kwargs.filtker);
            end
            for i = 1:prod(sz(3:end))
                data(:, :, i) = medfilt2(data(:, :, i), kwargs.filtker);
            end
            data = reshape(data, sz);
        case 'mode'
            data = nonlinfilt(data, method = @(x) mode(x(:)), kernel = kwargs.filtker, padval = kwargs.padval, verbose = kwargs.verbose);
        case 'fillmissing'
            if kwargs.method ~= "none"
                if kwargs.zero2nan; data(data==0) = nan; end
                sz = size(data);
                parfor i = 1:prod(sz(3:end))
                    data(:, :, i) = fillmissing2(data(:, :, i), kwargs.method);
                end
                data = reshape(data, sz);
            end
        case 'mediancond'
            data = nonlinfilt(data, method = @(x) kermedcond(x, kwargs.mediancondvars), kernel = kwargs.filtker, ...
                padval = kwargs.padval, verbose = kwargs.verbose);
    end

    function y = kermedcond(x,n)
        szx = size(x); szm = floor(szx/2);
        mask = true(szx); mask(szm(1),szm(2)) = false; mask = mask(:);
        xvar = sqrt(var(x(mask),[],'omitmissing'));
        xmed = median(x(mask),'omitmissing');
        if isnan(x(szm(1),szm(2)))
            y = xmed;
        else
            if (xmed - n(1)*xvar <= x(szm(1),szm(2))) && (xmed + n(2)*xvar >= x(szm(1),szm(2)))
                y = x(szm(1),szm(2));
            else
                y = xmed;
            end
        end
    end

end