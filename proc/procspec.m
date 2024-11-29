function [spec, f] = procspec(data, kwargs)
    % Calculate auto/cross spectra of 1D signals.

    arguments
        data double % signal data, 1-dim: sample, 2-dim: channel, 3-..dims: realization
        kwargs.spectrumtype (1,:) char {mustBeMember(kwargs.spectrumtype, {'power', 'psd'})} = 'psd'
        kwargs.freqrange (1,:) char {mustBeMember(kwargs.freqrange, {'onesided', 'twosided', 'centered'})} = 'onesided' % half, total and total centered spectra
        kwargs.winfun (1,:) char {mustBeMember(kwargs.winfun, {'uniform', 'hanning', 'hamming'})} = 'hanning' % window function
        kwargs.winlen double = 4096 % window function width
        kwargs.overlap double = 3072 % window function overlap
        kwargs.fs (1,1) double = 25e3 % frequency sampling
        kwargs.winfuncor (1,1) logical = true % spectra power correction at weighting data by window function
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'none', 'rms'})} = 'rms' % spectra norm
        kwargs.ans (1,:) char {mustBeMember(kwargs.ans, {'double', 'cell'})} = 'cell'
    end

    % build window function
    switch kwargs.winfun
        case 'uniform'
            win = ones(1, kwargs.winlen);
        case 'hanning'
            win = hann(kwargs.winlen);
        case 'hamming'
            win = hamming(kwargs.winlen);
    end

    sz = size(data); if ismatrix(data); sz(3) = 1; end
    if kwargs.winfuncor; ecf = 1/rms(win); else; ecf = 1; end % energy correction factor

    % frequency grid
    [~, f, ~] = spectrogram(data(:, 1, 1), win, kwargs.overlap, [], kwargs.fs, ...
        kwargs.freqrange, kwargs.spectrumtype);
    df = f(2)-f(1);
    ws = numel(f);

    % calculate auto/cross spectra
    % allocate
    spec = cell(sz(2), sz(2));
    for i = 1:numel(sz(2))
        for j = i:numel(sz(2))
            spec{i,j} = zeros(ws, prod(sz(3:end)));
        end
    end
    % calculate
    for k = 1:prod(sz(3:end)) % over exp point
        % proc fft
        si = cell(1, sz(2));
        for i = 1:sz(2)
            si{i} = spectrogram(data(:, i, k), win, kwargs.overlap, [], kwargs.fs, ...
                kwargs.freqrange, kwargs.spectrumtype);
        end

        % calc auto/cross term
        for i = 1:sz(2)
            for j = 1:sz(2)
                spec{i,j}(:,k) = squeeze(mean(si{i}.*conj(si{j}), 2));
            end
        end
    end

    clear si;

    % manual one-half amplitude spectral correction, `spectrogram` isn't work
    switch kwargs.freqrange
        case 'onesided'
            ampcor = 2;
            wsn = kwargs.winlen;
        otherwise
            ampcor = 1;
            wsn = ws;
    end

    switch kwargs.spectrumtype
        case 'power'
            df = 1;
    end

    % norm spectra
    switch kwargs.norm
        case 'rms'
            nrm = 1/wsn^2;
        otherwise
            nrm = 1;
    end
    for i = 1:sz(2)
        for j = 1:sz(2)
            spec{i,j} = spec{i,j}*nrm*ecf.^2/df;
            spec{i,j}(2:end,:) = spec{i,j}(2:end,:)*ampcor;
        end
    end

    % reshape spectra
    for i = 1:sz(2)
        for j = 1:sz(2)
            spec{i,j} = reshape(spec{i,j}, [size(spec{i,j}, 1), sz(3:end)]);
        end
    end

    switch kwargs.ans
        case 'double'
            temp = [];
            for i = 1:size(spec, 1)
                for j = 1:size(spec, 2)
                    temp(:,i,j) = spec{i,j}(:);
                end
            end
            spec = reshape(temp, [ws, prod(sz(3:end)), size(spec)]);
    end
    
end