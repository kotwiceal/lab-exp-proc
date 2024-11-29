function [xcor, t] = procspecxcor(sxy, kwargs)
    arguments
        sxy double
        kwargs.sxx double = []
        kwargs.syy double = []
        kwargs.fs (1,1) double = 1
        kwargs.type (1,:) char {mustBeMember(kwargs.type , {'none', 'norm'})} = 'none'
    end

    if isempty(kwargs.sxx) && isempty(kwargs.syy)
        xcor = fftshift(real(ifft(sxy,[],1)),1);
    else
        switch kwargs.type
            case 'norm'
                sxy = sxy./(sum(kwargs.sxx,1).*sum(kwargs.syy,1));
            otherwise
        end
        xcor = fftshift(real(ifft(sxy,[],1)),1);
    end

    n = size(xcor, 1);
    nh = floor(n/2);
    nh1 = nh + mod(n,2);
    dt = 1/kwargs.fs;
    t = dt * (-nh:nh1-1); 

end