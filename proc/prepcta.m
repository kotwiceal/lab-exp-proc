function varargout = prepcta(input, kwargs)
%% Preparing CTA measurements: calculate spectra, perform cross-correlation correction, reshaping 
%% The function takes following arguments:
%   input:              [double, struct]
%   scan:               [n×10×m double]
%   winwidth:           [1×1 double]                - width of window function
%   overlap:            [1×1 double]                - overlap of windows
%   fs:                 [1×1 double]                - frequency sampling
%   corrvibr:           [1×1 logical]               - supress vibration term via cross-correlation correction
%   shape:              [1×q double]                - reshape data
%   output:             [char array]                - specify function return value
%% The function returns following results:
%   spec:               [k×m double] 
%   f:                  [k×1 double]
%   vel:                [m×1 double]
%   x:                  [m×1 double]
%   y:                  [m×1 double]
%   z:                  [m×1 double]
%% Examples:
%% load cta measurements, calculate auto-spectra (struct notation)
% data = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931', output = 'struct');
% dataprep = prepcta(p1, output = 'struct');

%% load cta measurements, calculate auto-spectra (array notation)
% [scan, data, raw] = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931');
% [spec, f, vel, x, y, z] = prepcta(raw, scan = scan);

    arguments
        input {mustBeA(input, {'double', 'struct'})}
        kwargs.scan double = []
        kwargs.winwidth double = 4096
        kwargs.overlap double = 3072
        kwargs.fs double = 2e4
        kwargs.corrvibr logical = false;
        kwargs.shape double = []
        kwargs.output (1,:) char {mustBeMember(kwargs.output, {'struct', 'array'})} = 'struct'
    end

    if isa(input, 'double')
        raw = input;
    else
        raw = input.raw;
        kwargs.scan = input.scan;
    end

    s0 = []; s1 = []; s2 = [];

    % calculate spectrogram
    for i = 1:size(raw, 3)
        s0(:,:,i) = spectrogram(raw(:, 1, i), kwargs.winwidth, kwargs.overlap , [], kwargs.fs);
        s1(:,:,i) = spectrogram(raw(:, 1, i), kwargs.winwidth, kwargs.overlap , [], kwargs.fs);
        s2(:,:,i) = spectrogram(raw(:, 1, i), kwargs.winwidth, kwargs.overlap , [], kwargs.fs);
    end

    [~, f, ~] = spectrogram(raw(:, 1, 1), kwargs.winwidth, kwargs.overlap , [], kwargs.fs);

    % calculate auto/cross spetra
    s00 = squeeze(mean(s0.*conj(s0), 2));
    s01 = squeeze(mean(s0.*conj(s1), 2));
    s02 = squeeze(mean(s0.*conj(s2), 2));

    s11 = squeeze(mean(s1.*conj(s1), 2));
    s22 = squeeze(mean(s2.*conj(s2), 2));

    % to substract correrlated part signal 
    if kwargs.corrvibr
        s00 = s00 - abs(s01).^2./s11;
    end

    if ~isempty(kwargs.scan)
        x = squeeze(kwargs.scan(:,1,:));
        z = squeeze(kwargs.scan(:,2,:));
        y = squeeze(kwargs.scan(:,3,:));
        vel = kwargs.scan(:, 4);
    end

    if ~isempty(kwargs.shape)
        s00 = reshape(s00, [size(s00, 1), kwargs.shape]);
        if ~isempty(kwargs.scan)
            x = reshape(x, kwargs.shape);
            z = reshape(z, kwargs.shape);
            y = reshape(y, kwargs.shape);
            vel = reshape(vel, kwargs.shape);
        end
    end

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