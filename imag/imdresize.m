function result = imdresize(data, sz, kwargs)
    %% Resize page-wise images.

    arguments
        data double % multidimensional data
        sz (1,:) double % object size
        kwargs.parproc (1,1) logical = false % perform paralell processing
    end

    szd = size(data); if ismatrix(data); szd(3) = 1; end
    result = zeros([sz, prod(szd(3:end))]);

    if kwargs.parproc
        parfor i = 1:prod(szd(3:end))
            result(:, :, i) = imresize(data(:, :, i), sz);
        end
    else
        for i = 1:prod(szd(3:end))
            result(:, :, i) = imresize(data(:, :, i), sz);
        end
    end

    result = reshape(result, [sz, szd(3:end)]);

end