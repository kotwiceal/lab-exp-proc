function result = guigetdata(roi, data, kwargs)
%% Select data by specified 2d mask.
%% The function takes following arguments:
%   roi:        [ROI object]        - ROI object to select data
%   data:       [n1×m1... double]   - multidimensional data
%   shape:      [char array]        - shape of output data
%   x:          [n1×m1 double]      - spatial coordinate
%   z:          [n1×m1 double]      - spatial coordinate
%% The function returns following results:
%   result: [n1×m1... double] or [k1×1 double] - selected data
        
        arguments
            roi 
            data double
            kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'raw', 'cut', 'flatten'})} = 'raw'
            kwargs.x double = []
            kwargs.z double = []
            kwargs.position double = []
            kwargs.size double = []
            kwargs.permute (1,2) double = [1, 2]
        end
        sz = size(data);

        if isempty(kwargs.x) && isempty(kwargs.z)
            index = createMask(roi);
            kwargs.position = roi.Position;
        else
            pos = roi.Position;
            mask = [pos(1), pos(2); pos(1)+pos(3), pos(2); pos(1)+pos(3), pos(2)+pos(4); pos(1), pos(2)+pos(4)];
            index = inpolygon(kwargs.x(:), kwargs.z(:), mask(:, 1), mask(:, 2));
            [r, c] = ind2sub(sz(1:2), find(index==1));
            kwargs.position = [min(r), min(c), max(r)-min(r), max(c)-min(c)];
            if ~isempty(kwargs.size)
                kwargs.position(3:end) = flip(kwargs.size);
            end
        end

        if ~ismatrix(data)
            index = repmat(index(:), prod(sz(3:end)), 1);
        end

        switch kwargs.shape
            case 'raw'
                data(~index) = nan;
                result = data;
            case 'cut'
                data = data(:,:,:);
                data = permute(data, [kwargs.permute, 3]);
                result = data(kwargs.position(1):kwargs.position(1)+kwargs.position(3), ...
                    kwargs.position(2):kwargs.position(2)+kwargs.position(4), :);

                if isempty(kwargs.x) && isempty(kwargs.z)
                    if kwargs.permute == [2, 1]
                        result = pagetranspose(result);
                    end
                end
                result = reshape(result, [size(result, 1:2), sz(3:end)]);
            case 'flatten'
                result = data(index);
        end

end