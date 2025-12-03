function y = teropf(condition,m,n)
    % condition ? m() : n();
    try
        if condition
            y = m();
        else
            y = n();
        end
    catch
        y = [];
    end
end