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
        kwargs.winlen double = 4096 % window function width
        kwargs.overlap double = 3072 % window function overlap
        kwargs.fs (1,1) double = 25e3 % frequency sampling
        % spectra norm
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'none', 'psd', 'psd-corrected'})} = 'psd-corrected'
        kwargs.corvibr (1,1) logical = true; % supress vibrations via cross-correlation correction
        kwargs.corvibrind (1,:) double = [1, 2]
        kwargs.reshape double = [] % reshape data
        kwargs.permute double = [] % permute data
        kwargs.procamp (1,:) char {mustBeMember(kwargs.procamp, {'rms', 'sum'})} = 'rms'
        % transform scan unit
        kwargs.unit (1,:) char {mustBeMember(kwargs.unit, {'mm', 'count'})} = 'mm'
        kwargs.xfit = [] % fitobj transfrom to leading edge coordinate system
        kwargs.yfit = [] % fitobj to reverse a correction of vectical scanning component
        kwargs.zfit = [] % fitobj transfrom to leading edge coordinate system
        kwargs.steps (1,:) double = [50, 800, 400] % single step displacement of step motor in um
    end

    % parse inputs
    if isa(input, 'double')
        raw = input;
    else
        raw = input.raw;
        kwargs.scan = input.scan;
        if isfield(input, 'fs'); kwargs.fs = input.fs; end
        if isfield(input, 'reshape'); kwargs.reshape = input.reshape; end
        if isfield(input, 'permute'); kwargs.permute = input.permute; end
        if isfield(input, 'corvibrind'); kwargs.corvibrind = input.corvibrind; end

        if isfield(input, 'xfit'); kwargs.xfit = input.xfit; end
        if isfield(input, 'yfit'); kwargs.yfit = input.yfit; end
        if isfield(input, 'zfit'); kwargs.zfit = input.zfit; end
    end

    % calculate auto/scross spectra
    [spec, f] = procspec(raw, wintype = kwargs.wintype, winlen = kwargs.winlen, ...
        overlap = kwargs.overlap, fs = kwargs.fs, norm = kwargs.norm);
    df = f(2)-f(1);

    % to substract correrlated signal part 
    if kwargs.corvibr
        spec{kwargs.corvibrind(1),kwargs.corvibrind(1)} = spec{kwargs.corvibrind(1),kwargs.corvibrind(1)} ...
            - abs(spec{kwargs.corvibrind(1),kwargs.corvibrind(2)}).^2./spec{kwargs.corvibrind(2),kwargs.corvibrind(2)};
    end

    % extract scanning points
    if ~isempty(kwargs.scan)
        x = squeeze(kwargs.scan(:,1,:));
        z = squeeze(kwargs.scan(:,2,:));
        y = squeeze(kwargs.scan(:,3,:));
        vm = kwargs.scan(:, 4);
    end

    % tranform y-axis to uncorrected vertical positions
    if ~isempty(kwargs.yfit) && ~isempty(kwargs.scan)
        y = y - round(kwargs.yfit(x, z)); 
    end

    if kwargs.raw; raw = squeeze(raw(:,1,:)); end

    % reshape spectra, scanning points and velocity
    if ~isempty(kwargs.reshape)
        for i = 1:size(spec, 1)
            for j = 1:size(spec, 2)
                spec{i,j} = reshape(spec{i,j}, [numel(f), kwargs.reshape]);
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
        for i = 1:size(spec, 1)
            for j = i:size(spec, 2)
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
                y = y/kwargs.steps(2);

                % transform to LE coordinate system
                if ~isempty(kwargs.xfit); xtemp = kwargs.xfit(x,z); else; xtemp = x/kwargs.steps(1); end
                if ~isempty(kwargs.zfit); ztemp = kwargs.zfit(x,z); else; ztemp = z/kwargs.steps(3); end
                x = xtemp;
                z = ztemp;
        end
    end


    % handler to select mask index by given frequency range
    freq2ind = @(x) f>=x(1)&f<=x(2);

    % parse outputs
    result.spec = spec;
    result.f = f;
    if ismatrix(spec{1,1})
        switch kwargs.procamp
            case 'rms'
                handler = @(spec, freq) sqrt(abs(df*sum(spec(freq2ind(freq), :))));
            case 'sum'
                handler = @(spec, freq) (df*sum(spec(freq2ind(freq), :)));
        end
    else
        switch kwargs.procamp
            case 'rms'
                handler = @(spec, freq) reshape(sqrt(abs(df*sum(spec(freq2ind(freq), :)))), size(spec, 2:ndims(spec)));
            case 'sum'
                handler = @(spec, freq) reshape(df*sum(spec(freq2ind(freq), :)), size(spec, 2:ndims(spec)));
        end
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