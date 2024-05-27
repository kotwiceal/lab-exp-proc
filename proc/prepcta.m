function varargout = prepcta(input, kwargs)
    %% Preparing CTA measurements: calculate spectra, perform cross-correlation correction.

    %% Examples:
    %% 1. Load cta measurements, calculate auto-spectra (struct notation):
    % data = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931');
    % dataprep = prepcta(p1, output = 'struct');

    %% 2. Load cta measurements, calculate auto-spectra (array notation):
    % [scan, data, raw] = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931', output = 'array');
    % [spec, f, vel, x, y, z] = prepcta(raw, scan = scan);

    arguments
        input {mustBeA(input, {'double', 'struct'})}
        kwargs.scan (:,:) double = [] % scan table
        kwargs.raw (1,1) logical = false
        % window function
        kwargs.wintype (1,:) char {mustBeMember(kwargs.wintype, {'uniform', 'hanning', 'hamming'})} = 'hanning'
        kwargs.winsize double = 4096 % window function width
        kwargs.overlap double = 3072 % window function overlap
        kwargs.fs (1,1) double = 25e3 % frequency sampling
        % spectra norm
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'none', 'psd', 'psd-corrected'})} = 'psd-corrected'
        kwargs.corvibr (1,1) logical = true; % supress vibrations via cross-correlation correction
        kwargs.reshape double = [] % reshape data
        kwargs.permute double = [] % permute data
        % transform scan unit
        kwargs.unit (1,:) char {mustBeMember(kwargs.unit, {'mm', 'count'})} = 'mm'
        kwargs.fit = [] % fitobj to reverse a correction of vectical scanning component
        kwargs.steps (1,:) double = [50, 400, 800] % single step displacement of step motor in um
        kwargs.parproc (1,1) logical = false % perfor parallel processing
    end

    % choose input type
    if isa(input, 'double')
        raw = input;
    else
        raw = input.raw;
        kwargs.scan = input.scan;
        if isfield(input, 'fs'); kwargs.fs = input.fs; end
        if isfield(input, 'reshape'); kwargs.reshape = input.reshape; end
        if isfield(input, 'permute'); kwargs.permute = input.permute; end
        if isfield(input, 'fit'); kwargs.fit = input.fit; end
        if isfield(input, 'ft'); kwargs.fit = input.ft; end
    end

    s0 = []; s1 = [];

    % build window function
    switch kwargs.wintype
        case 'uniform'
            win = ones(1, kwargs.winsize);
        case 'hanning'
            win = hann(kwargs.winsize);
        case 'hamming'
            win = hamming(kwargs.winsize);
    end

    % calculate spectra correction factors
    acf = 1/mean(win); % amplitude correction factor
    ecf = 1/rms(win); % energy correction factor

    sz = size(raw); ws = ceil(kwargs.winsize/2+1);

    % calculate auto/cross spectra
    spec = cell(sz(2), sz(2));
    for i = 1:numel(sz(2))
        for j = i:numel(sz(2))
            spec{i,j} = zeros(ws, prod(sz(3:end)));
        end
    end
    for k = 1:prod(sz(3:end))
        si = cell(1, sz(2));
        for i = 1:sz(2)
            si{i} = spectrogram(raw(:, i, k), win, kwargs.overlap , [], kwargs.fs);
        end

        for i = 1:sz(2)
            for j = i:sz(2)
                spec{i,j}(:,k) = squeeze(mean(si{i}.*conj(si{j}), 2));
            end
        end
    end

    clear si;

    % frequency grid
    [~, f, ~] = spectrogram(raw(:, 1, 1), win, kwargs.overlap , [], kwargs.fs);
    df = f(2)-f(1);

    % to substract correrlated signal part 
    if kwargs.corvibr
        spec{1,1} = spec{1,1} - abs(spec{1,2}).^2./spec{2,2};
    end

    % norm spectra
    switch kwargs.norm
        case 'psd'
            nrm = 1/ws^2/df*2;
        case 'psd-corrected'
            nrm = 1/ws^2/df*2*ecf;
        otherwise
            nrm = 1;
    end
    for i = 1:sz(2)
        for j = i:sz(2)
            spec{i,j} = spec{i,j}*nrm;
        end
    end

    % extract scanning points
    if ~isempty(kwargs.scan)
        x = squeeze(kwargs.scan(:,1,:));
        z = squeeze(kwargs.scan(:,2,:));
        y = squeeze(kwargs.scan(:,3,:));
        vm = kwargs.scan(:, 4);
    end

    % return to uncorrected vertical positions
    if ~isempty(kwargs.fit) && ~isempty(kwargs.scan)
        y = y - round(kwargs.fit(x, z)); 
    end

    if kwargs.raw; raw = squeeze(raw(:,1,:)); end

    % reshape spectra, scanning points and velocity
    if ~isempty(kwargs.reshape)
        for i = 1:sz(2)
            for j = i:sz(2)
                spec{i,j} = reshape(spec{i,j}, [ws, kwargs.reshape]);
            end
        end
        if ~isempty(kwargs.scan)
            x = reshape(x, kwargs.reshape);
            z = reshape(z, kwargs.reshape);
            y = reshape(y, kwargs.reshape);
            vm = reshape(vm, kwargs.reshape);
        end
        if kwargs.raw; raw = reshape(raw, [size(raw, 1), kwargs.reshape]); end
        if isempty(kwargs.permute); raw = permute(raw, [2:ndims(raw), 1]); end
    end

    if ~isempty(kwargs.permute)
        for i = 1:sz(2)
            for j = i:sz(2)
                spec{i,j} = permute(spec{i,j}, [1, kwargs.permute+1]);
            end
        end
        if ~isempty(kwargs.scan)
            vm = permute(vm, kwargs.permute);
            x = permute(x, kwargs.permute);
            y = permute(y, kwargs.permute);
            z = permute(z, kwargs.permute);
        end
        if kwargs.raw; raw = permute(raw, [1, kwargs.permute + 1]); end
    end

    % transform units
    if ~isempty(kwargs.scan)
        switch kwargs.unit
            case 'mm'
                x = x/kwargs.steps(1);
                y = y/kwargs.steps(2);
                z = z/kwargs.steps(3);
        end
    end

    % handle a frequency to index
    freq2ind = @(ind) f>=ind(1)&f<=ind(2);

    % output
    result.spec = spec;
    result.f = f;
    if ismatrix(spec{1,1})
        handler = @(spec, freq) sqrt(abs(df*sum(spec(freq2ind(freq), :))));
    else
        handler = @(spec, freq) reshape(sqrt(abs(df*sum(spec(freq2ind(freq), :)))), size(spec, 2:ndims(spec)));
    end
    result.intspec = handler;
    if ~isempty(kwargs.scan)
        result.vm = vm;
        result.x = x;
        result.y = y;
        result.z = z;
    end
    if kwargs.raw; result.raw = raw; end
    varargout{1} = result;

end