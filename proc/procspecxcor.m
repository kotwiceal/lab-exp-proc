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
        case 'norm'
            sxy = sxy./(sum(kwargs.sxx,1).*sum(kwargs.syy,1));
        case 'tf'
            sxy = sxy./sqrt(kwargs.syy);
    end
    xcor = fftshift(real(ifft(sxy,[],1)),1);

    n = size(xcor, 1);
    nh = floor(n/2);
    nh1 = nh + mod(n,2);
    dt = 1/kwargs.fs;
    t = dt * (-nh:nh1-1); 

end