function y = teropf(condition,m,n)
    % condition ? m() : n();
    if condition
        y = m();
    else
        y = n();
    end
end