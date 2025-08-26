function [U, S, V] = procpod(x, s, ind)
    arguments
        x (:, :) double % 2 dim data array, 1st dim responds for spatial, 2nd for pseudo-time dim 
        s               % x-arr size b4 merging dimensions
        ind             % binar matrix, that is cutting area of interest
    end

    [i,j,v] = find(x);
    v = reshape(v, [], s(3));
    [Ut,St,Vt] = svd(v);
    
    V = Vt;
    S = St;

    U = zeros([s(1:2), numel(find(ind))]);
    U(repmat(ind, 1, 1, numel(find(ind)))) = Ut;
end