function teropf(condition,m,n)
    % condition ? m() : n();
    if condition
        m();
    else
        n();
    end
end