function result = immorph(data, kwargs)
    %% Batch morphological image processing.

    arguments
        data double % multidimensional data
        % morphological method
        kwargs.method (1,:) char {mustBeMember(kwargs.method , {'none', 'fill', 'erode', 'dialte', 'close', 'open'})} = 'erode'
        kwargs.strel (1,:) char {mustBeMember(kwargs.strel, {'disk'})} = 'disk' % structure element
        kwargs.strelker (1,:) double = 4 % kernel of structure element
        kwargs.parproc (1,1) logical = false % perform parallel processing
    end

    strl = strel(kwargs.strelker, kwargs.strelker);

    switch kwargs.method 
        case 'fill'
            method = @(img) imfill(img, 'holes');
        case 'erode'
            method = @(img) imerode(img, strl);
        case 'dialte'
            method = @(img) imdialte(img, strl);
        case 'close'
            method = @(img) imclose(img, strl);
        case 'open'
            method = @(img) imopen(img, strl);
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
end