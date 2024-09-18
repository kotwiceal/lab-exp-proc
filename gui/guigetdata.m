function result = guigetdata(roi, data, kwargs)
    %% Select data by specified rectangle/polygonal mask.

    %% Examples:
    %% 1. Select region of image data by rectangle/polygonal ROI and outer values are assigned nan
    % [x, z] = meshgrid(0:100, 0:50);
    % data = sin(x+z); % roi.Position = [10, 10, 5, 5];
    % result = guigetdata(roi, data, shape = 'raw', x = x, z = z); % size(result) = [101, 51]
    %% 2. Extract region of image data by rectangle ROI
    % [x, z] = meshgrid(0:100, 0:50);
    % data = sin(x+z); % roi.Position = [10, 10, 5, 5];
    % result = guigetdata(roi, data, shape = 'cut', x = x, z = z); % size(result) = [5, 5]
    %% 3. Extract region of image data by rectangle/polygonal ROI and flat to vector
    % [x, z] = meshgrid(0:100, 0:50);
    % data = sin(x+z); % roi.Position = [10, 10, 5, 5]; roi is rectangle;
    % result = guigetdata(roi, data, shape = 'flatte', x = x, z = z); % size(result) = [5, 5]
    %% 4. Extract region of page-wise data by rectangle ROI
    % [x, z] = meshgrid(0:100, 0:50);
    % data = (0.1*rand([size(x), 10])+1).*sin(x+z); % roi.Position = [10, 10, 5, 5];
    % result = guigetdata(roi, data, shape = 'cut', x = x, z = z); % size(result) = [5, 5, 10]
    %% 5. Extract region of vector data by rectangle ROI
    % x = 0:100;
    % data = (0.1*rand(size(x))+1).*sin(x); % roi.Position = [10, 15, 5, 6];
    % result = guigetdata(roi, data, shape = 'cut', x = x); % size(result) = [1, 5]

    arguments
        roi % ROI object to select data
        data double % multidimensional data
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'raw', 'cut', 'flatten'})} = 'raw' % shape of output data
        kwargs.x double = [] % spatial coordinate
        kwargs.z double = [] % spatial coordinate
        kwargs.position double = []
        kwargs.size double = []
        kwargs.permute (1,2) double = [1, 2]
    end
    sz = size(data);

    if isvector(data)
        % vector data
        if isempty(kwargs.x)
            kwargs.x = 1:numel(data);
        end
        dx = [roi.Position(1), roi.Position(1)+roi.Position(3)];
        index = kwargs.x>dx(1)&kwargs.x<=dx(2);
        switch kwargs.shape
            case 'raw'
                data(~index) = nan;
                result = data;
            case 'cut'
                result = data(index);
            case 'flatten'
                result = data(index);
        end
    else
        % image data
        if isempty(kwargs.x) && isempty(kwargs.z)
            index = createMask(roi);
            kwargs.position = roi.Position;
        else
            pos = roi.Position;
            if roi.Type == "images.roi.polygon"
                mask = pos;
            else
                mask = [pos(1), pos(2); pos(1)+pos(3), pos(2); pos(1)+pos(3), pos(2)+pos(4); pos(1), pos(2)+pos(4)];
            end
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
                kwargs.position = round(kwargs.position);
                data = permute(data(:,:,:), [kwargs.permute, 3]);
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
end