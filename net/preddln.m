function varargout = preddln(network, data, param)
    %% Predict by deep neural network.

    arguments (Input)
        network {mustBeA(network, {'dlnetwork'})}
        data {mustBeA(data, {'matlab.io.datastore.SequentialDatastore', 'matlab.io.datastore.TransformedDatastore', 'matlab.io.datastore.CombinedDatastore'})}
        param.ans {mustBeMember(param.ans, {'double', 'struct', 'table'})} = 'double'
    end
    arguments (Output, Repeating)
        varargout {mustBeA(varargout, {'double', 'struct', 'table'})}
    end

    temp = readall(data);
    X = temp(:,1);
    T = temp(:,2);
        
    Y = cell(numel(X), 1);
    for i = 1:numel(X)
        Y{i} = gather(predict(network, X{i}));
    end

    temp = cellfun(@cell2arr, {X; Y; T}, UniformOutput = false);
    [X, Y, T] = deal(temp{:});

    switch param.ans
        case 'double'
            varargout = cell(1 ,3);
            [varargout{:}] = deal(X, Y, T);
        case 'struct'
            varargout{1} = struct(X = X, Y = Y, T = T);
        case 'table'
            varargout{1} = table({X}, {Y}, {T}, 'VariableNames', {'X', 'Y', 'T'});
    end

end