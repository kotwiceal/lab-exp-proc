function value = histintersect(edges, modes)
    %% Calculate intersection of two statistics.
    %% The function takes following arguments:
    % edges: [n×1 double]
    % modes: [n×2 double]
    %% The function returns following results:
    % value: [double]

        [~, ind_1] = max(modes(:, 1)); 
        [~, ind_2] = max(modes(:, 2));
        ind_range = ind_1:ind_2;
        [~, ind_crit] = min(abs(modes(ind_range, 1) - modes(ind_range, 2)));
        value = mean([edges(ind_range(ind_crit)), edges(ind_range(ind_crit))]);
    end