function [spec, f] = procspec(data, kwargs)
    % Calculate auto/cross spectra of 1D signals.

    arguments
        data double % signal data, 1-dim: sample, 2-dim: channel, 3-..dims: realization
        % window function
        kwargs.wintype (1,:) char {mustBeMember(kwargs.wintype, {'uniform', 'hanning', 'hamming'})} = 'hanning'
        kwargs.winlen double = 4096 % window function width
        kwargs.overlap double = 3072 % window function overlap
        kwargs.fs (1,1) double = 25e3 % frequency sampling
        % spectra norm
        kwargs.norm (1,:) char {mustBeMember(kwargs.norm, {'none', 'psd', 'psd-corrected'})} = 'psd-corrected'
        kwargs.ans (1,:) char {mustBeMember(kwargs.ans, {'double', 'cell'})} = 'cell'
    end

    % build window function
    switch kwargs.wintype
        case 'uniform'
            win = ones(1, kwargs.winlen);
        case 'hanning'
            win = hann(kwargs.winlen);
        case 'hamming'
            win = hamming(kwargs.winlen);
    end

    sz = size(data); if ismatrix(data); sz(3) = 1; end
    ws = ceil(kwargs.winlen/2+1);
    ecf = 1/rms(win); % energy correction factor

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
            si{i} = spectrogram(data(:, i, k), win, kwargs.overlap , [], kwargs.fs);
        end

        % calc auto/cross term
        for i = 1:sz(2)
            for j = 1:sz(2)
                spec{i,j}(:,k) = squeeze(mean(si{i}.*conj(si{j}), 2));
            end
        end
    end

    clear si;

    % frequency grid
    [~, f, ~] = spectrogram(data(:, 1, 1), win, kwargs.overlap , [], kwargs.fs);
    df = f(2)-f(1);

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
        for j = 1:sz(2)
            spec{i,j} = spec{i,j}*nrm;
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