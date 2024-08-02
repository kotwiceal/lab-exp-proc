function data = imfilt(data, kwargs)
    %% Filter multidimensional data.

    arguments
        data double % multidimensional data
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'wiener', 'wiener-median', 'mode', 'fillmissing'})} = 'gaussian'
        kwargs.filtker double = [3, 3] % kernel size
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string'})} = nan
    end

    switch kwargs.filt
        case 'average'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker), kwargs.padval);
        case 'gaussian'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker), kwargs.padval);
        case 'median'
            data = nonlinfilt(data, method = @(x) median(x(:), 'omitmissing'), kernel = kwargs.filtker, padval = kwargs.padval);
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
            data = nonlinfilt(data, method = @(x) mode(x(:)), kernel = kwargs.filtker, padval = kwargs.padval);
        case 'fillmissing'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = fillmissing2(data(:, :, i), 'nearest');
            end
            data = reshape(data, sz);
    end
end