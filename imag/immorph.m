function result = immorph(data, kwargs)
    %% Batch morphological image processing.

    arguments
        data double % multidimensional data
        % morphological method
        kwargs.method (1,:) char {mustBeMember(kwargs.method , {'none', 'fill', 'erode', 'dilate', 'close', 'open', 'remclosedom', 'fillbound'})} = 'erode'
        kwargs.strel (1,:) char {mustBeMember(kwargs.strel, {'disk', 'line'})} = 'disk' % structure element
        kwargs.strelker (1,:) double = 4 % kernel of structure element
        kwargs.threshold (1,1) double = 1e3
        kwargs.parproc (1,1) logical = false % perform parallel processing
    end

    arg = cat(2, {kwargs.strel}, num2cell(kwargs.strelker));
    strl = strel(arg{:});

    switch kwargs.method 
        case 'fill'
            method = @(img) imfill(img, 'holes');
        case 'erode'
            method = @(img) imerode(img, strl);
        case 'dilate'
            method = @(img) imdilate(img, strl);
        case 'close'
            method = @(img) imclose(img, strl);
        case 'open'
            method = @(img) imopen(img, strl);
        case 'remclosedom'
            method = @(img) remclosedom(img, kwargs.threshold);
        case 'fillbound'
            method = @(img) fillbound(img);
    end

    sz = size(data); if ismatrix(data); sz(3) = 1; end
    result = data; result(isnan(result)) = 0;

    if kwargs.parproc
        parfor i = 1:prod(sz(3:end))
            result(:, :, i) = method(result(:, :, i));
        end
    else
        for i = 1:prod(sz(3:end))
            result(:, :, i) = method(result(:, :, i));
        end
    end

    result = reshape(result, sz);

    function img = remclosedom(img, trh)
        bnd = bwboundaries(img);
        szi = size(img);
        img = false(szi);
        for j = 1:numel(bnd)
            temp = poly2mask(bnd{j}(:,2), bnd{j}(:,1), szi(1), szi(2));
            if bwarea(temp) > trh; img = img | temp; end
        end
    end

    function img = fillbound(img)

        % fill boundary holes: west
        img = padarray(img, [0, 1], 1, 'pre');
        img = imfill(img, 'holes');
        img = img(:,2:end,:);

        % fill boundary holes: east
        img = padarray(img, [0, 1], 1, 'post');
        img = imfill(img, 'holes');
        img = img(:,1:end-1,:);
        
        % fill boundary holes: north
        img = padarray(img, [1, 0], 1, 'pre');
        img = imfill(img, 'holes');
        img = img(2:end,:,:);

        % fill boundary holes: south
        img = padarray(img, [1, 0], 1, 'post');
        img = imfill(img, 'holes');
        img = img(1:end-1,:,:);

    end

end