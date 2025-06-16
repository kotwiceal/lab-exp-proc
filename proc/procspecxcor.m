function [xcor, t] = procspecxcor(sxy, kwargs)
    arguments
        sxy double
        kwargs.sxx double = []
        kwargs.syy double = []
        kwargs.fs (1,1) double = 1
        kwargs.type (1,:) char {mustBeMember(kwargs.type , {'norm', 'tf', 'csd'})} = 'csd'
        kwargs.omitfreq (1,:) double = []
    end

    if ~isempty(kwargs.omitfreq); sxy(kwargs.omitfreq,:) = 0; end
    switch kwargs.type
        case 'norm' % normalized cross-covariation function
            sz = size(kwargs.sxx);
            ind = fix(sz(1)/2);

            cxx = fftshift(real(ifft(kwargs.sxx,[],1)),1);
            cyy = fftshift(real(ifft(kwargs.syy,[],1)),1);

            cxx0 = reshape(cxx(ind,:), [1, sz(2:end)]);
            cyy0 = reshape(cyy(ind,:), [1, sz(2:end)]);

            sxy = sxy./sqrt(cxx0.*cyy0);
        case 'tf' % transfer function
            sxy = sxy./kwargs.syy;
    end

    xcor = fftshift(real(ifft(sxy,[],1)),1);

    n = size(xcor, 1);
    nh = floor(n/2);
    nh1 = nh + mod(n,2);
    dt = 1/kwargs.fs;
    t = dt * (-nh:nh1-1); 

end