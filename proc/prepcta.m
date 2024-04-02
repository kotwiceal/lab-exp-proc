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
        kwargs.output (1,:) char {mustBeMember(kwargs.output, {'struct', 'array'})} = 'struct'
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
        if isfield(input, 'permute'); kwargs.fs = input.permute; end
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
    acf = 1/mean(win); % amplitude correction factor;
    ecf = 1/rms(win); % energy correction factor;

    sz = size(raw);

    % calculate spectrogram
    if kwargs.parproc
        s0 = spectrogram(raw(:, 2, 1), win, kwargs.overlap , [], kwargs.fs);
        s1 = spectrogram(raw(:, 2, 1), win, kwargs.overlap , [], kwargs.fs);

        s00 = zeros(size(s0, 1), prod(sz(3:end)));
        s11 = zeros(size(s0, 1), prod(sz(3:end)));
        s01 = zeros(size(s0, 1), prod(sz(3:end)));

        s00(:, 1) = squeeze(mean(s0.*conj(s0), 2));
        s11(:, 1) = squeeze(mean(s1.*conj(s1), 2));
        s01(:, 1) = squeeze(mean(s0.*conj(s1), 2)); 

        parfor i = 2:size(raw, 3)
            s0 = spectrogram(raw(:, 1, i), win, kwargs.overlap , [], kwargs.fs);
            s1 = spectrogram(raw(:, 2, i), win, kwargs.overlap , [], kwargs.fs);
            % calculate auto/cross spetra
            s00(:, i) = squeeze(mean(s0.*conj(s0), 2));
            s11(:, i) = squeeze(mean(s1.*conj(s1), 2));
            s01(:, i) = squeeze(mean(s0.*conj(s1), 2)); 
        end
    else
        s0 = spectrogram(raw(:, 2, 1), win, kwargs.overlap , [], kwargs.fs);
        s1 = spectrogram(raw(:, 2, 1), win, kwargs.overlap , [], kwargs.fs);

        s00 = zeros(size(s0, 1), prod(sz(3:end)));
        s11 = zeros(size(s0, 1), prod(sz(3:end)));
        s01 = zeros(size(s0, 1), prod(sz(3:end)));

        s00(:, 1) = squeeze(mean(s0.*conj(s0), 2));
        s11(:, 1) = squeeze(mean(s1.*conj(s1), 2));
        s01(:, 1) = squeeze(mean(s0.*conj(s1), 2)); 

        for i = 2:size(raw, 3)
            s0 = spectrogram(raw(:, 1, i), win, kwargs.overlap , [], kwargs.fs);
            s1 = spectrogram(raw(:, 2, i), win, kwargs.overlap , [], kwargs.fs);
            % calculate auto/cross spetra
            s00(:, i) = squeeze(mean(s0.*conj(s0), 2));
            s11(:, i) = squeeze(mean(s1.*conj(s1), 2));
            s01(:, i) = squeeze(mean(s0.*conj(s1), 2)); 
        end
    end

    clear s0 s1;

    % frequency grid
    [~, f, ~] = spectrogram(raw(:, 1, 1), win, kwargs.overlap , [], kwargs.fs);
    df = f(2)-f(1);

    % to substract correrlated signal part 
    if kwargs.corvibr
        s00 = s00 - abs(s01).^2./s11;
    end

    % norm spectra
    switch kwargs.norm
        case 'psd'
            s00 = s00/size(s00,1)^2/df*2;
        case 'psd-corrected'
            s00 = s00/size(s00,1)^2/df*2*ecf;
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
        s00 = reshape(s00, [size(s00, 1), kwargs.reshape]);
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
        s00 = permute(s00, [1, kwargs.permute+1]);
        if ~isempty(kwargs.scan)
            vm = permute(vm, kwargs.permute);
            x = permute(x, kwargs.permute);
            y = permute(y, kwargs.permute);
            z = permute(z, kwargs.permute);
        end
        if kwargs.raw; raw = permute(raw, [1, kwargs.permute]); end
    end

    % transform units
    switch kwargs.unit
        case 'mm'
            x = x/kwargs.steps(1);
            y = y/kwargs.steps(2);
            z = z/kwargs.steps(3);
    end

    % select output type
    switch kwargs.output
        case 'struct'
            result.spec = s00;
            result.f = f;
            if ~isempty(kwargs.scan)
                result.vm = vm;
                result.x = x;
                result.y = y;
                result.z = z;
            end
            if kwargs.raw; result.raw = raw; end
            varargout{1} = result;
        case 'array'
            varargout{1} = s00;
            varargout{2} = f;
            if ~isempty(kwargs.scan)
                varargout{3} = vm;
                varargout{4} = x;
                varargout{5} = y;
                varargout{6} = z;
            end
            if kwargs.raw; varargout{7} = raw; end
    end
end