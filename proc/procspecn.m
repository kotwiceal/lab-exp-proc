function [spec, f] = procspecn(data, kwargs)
    %% Process a multidimensional short-time Fourier transform.

    arguments
        data double
        kwargs.ftdim (1,:) double = [] % dimensions to apply transform
        kwargs.chdim (1,:) double = [] % dimensions to process cross spectra
        kwargs.winlen (1,:) double = 1024 % transform window lengths
        kwargs.overlap (1,:) double = 512 % transform window overlaps
        kwargs.side (1,:) char {mustBeMember(kwargs.side, {'single', 'double'})} = 'single' % spectra process mode
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'amp', 'power'})} = 'power' % spectra process mode
        kwargs.avg (1,1) logical = true % averaging by statistics of spectra
        kwargs.fs (1,:) double = [] % sampling frequency
        kwargs.center (1,1) logical = true % centre data at transform
        kwargs.winfun (1,:) char {mustBeMember(kwargs.winfun, {'none', 'hann'})} = 'hann' % to weight data at transform
        kwargs.norm (1,1) logical = true % norm for spectral density
    end

    szd = size(data); nd = ndims(data); ndw = numel(kwargs.winlen);

    if isempty(kwargs.ftdim); kwargs.ftdim = 1:numel(kwargs.winlen); end
    if isempty(kwargs.fs); kwargs.fs = ones(1, numel(kwargs.winlen)); end

    % generate frequency grid
    f = cell(1, numel(kwargs.winlen));
    df = zeros(1, numel(kwargs.winlen));
    find = zeros(1, numel(kwargs.winlen));
    for i = 1:numel(kwargs.winlen)
        n = kwargs.winlen(i);
        nh = floor(n/2);
        nh1 = nh + mod(n,2);
        df(i) = kwargs.fs(i)/n;
        switch kwargs.side
            case 'single'
                f{i} = df(i) * (0:nh);
                find(i) = nh1+1;
            case 'double'
                f{i} = df(i) * (-nh:nh1-1);
        end
        [f{:}] = ndgrid(f{:});
        if numel(f) == 1; f = f{1}; end
    end

    switch kwargs.winfun
        case 'none'
            if isvector(kwargs.winlen)
                win = ones(kwargs.winlen, 1);
            else
                win = ones(kwargs.winlen);
            end
        case 'hann'
            win = hann(kwargs.winlen(1));
            if ~isvector(kwargs.winlen); for i = 2:numel(kwargs.winlen); win = win.*shiftdim(hann(kwargs.winlen(i)),-i+1); end; end
    end

    kernel = zeros(1, nd); kernel(kwargs.ftdim) = kwargs.winlen;
    stride = ones(1, nd); stride(kwargs.ftdim) = kwargs.overlap;
    spec = nonlinfilt(data, method = @specker, kernel = kernel, stride = stride, shape='valid');

    arbind = 1:ndims(spec); arbind([kwargs.ftdim, nd+1:numel(kwargs.winlen)+nd]) = [];

    spec = permute(spec, [nd+1:numel(kwargs.winlen)+nd, kwargs.ftdim, arbind]); % permute dims
    spec = spec./sqrt(kwargs.winlen); % norm spectra

    szs = size(spec);
    switch kwargs.side
        case 'single'
            ind = cell(1, numel(find) + nd);
            for i = 1:numel(find); ind{i} = 1:find(i); end
            for i = 1:nd; ind{i + numel(find)} = 1:szs(i + numel(find)); end
            spec = spec(ind{:})*sqrt(2); % amplitude correction
            for i = 1:numel(find); ind{i} = 1; end
            spec(ind{:}) = spec(ind{:})./sqrt(2); % zero frequency without amplitude correction
            szs = size(spec);
        case 'double'
            for i = 1:numel(kwargs.winlen); spec = fftshift(spec, i); end % shift nodes
    end

    cf = ones(1, numel(kwargs.winlen));
    switch kwargs.type
        case 'power'
            for i = 1:numel(kwargs.winlen); cf(i) = 1./rms(win, i); end

            if isempty(kwargs.chdim)
                spec = spec./conj(spec);
            else
                indg = cell(1, numel(kwargs.winlen) + nd - 1);
                szst = szs; szst(numel(kwargs.winlen)+kwargs.chdim) = [];
                for i = 1:numel(szst); indg{i} = 1:szst(i); end

                indi = cell(1, numel(kwargs.winlen) + nd);
                for i = 1:ndims(spec); indi{i} = 1:szs(i); end
                indj = indi;

                temp = [];
                for i = 1:szd(kwargs.chdim)
                    indi{kwargs.chdim+numel(kwargs.winlen)} = i;
                    for j = 1:szd(kwargs.chdim)
                        indj{kwargs.chdim+numel(kwargs.winlen)} = j;
                        indt = cat(2, indg, i, j);
                        temp(indt{:}) = spec(indi{:}).*conj(spec(indj{:}));
                    end
                end
                spec = temp; clear temp;
            end
        case 'amp'
            for i = 1:numel(kwargs.winlen); cf(i) = 1./mean(win, i); end
    end

    if kwargs.avg; spec = squeeze(mean(spec, (1:numel(kwargs.winlen)) + numel(kwargs.winlen))); end

    spec = spec.*cf; % window function correction factor

    if kwargs.norm; spec = spec./df; end % norm to spectral density

    function y = specker(x)
        x = squeeze(x);
        if kwargs.center; for k = 1:ndw; x = normalize(x,k,'center'); end; end % centre data
        x = x.*win; % weight data by window function
        y = fftn(x); % process mult. dim. FFT
    end

end