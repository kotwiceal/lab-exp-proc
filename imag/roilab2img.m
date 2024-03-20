function varargout = roilab2img(data, kwargs)
%% Generate binary 2D masks specified by polygonal ROI regions.

    arguments
        data {mustBeA(data, {'groundTruth', 'table'})} % groundTruth instance or table containing polyginal masks
        kwargs.size (1,:) double = [270, 320] % size of generated image
        kwargs.map (1,:) double = [0, 1] % mask value mapping to RGB
        kwargs.store (1,:) char = [] % path to store images
        kwargs.extension (1,:) char = '.bmp' % extension of storing images
        kwargs.morph (1,:) char {mustBeMember(kwargs.morph, {'none', 'imdilate'})} = 'none' % apply morphological image processing
        kwargs.strel (1,:) char {mustBeMember(kwargs.strel, {'diamond', 'disk', 'rectangle', 'square'})} = 'disk' % exploit morphological structure element
        kwargs.strelker (1,:) double = 5 % parameters of morphological structure element
        kwargs.fill (1,1) logical = false % apply of morphological image filling
    end

    if isa(data, 'groundTruth')
        data = data.LabelData;
    end
   
    result = nan([kwargs.size, size(data)]);

    % generate binary masks
    for i = 1:size(data, 2)
        for j = 1:size(data, 1)
           if ~isempty(data{j,i}{1})
                masks = data{j,i}{1};
                mask = false(kwargs.size);
                for k = 1:length(masks)
                    temp = masks{k};
                    mask = mask | poly2mask(temp(:,1), temp(:,2), kwargs.size(1), kwargs.size(2));
                end
                result(:,:,j,i) = mask;
            end 
        end
    end

    % morphological processing
    switch kwargs.morph
        case 'imdilate'
            sz = size(result); temporary = nan(sz);
            for i = 1:prod(sz(3:end))
                temporary(:,:,i) = imdilate(result(:,:,i), strel(kwargs.strel, kwargs.strelker));
            end
            result = reshape(temporary, sz);
    end

    if kwargs.fill
        sz = size(result); temporary = zeros(sz);
        result(isnan(result)) = 0;
        for i = 1:prod(sz(3:end))
            temporary(:,:,i) = imfill(result(:,:,i), 'holes');
        end
        result = reshape(temporary, sz);
    end

    varargout{1} = result;

    % store images
    if ~isempty(kwargs.store)
        try mkdir(kwargs.filename); catch; end
        for i = 1:size(result, 4)
            try mkdir(fullfile(kwargs.store, num2str(i))); catch; end
            for j = 1:size(result, 3)
                filename = fullfile(kwargs.store, num2str(i), strcat(num2str(j), kwargs.extension));
                imwrite(mat2gray(result(:,:,j,i), kwargs.map), filename);
            end
        end
    end
end