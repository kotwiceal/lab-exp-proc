function [spec, f] = procspecn(data, kwargs)
    %% Process a multidimensional short-time Fourier transform.

    arguments
        data double
        kwargs.ftdim (1,:) double = [] % dimensions to apply transform
        kwargs.chdim (1,:) double = [] % dimensions to process cross spectra
        kwargs.winlen (1,:) double = 1024 % transform window lengths
        kwargs.overlap (1,:) double = 512 % transform window strides
        kwargs.offset (1,:) {mustBeA(kwargs.offset, {'double', 'cell '})} = 0 % sliding window offset at performing STFT
        kwargs.side (1,:) char {mustBeMember(kwargs.side, {'single', 'double'})} = 'single' % spectra process mode
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'amp', 'power', 'psd'})} = 'power' % spectra process mode
        kwargs.avg (1,1) logical = true % averaging by statistics of spectra
        kwargs.fs (1,:) double = [] % sampling frequency
        kwargs.center (1,1) logical = true % centre data at transform
        kwargs.winfun (1,:) char {mustBeMember(kwargs.winfun, {'uniform', 'hann', 'hanning', 'hamming'})} = 'hanning' % to weight data at transform
        kwargs.norm (1,1) logical = true % norm for spectral density
        kwargs.ans (1,:) char {mustBeMember(kwargs.ans, {'double', 'cell'})} = 'double' % output data format
        % parallel processing settings
        kwargs.usefiledatastore (1, 1) logical = false
        kwargs.useparallel (1,1) logical = false
        kwargs.extract {mustBeMember(kwargs.extract, {'readall', 'writeall'})} = 'writeall'
        kwargs.poolsize (1,:) double = 16
        kwargs.resources {mustBeA(kwargs.resources, {'char', 'string', 'cell'}), mustBeMember(kwargs.resources, {'Processes', 'Threads'})} = 'Processes'
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
    end
    [f{:}] = ndgrid(f{:});
    if isscalar(f); f = f{1}; end

    % create multidimensional window function
    switch kwargs.winfun
        case 'uniform'
            if isvector(kwargs.winlen)
                winfunc = @(x) ones(x, 1);
            else
                winfunc = @(x) ones(x);
            end
        case 'hann'
            winfunc = @hann;
        case 'hanning'
            winfunc = @hanning;
        case 'hamming'
            winfunc = @hamming;
    end
    win = winfunc(kwargs.winlen(1));
    if ~isvector(kwargs.winlen); for i = 2:numel(kwargs.winlen); win = win.*shiftdim(hann(kwargs.winlen(i)),-i+1); end; end
    
    kernel = zeros(1, nd); kernel(kwargs.ftdim) = kwargs.winlen;
    stride = ones(1, nd); stride(kwargs.ftdim) = kwargs.overlap;
    offset = zeros(1, nd); offset(kwargs.ftdim) = kwargs.offset;
    spec = nonlinfilt(@specker, data, kernel = kernel, stride = stride, offset = offset, padval = false, ...
        resources = kwargs.resources, usefiledatastore = kwargs.usefiledatastore, useparallel = kwargs.useparallel, ...
        extract = kwargs.extract, poolsize = kwargs.poolsize);

    if ismatrix(spec); nd = nd - 1; end

    arbind = 1:ndims(spec); arbind([kwargs.ftdim, nd+1:numel(kwargs.winlen)+nd]) = [];
    permind = [nd+1:numel(kwargs.winlen)+nd, kwargs.ftdim, arbind];

    % spec = permute(spec, permind); % permute dims
    if kwargs.norm;  spec = spec./kwargs.winlen; end % norm spectra

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
        case 'amp'
            for i = 1:numel(kwargs.winlen); cf(i) = kwargs.winlen(i)./mean(win, i); end
        otherwise
            for i = 1:numel(kwargs.winlen); cf(i) = 1./rms(win, i); end

            if isempty(kwargs.chdim)
                spec = spec.*conj(spec);
            else
                indg = cell(1, numel(kwargs.winlen) + nd - 1);
                szst = szs; szst(numel(kwargs.winlen)+kwargs.chdim) = [];
                for i = 1:numel(szst); indg{i} = 1:szst(i); end

                indi = cell(1, numel(kwargs.winlen) + nd);
                for i = 1:ndims(spec); indi{i} = 1:szs(i); end
                indj = indi;

                temp = zeros([szst, szd(kwargs.chdim), szd(kwargs.chdim)]);
                for i = 1:szd(kwargs.chdim)
                    indi{kwargs.chdim+numel(kwargs.winlen)} = i;
                    for j = 1:szd(kwargs.chdim)
                        indj{kwargs.chdim+numel(kwargs.winlen)} = j;
                        indt = cat(2, indg, i, j);
                        if j < i
                            temp2 = nan; 
                        else
                            temp2 = spec(indi{:}).*conj(spec(indj{:}));
                        end
                        temp(indt{:}) = temp2;
                    end
                end
                spec = temp; clear temp temp2;
            end
    end

    if kwargs.avg; spec = squeeze(mean(spec, (1:numel(kwargs.winlen)) + numel(kwargs.winlen))); end

    spec = spec.*cf.^2; % window function correction factor

    if kwargs.type == "psd"; spec = spec./df; end % norm to spectral density

    switch kwargs.ans
        case 'cell'
            szs = size(spec);
            indg = cell(1, numel(kwargs.winlen) + nd - 2);
            szst = szs; szst(end-1:end) = [];
            for i = 1:numel(szst); indg{i} = 1:szst(i); end

            temp = cell(szd(kwargs.chdim));
            for i = 1:szd(kwargs.chdim)
                for j = 1:szd(kwargs.chdim)
                    indt = cat(2, indg, i, j);
                    temp{i,j} = spec(indt{:});
                end
            end
            spec = temp; clear temp;
    end

    function y = specker(x, ~)
        x = squeeze(x);
        if kwargs.center; for k = 1:ndw; x = normalize(x,k,'center'); end; end % centre data
        x = x.*win; % weight data by window function
        y = fftn(x); % process mult. dim. FFT
    end

end