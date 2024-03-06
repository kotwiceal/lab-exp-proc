function varargout = prepcta(input, kwargs)
%% Preparing CTA measurements: calculate spectra, perform cross-correlation correction, reshaping 
%% The function takes following arguments:
%   input:              [double, struct]
%   scan:               [n×10×m double]
%   wintype:            [char array]                - type of window function
%   winsize:            [1×1 double]                - width of window function
%   overlap:            [1×1 double]                - overlap of windows
%   fs:                 [1×1 double]                - frequency sampling
%   norm:               [char array]                - to norm spectra
%   corvibr:            [1×1 logical]               - supress vibration term via cross-correlation correction
%   reshape:            [1×q double]                - reshape data
%   permute:            [1×q double]                - permute data
%   unit:               [char array]                - transform scan unit  
%   fit:                [function_handle]           - reverse a correction of vectical scanning component
%   output:             [char array]                - specify function return value
%   steps:              [1×3 double]                - step motors linear shift vector
%% The function returns following results:
%   spec:               [k×m double] 
%   f:                  [k×1 double]
%   vel:                [m×1 double]
%   x:                  [m×1 double]
%   y:                  [m×1 double]
%   z:                  [m×1 double]
%% Examples:
%% 1. Load cta measurements, calculate auto-spectra (struct notation):
% data = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931');
% dataprep = prepcta(p1, output = 'struct');

%% 2. Load cta measurements, calculate auto-spectra (array notation):
% [scan, data, raw] = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931', output = 'array');
% [spec, f, vel, x, y, z] = prepcta(raw, scan = scan);

    arguments
        input {mustBeA(input, {'double', 'struct'})}
        kwargs.scan double = []
        kwargs.wintype (1,:) char {mustBeMember(kwargs.wintype, {'uniform', 'hanning', 'hamming'})} = 'hanning'
        kwargs.winsize double = 4096
        kwargs.overlap double = 3072
        kwargs.fs double = 25e3
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'none', 'psd', 'psd-corrected'})} = 'psd-corrected'
        kwargs.corvibr logical = true;
        kwargs.reshape double = []
        kwargs.permute double = []
        kwargs.unit (1,:) char {mustBeMember(kwargs.unit, {'mm', 'count'})} = 'mm'
        kwargs.fit = []
        kwargs.output (1,:) char {mustBeMember(kwargs.output, {'struct', 'array'})} = 'struct'
        kwargs.steps (1,:) double = [50, 400, 800]
    end

    % choose input type
    if isa(input, 'double')
        raw = input;
    else
        raw = input.raw;
        kwargs.scan = input.scan;
    end

    s0 = []; s1 = []; s2 = [];

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

    % calculate spectrogram
    for i = 1:size(raw, 3)
        s0(:,:,i) = spectrogram(raw(:, 1, i), win, kwargs.overlap , [], kwargs.fs);
        s1(:,:,i) = spectrogram(raw(:, 2, i), win, kwargs.overlap , [], kwargs.fs);
    end

    [~, f, ~] = spectrogram(raw(:, 1, 1), win, kwargs.overlap , [], kwargs.fs);
    df = f(2)-f(1);

    % calculate auto/cross spetra
    s00 = squeeze(mean(s0.*conj(s0), 2));
    s01 = squeeze(mean(s0.*conj(s1), 2));

    s11 = squeeze(mean(s1.*conj(s1), 2));

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
        vel = kwargs.scan(:, 4);
    end

    % return to uncorrected vertical positions
    if ~isempty(kwargs.fit) && ~isempty(kwargs.scan)
        y = y - round(kwargs.fit(x, z)); 
    end

    % reshape spectra, scanning points and velocity
    if ~isempty(kwargs.reshape)
        s00 = reshape(s00, [size(s00, 1), kwargs.reshape]);
        if ~isempty(kwargs.scan)
            x = reshape(x, kwargs.reshape);
            z = reshape(z, kwargs.reshape);
            y = reshape(y, kwargs.reshape);
            vel = reshape(vel, kwargs.reshape);
        end
    end

    if ~isempty(kwargs.permute)
        s00 = permute(s00, [1. kwargs.permute+1]);
        if ~isempty(kwargs.scan)
            vel = permute(vel, kwargs.permute);
            x = permute(x, kwargs.permute);
            y = permute(y, kwargs.permute);
            z = permute(z, kwargs.permute);
        end
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
                result.vel = vel;
                result.x = x;
                result.y = y;
                result.z = z;
            end
            varargout{1} = result;
        case 'array'
            varargout{1} = s00;
            varargout{2} = f;
            if ~isempty(kwargs.scan)
                varargout{3} = vel;
                varargout{4} = x;
                varargout{5} = y;
                varargout{6} = z;
            end
    end
end