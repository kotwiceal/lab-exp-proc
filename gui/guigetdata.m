function result = guigetdata(roi, data, kwargs)
%% Select data by specified 2d mask.
%% The function takes following arguments:
%   roi:        [ROI object]        - ROI object to select data
%   data:       [n1×m1... double]   - multidimensional data
%   shape:      [char array]        - shape of output data
%   type:       [char array]        - indicate type of ROI mask
%   x:          [n1×m1 double]      - spatial coordinate
%   z:          [n1×m1 double]      - spatial coordinate
%
%% The function returns following results:
%   result: [n1×m1... double] or [k1×1 double] - selected data
        
        arguments
            roi 
            data double
            kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'raw', 'cut', 'flatten'})} = 'raw'
            kwargs.type (1,:) char {mustBeMember(kwargs.type, {'node', 'spatial'})} = 'node'
            kwargs.x double = []
            kwargs.z double = []
            kwargs.position double = []
        end
        sz = size(data);

        switch kwargs.type
            case 'node'
                index = createMask(roi);
                kwargs.position = roi.Position;
            case 'spatial'
                pos = roi.Position;
                mask = [pos(1), pos(2); pos(1)+pos(3), pos(2); pos(1)+pos(3), pos(2)+pos(4); pos(1), pos(2)+pos(4)];
                index = inpolygon(kwargs.x(:), kwargs.z(:), mask(:, 1), mask(:, 2));
                % [r, c] = ind2sub(sz, index);
                [r, c] = ind2sub(sz, find(index==1));
                kwargs.position = [min(r), min(c), max(r)-min(r), max(c)-min(c)];
        end

        if ~ismatrix(data)
            index = repmat(index(:), prod(sz(3:end)), 1);
        end

        switch kwargs.shape
            case 'raw'
                data(~index) = nan;
                result = data;
            case 'cut'
                kwargs.position = floor(kwargs.position);
                result = data(kwargs.position(2):kwargs.position(2)+kwargs.position(4), ...
                    kwargs.position(1):kwargs.position(1)+kwargs.position(3), :);
                result = reshape(result, [size(result, 1:2), sz(3:end)]);
            case 'flatten'
                result = data(index);
        end

end