function result = guigetdata(roi, data, named)
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
            named.shape (1,:) char {mustBeMember(named.shape, {'raw', 'cut', 'flatten'})} = 'raw'
            named.type (1,:) char {mustBeMember(named.type, {'node', 'spatial'})} = 'node'
            named.x double = []
            named.z double = []
            named.position double = []
        end
        sz = size(data);

        switch named.type
            case 'node'
                index = createMask(roi);
                named.position = roi.Position;
            case 'spatial'
                pos = roi.Position;
                mask = [pos(1), pos(2); pos(1)+pos(3), pos(2); pos(1)+pos(3), pos(2)+pos(4); pos(1), pos(2)+pos(4)];
                index = inpolygon(named.x(:), named.z(:), mask(:, 1), mask(:, 2));
                % [r, c] = ind2sub(sz, index);
                [r, c] = ind2sub(sz, find(index==1));
                named.position = [min(r), min(c), max(r)-min(r), max(c)-min(c)];
        end

        if ~ismatrix(data)
            index = repmat(index(:), prod(sz(3:end)), 1);
        end

        switch named.shape
            case 'raw'
                data(~index) = nan;
                result = data;
            case 'cut'
                named.position = floor(named.position);
                result = data(named.position(2):named.position(2)+named.position(4), ...
                    named.position(1):named.position(1)+named.position(3), :);
                result = reshape(result, [size(result, 1:2), sz(3:end)]);
            case 'flatten'
                result = data(index);
        end

end