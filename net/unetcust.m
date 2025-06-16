function net = unetcust(imgsz, blk, param)
%% Initialize custom U-net neural network for image segmentation problem. 

    arguments (Input)
        imgsz {mustBeInteger, mustBeGreaterThanOrEqual(imgsz, 1)} % input data size
        blk (1,1) {mustBeInteger, mustBeGreaterThanOrEqual(blk, 1)} % blocks number
        param.labnum {mustBeInteger, mustBeGreaterThanOrEqual(param.labnum, 1)} = 2 % labels number
        param.avgker (1,:) cell = {} % average pooling kernel size
        param.avgstr (1,:) cell = {} % average pooling kernel stride
        param.convker (1,:) cell = {} % 2D convolution kernel size
        param.convfilt (1,:) cell = {} % 2D convolution kernel number
        param.convstr (1,:) cell = {} % 2D convolution kernel stride
        param.show (1,1) logical = true % show net graph
        param.docked (1,1) logical = true % docked figure
        param.summarize (1,1) logical = true % summarize layers info
    end
    
    arguments (Output)
        net (1,1) dlnetwork
    end
    
    if isempty(param.avgker); param.avgker = repmat({[1, 1]}, blk, 1); end
    if isempty(param.avgstr); param.avgstr = repmat({[1, 1]}, blk, 1); end
    if isempty(param.convker); param.convker = repmat({[1, 1]}, blk, 1); end
    if isempty(param.convfilt); param.convfilt = repmat({1}, blk, 1); end
    if isempty(param.convstr); param.convstr = repmat({[1, 1]}, blk, 1); end

    % assembly encoder and decoder
    encoder = []; decoder = [];
    for i = 1:blk
        ind = num2str(i);
    
        layers = [  
            averagePooling2dLayer(param.avgker{i}, Stride = param.avgstr{i}, Name = strcat("enc_avg_",ind))
            convolution2dLayer(param.convker{i}, param.convfilt{i}, Stride = param.convstr{i}, Name = strcat("enc_conv_",ind))
            batchNormalizationLayer(Name = strcat("enc_norm_",ind))
            reluLayer(Name = strcat("enc_relu_",ind))
        ];
        encoder = [encoder; layers];
    
        j = blk + 1 - i;
        layers = [
            concatenationLayer(3, 2, Name = strcat("dec_cat_",ind))
            transposedConv2dLayer(param.convker{j}, param.convfilt{j}, Stride = param.convstr{j}, Name = strcat("dec_conv_",ind))
            batchNormalizationLayer(Name = strcat("dec_norm_",ind))
            reluLayer(Name = strcat("dec_relu_",ind))
        ];
        if i == 1; layers(1) = []; end
        decoder = [decoder; layers];
    end
    
    layers = [imageInputLayer(imgsz, Name = "in"); encoder; decoder; ...
        convolution2dLayer(1, param.labnum, Name = "out_conv"); softmaxLayer(Name = "out_max")];
    
    % define net
    net = dlnetwork;
    net = addLayers(net, layers);
    
    % assign bypass connections
    for i = 1:blk-1
        net = connectLayers(net, strcat("enc_relu_", num2str(i)), strcat("dec_cat_", num2str(blk - i + 1), "/in2"));
    end
    
    if param.show
        if param.docked; figure(WindowStyle = 'docked'); else; clf; end
        plot(net)
    end

    if param.summarize; analyzeNetwork(net); end

end