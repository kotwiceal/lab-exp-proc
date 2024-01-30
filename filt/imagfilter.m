function data = imagfilter(data, kwargs)
%% Multidimenstion data fitlering by build-in methods
%% The function takes following arguments:
%   data:           [n×m... double]         - multidimensional data
%   filt:           [char array]            - filter name
%   filtker:        [1×2 double]            - kernel size
%% The function returns following results:
%   data:              [n×m... double]         - filtered data

    arguments
        data double
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'wiener', 'median-wiener', 'mode'})} = 'gaussian'
        kwargs.filtker double = [3, 3]
    end

    switch kwargs.filt
        case 'average'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker));
        case 'gaussian'
            data = imfilter(data, fspecial(kwargs.filt, kwargs.filtker));
        case 'median'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = medfilt2(data(:, :, i), kwargs.filtker);
            end
            data = reshape(data, sz);
        case 'wiener'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = wiener2(data(:, :, i), kwargs.filtker);
            end
            data = reshape(data, sz);
        case 'median-wiener'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = medfilt2(data(:, :, i), kwargs.filtker);
            end
            for i = 1:prod(sz(3:end))
                data(:, :, i) = wiener2(data(:, :, i), kwargs.filtker);
            end
            data = reshape(data, sz);
        case 'mode'
            sz = size(data);
            for i = 1:prod(sz(3:end))
                data(:, :, i) = modefilt(data(:, :, i), kwargs.filtker);
            end
            data = reshape(data, sz);
    end
end