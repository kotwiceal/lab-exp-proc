function [modes, expansion, energy, f] = spod(data, kwargs)
    %% Spectral proper orthogonal decomposition.
    
    arguments
        data double
        kwargs.win (1,:) double = []
        % window function
        kwargs.wintype (1,:) char {mustBeMember(kwargs.wintype, {'uniform', 'hanning', 'hamming'})} = 'hanning'
        kwargs.winlen double = 4096 % window function width
        kwargs.overlap double = 3072 % window function overlap
        kwargs.fs (1,1) double = 25e3 % frequency sampling
    end

    % build window function
    if isempty(kwargs.win)
        switch kwargs.wintype
            case 'uniform'
                kwargs.win = ones(1, kwargs.winlen);
            case 'hanning'
                kwargs.win = hann(kwargs.winlen);
            case 'hamming'
                kwargs.win = hamming(kwargs.winlen);
        end
    end

    szd = size(data);

    si = [];
    % calculate fft
    for i = 1:prod(szd(2:end)) % over exp point
        [si(:,:,i), f] = spectrogram(data(:, i), kwargs.win, kwargs.overlap, [], kwargs.fs);
    end
    si = permute(si, [3, 2, 1]); % [point, block, sample];
    szs = size(si);

    % cross-spectra density
    csd = pagemtimes(pagectranspose(si), si);
    
    % eigenvalue decomposition
    [phi, lambda] = pageeig(csd);

    modes = pagemrdivide(pagemtimes(si, phi), sqrt(lambda));
    expansion = pagemtimes(sqrt(lambda), phi);
    energy = abs(lambda);

    % reconstruct dimensions
    modes = permute(reshape(modes, [szd(2:end), szs(2:end)]), [numel(szd(2:end))+2, 1:numel(szd(2:end)), numel(szd(2:end))+1]);
    expansion = permute(expansion, [3, 1, 2]);

    temporary = zeros(flip(size(energy, 2:3)));
    for i = 1:size(energy, 3)
        temporary(i, :) = diag(energy(:,:,i));
    end
    energy = temporary;
end