function [X, matind] = pivfindlocmax(data, kwargs)
    %% Find positions of local maxima of 2D matrix for PIV method. 

    arguments (Input)
        data (:,:)
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'morph', 'max'})} = 'morph'
        kwargs.msz (1,:) double = [];
        kwargs.ker (1,:) double = [0, 0];
    end

    arguments (Output)
        X (:,2)
        matind (:,:)
    end

    data = abs(data);

    switch kwargs.method
        case 'morph'
            if isempty(kwargs.msz); kwargs.msz = floor(size(data, [1, 2])/2); end
            mask = ones(kwargs.msz); szm = ceil(size(mask)/2); 
            mask(szm(1)-kwargs.ker(1):szm(1)+kwargs.ker(1),szm(2)-kwargs.ker(2):szm(2)+kwargs.ker(2)) = 0;
            matind = data > imdilate(data, mask);
            linind = find(matind);
        case 'max'
            [~, linind] = max(data, [], 'all');
            matind = [];
    end
    
    [xp, yp] = ind2sub(size(data), linind);
    X = [xp, yp];

end