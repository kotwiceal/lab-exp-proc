function data = procxcorcta(data, kwargs)
    %% Cross-spectra analysis.

    arguments   
        data (1,1) struct
        kwargs.df (1,1) double = 50
        kwargs.fgrid (1,:) double = [100:25:900];
        kwargs.phi (1,:) double = 0:5:360
        kwargs.varcs (1,:) char {mustBeMember(kwargs.varcs, {'csdn', 'csd'})} = 'csdn'
    end

    data.csd = data.spec{1,3}; % cross-spectra density
    data.coh = abs(data.spec{1,3})./sqrt(data.spec{1,1}.*data.spec{3,3}); % coherence
    data.csdn = data.spec{1,3}./sqrt(data.spec{1,1}.*data.spec{3,3}); % normalized cross-spectra density

    switch kwargs.varcs
        case 'csd'
            temp = data.csd;
        case 'csdn'
            temp = data.csdn;
    end

    % phase rotation of cross-spectra: [x-axis, z-axis, frequency band, dis/ref, phase shift];
    data.fgrid = kwargs.fgrid;
    data.df = kwargs.df;
    data.rcsd = shiftdim(real(shiftdim(temp,-1).*exp(1j*deg2rad(kwargs.phi)')),1);
    sz = size(data.rcsd);
    data.rcsd = cellfun(@(f)data.intspec(data.rcsd,f), ...
        mat2cell([0, kwargs.df] + kwargs.fgrid', ones(1,numel(kwargs.fgrid)))', 'UniformOutput', false);
    data.rcsd = reshape(cell2mat(data.rcsd), [sz(2:3), numel(kwargs.fgrid), sz(4:end)]);
end