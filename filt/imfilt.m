function data = imfilt(data, kwargs)
%% Multidimenstion data fitlering by build-in methods

    arguments
        data double % multidimensional data
        % filter name
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'wiener-median', 'mode'})} = 'gaussian'
        kwargs.filtker double = [3, 3] % kernel size
        kwargs.weight double = []
        % gridded window function by shape initial data to perform weighted filtering
        kwargs.weightname (1,:) char {mustBeMember(kwargs.weightname, {'tukeywin'})} = 'tukeywin'
        % name of window function 
        kwargs.weightparam double = [0.05, 0.05] % parameters of window function 
        kwargs.omitmissing logical = true
    end

    switch kwargs.filt
        case 'average'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker));
        case 'gaussian'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker));
        case 'median'
            data = nlpfilter(data, kwargs.filtker, @(x) median(x(:)));
        case 'median-omitmissing'
            data = nlpfilter(data, kwargs.filtker, @(x) median(x(:), 'omitmissing'));
        case 'median-weighted'
            if isempty(kwargs.weight)
                sz = size(data);
                switch kwargs.weightname
                    case 'tukeywin'
                        weight = tukeywin(sz(1), kwargs.weightparam(1)).*tukeywin(sz(2), kwargs.weightparam(2))';
                end
            else
                weight = kwargs.weight;
            end
            nlkernel = @(x, y) median(x(:).*y(:), 'omitmissing');
            data = nlpfilter(data, kwargs.filtker, @(x, y) nlkernel(x, y), y = weight, type = 'slice-cross');
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
                data = nlpfilter(data, kwargs.filtker, @(x) mode(x(:)));
    end
end