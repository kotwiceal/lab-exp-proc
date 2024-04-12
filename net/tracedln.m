function tracedln(input, data, kwargs)
    % Trace layers output of deep neural network.

    arguments
        input {mustBeA(input, {'dlnetwork', 'nnet.cnn.layer.Layer'})}
        data {mustBeA(data, {'double', 'matlab.io.datastore.ArrayDatastore'})}
        kwargs.verbose (1,1) logical = true
        kwargs.clim (1,:) = []
        kwargs.docked (1,1) logical = true
    end

    if isa(input, 'nnet.cnn.layer.Layer')
        input = dlnetwork(input);
    end

    network = initialize(input);

    if kwargs.verbose; summary(network); end

    if isa(data, 'matlab.io.datastore.ArrayDatastore')
        data = read(data);
        data = dlarray(data{1}, 'SSCB');
    end

    response = predict(network, data);
    response = extractdata(response);

    if isa(data, 'dlarray')
        data = extractdata(data);
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); 
    nexttile; imagesc(data); axis image; colorbar;
    nexttile; montage(response); axis on; axis image; colorbar; colormap turbo; 
    title(num2str(size(response)), 'FontWeight','normal'); 
    if ~isempty(kwargs.clim); clim(kwargs.clim); end

end