function data = imagfilter(data, kwargs)
%% Multidimenstion data fitlering by build-in methods
%% The function takes following arguments:
%   data:           [n×m... double]         - multidimensional data
%   filt:           [char array]            - filter name
%   filtker:        [1×2 double]            - kernel size
%   weight:         [n×m... double]         - gridded window function by shape initial data to perform weighted filtering
%   weightname:     [char array]            - name of window function 
%   weightparam:    [1×k double]            - parameters of window function 
%% The function returns following results:
%   data:           [n×m... double]         - filtered data

    arguments
        data double
        kwargs.filt (1,:) char {mustBeMember(kwargs.filt, {'none', 'gaussian', 'average', 'median', 'median-omitmissing', 'median-weighted', 'wiener', 'median-wiener', 'mode'})} = 'gaussian'
        kwargs.filtker double = [3, 3]
        kwargs.weight double = []
        kwargs.weightname (1,:) char {mustBeMember(kwargs.weightname, {'tukeywin'})} = 'tukeywin'
        kwargs.weightparam double = [0.05, 0.05]
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
                data = nlpfilter(data, kwargs.filtker, @(x) mode(x(:)));
    end
end