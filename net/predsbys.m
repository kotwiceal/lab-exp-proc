function res = preddlnsbys(net, x)
    %% Predict step-by-step output of dlnetwork layers.

    arguments
        net (1,1) dlnetwork
        x double
    end
    
    res = {};
    for i = 1:numel(net.Layers)
        tempnet = dlnetwork(net.Layers(1:i));
        res{i} = double(predict(tempnet, x));
    end
end