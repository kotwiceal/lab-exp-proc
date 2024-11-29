function data = procxcorcta(data, kwargs)
    %% Cross-spectra analysis.

    arguments   
        data (1,1) struct
        kwargs.df (1,1) double = 50
        kwargs.fgrid (1,:) double = [100:25:900];
        kwargs.phi (1,:) double = 0:5:360
        kwargs.varcs (1,:) char {mustBeMember(kwargs.varcs, {'coh', 'csdn', 'csd', 'tf', 'csdn1'})} = 'csdn'
        kwargs.intspec (1,:) char {mustBeMember(kwargs.intspec, {'sum', 'mean', 'struct'})} = 'struct'
        kwargs.freqsel (1,:) char {mustBeMember(kwargs.freqsel, {'range', 'mean'})} = 'range'
    end

    data.csd = data.spec{1,3}; % cross-spectra density
    data.coh = abs(data.spec{1,3})./sqrt(data.spec{1,1}.*data.spec{3,3}); % coherence
    data.tf = data.spec{1,3}./sqrt(data.spec{3,3}); % transfer function
    data.csdn = data.spec{1,3}./sqrt(data.spec{1,1}.*data.spec{3,3}); % normalized cross-spectra density

    switch kwargs.varcs
        case 'coh'
            temp = data.coh;
        case 'csd'
            temp = data.csd;
        case 'csdn'
            temp = data.csdn;
        case 'tf'
            temp = data.tf;
    end

    switch kwargs.freqsel
        case 'range'
            freq2ind = @(f,x) find(f>=x(1)&f<=x(2));
        case 'mean'
            freq2ind = @(f,x) round(mean(find(f>=x(1)&f<=x(2))));
    end
    df = data.f(2) - data.f(1);

    switch kwargs.intspec
        case 'sum'
            kwargs.intspec = @(spec, freq) reshape(df*sum(spec(freq2ind(data.f,freq), :)), size(spec, 2:ndims(spec)));
        case 'mean'
            df = sqrt(df);
            kwargs.intspec = @(spec, freq) reshape(df*mean(spec(freq2ind(data.f,freq), :),1), size(spec, 2:ndims(spec)));  
        case 'struct'
            kwargs.intspec = @data.intspec;
    end

    % phase rotation of cross-spectra: [x-axis, z-axis, frequency band, dis/ref, phase shift];
    data.fgrid = kwargs.fgrid;
    data.df = kwargs.df;
    data.rcsd = shiftdim(real(shiftdim(temp,-1).*exp(1j*deg2rad(kwargs.phi)')),1);
    sz = size(data.rcsd);
    data.rcsd = cellfun(@(f)kwargs.intspec(data.rcsd,f), ...
        mat2cell([0, kwargs.df] + kwargs.fgrid', ones(1,numel(kwargs.fgrid)))', 'UniformOutput', false);
    data.rcsd = reshape(cell2mat(data.rcsd), [sz(2:3), numel(kwargs.fgrid), sz(4:end)]);
end