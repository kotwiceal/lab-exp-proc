function varargout = roilab2img(data, kwargs)
    arguments
        data table
        kwargs.size (1,:) double = [270, 320]
        kwargs.map (1,:) double = [0, 1]
        kwargs.store (1,:) char = []
        kwargs.extension (1,:) char = '.bmp'
    end
   
    result = nan([kwargs.size, size(data)]);

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

    varargout{1} = result;

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