function varargout = preddln(network, data, kwargs)
    %% Predict the train deep neural network.

    arguments
        network {mustBeA(network, {'dlnetwork'})}
        data {mustBeA(data, {'double', 'matlab.io.datastore.ArrayDatastore', 'matlab.io.datastore.CombinedDatastore'})}
        kwargs.type (1,:) char {mustBeMember(kwargs.type, {'simple', 'segmentation'})} = 'simple'
    end

    switch kwargs.type
        case 'segmentation'
            if isa(data, 'double')
                sz = size(data); if ndims(data) == 1; sz(3) = 1; end
                result = zeros(sz);
                for i = 1:prod(sz(3:end))
                    [~, result(:,:,i)] = max(predict(network, data(:,:,i)), [], 3);
                end
                result = result - 1;
            end
        
            if isa(data, 'matlab.io.datastore.ArrayDatastore')
                data = readall(data); sz = size(data{1}); result = zeros([sz, numel(data)]);
                for i = 1:numel(data)
                    [~, result(:,:,i)] = max(predict(network, data{i}), [], 3);
                end
                result = result - 1;
            end
        
            if isa(data, 'matlab.io.datastore.CombinedDatastore')
                input = readall(data.UnderlyingDatastores{1}); output = readall(data.UnderlyingDatastores{2});
                result = zeros([size(input{1}), numel(input)]); resultRaw = zeros([size(output{1}), numel(output)]);
                for i = 1:numel(input)
                    [~, result(:,:,i)] = max(predict(network, input{i}), [], 3);
                    resultRaw(:,:,i) = double(output{i}) - 1;
                end
                result = result - 1;
                varargout{2} = vecnorm(resultRaw-result, 2, 3);
            end
        case 'simple'
            if isa(data, 'double')
                sz = size(data); if ndims(data) == 1; sz(3) = 1; end
                result = zeros(sz);
                for i = 1:prod(sz(3:end))
                    result(:,:,i) = predict(network, data(:,:,i));
                end
            end
        
            if isa(data, 'matlab.io.datastore.ArrayDatastore')
                data = readall(data); sz = size(data{1}); result = zeros([sz, numel(data)]);
                for i = 1:numel(data)
                    result(:,:,i) = predict(network, data{i});
                end
            end
        
            if isa(data, 'matlab.io.datastore.CombinedDatastore')
                input = readall(data.UnderlyingDatastores{1}); output = readall(data.UnderlyingDatastores{2});
                result = zeros([size(input{1}), numel(input)]); resultRaw = zeros([size(output{1}), numel(output)]);
                for i = 1:numel(input)
                    result(:,:,i) = predict(network, input{i});
                    resultRaw(:,:,i) = output{i};
                end
                varargout{2} = vecnorm(resultRaw-result, 2, 3);
            end
    end
    varargout{1} = result;

end