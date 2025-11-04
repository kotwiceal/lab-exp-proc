function y = terop(condition,m,n)
    % y = condition ? m : n;
    if condition
        y = m;
    else
        y = n;
    end
end