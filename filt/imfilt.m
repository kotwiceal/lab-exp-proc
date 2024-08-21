function data = imfilt(data, kwargs)
    %% Batch filtering of 2D data.

    arguments (Input)
        data
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode', 'fillmissing'})} = 'gaussian'
        kwargs.filtker double = [3, 3] % kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string'})} = nan % padding value
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none' % at specifying `fillmissing`
        kwargs.zero2nan (1,1) logical = true
        kwargs.verbose (1,1) logical = true;
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
    end
end