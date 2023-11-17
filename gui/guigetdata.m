function result = guigetdata(roi, data, named)
%% Select data by 2d mask.
%% The function takes following arguments:
%   roi:        [ROI object]        - ROI object to select data
%   data:       [n1×m1... double]   - multidimensional data
%   shape:      [k×1 double]        - shape of output data
%
%% The function returns following results:
%   result: [n1×m1... double] - selected data
    
        arguments
            roi 
            data double
            named.shape char = 'raw'
        end

        sz = size(data);
        index = createMask(roi);
        if ~ismatrix(data)
            index = repmat(index(:), prod(sz(3:end)), 1);
        end

        switch named.shape
            case 'raw'
                data(~index) = nan;
                result = data;
            case 'flatten'
                result = data(index);
        end

end