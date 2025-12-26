function y = parseregion(x)
    arguments (Input)
        x (:,1) double
    end
    difbin = [0; diff(x(:), 1, 1)];
    lb = find(difbin>0);
    rb = find(difbin<0);
    if isempty(lb); lb = 1; end
    if isempty(rb); rb = numel(difbin); end
    if isscalar(lb) && isscalar(rb)
        unq = unique(x);
        if isscalar(unq)
            if x(1) > 0
                lb = 1;
                rb = numel(difbin);
            else
                lb = 1;
                rb = 1;
            end
        end
    else
        if lb(1) > rb(1)
            lb = [1; lb];
        end
        if lb(end) > rb(end)
            rb = [rb; numel(difbin)];
        end
    end
    y = [lb, rb];
end