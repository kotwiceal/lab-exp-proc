function varargout = predinterm(data, kwargs)
    %% Predict trained CNN to process intermittency.

    arguments
        data (:,:,:) double % multidimensional data
        % version of convolutional neural network
        kwargs.version (1,:) char {mustBeMember(kwargs.version, {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6'})} = '0.1'
        kwargs.network = [] % instance of sequence network
        kwargs.rescale (1,:) double = [0, 1.5]  % mapping data range to specified
        kwargs.crop (1,:) double = [] % crop data: [x0, y0, width, height]
        kwargs.padval (1,:) {mustBeA(kwargs.padval, {'char', 'string', 'double'})} = nan % padding value
        % method of filling missing data
        kwargs.fillmiss (1,:) char {mustBeMember(kwargs.fillmiss, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
    end

    sz = size(data);

    if isempty(kwargs.network)
        d = dir(fullfile(fileparts(mfilename('fullpath')), '..'));
        folder = d(1).folder;
        temporary = load(fullfile(folder, 'net', strcat('cnn_interm_v', kwargs.version, '.mat')));
        kwargs.network = temporary.net;
    end

    if ~isempty(kwargs.crop)
        data = data(kwargs.crop(1):kwargs.crop(1)+kwargs.crop(3)-1,kwargs.crop(2):kwargs.crop(2)+kwargs.crop(4)-1,:);
    end

    if ~isempty(kwargs.rescale)
        data = rescale(data, 0, 255, InputMin = kwargs.rescale(1), InputMax = kwargs.rescale(2));
    end

    binarized = nan(sz);

    for i = 1:size(data, 3)
        binarized(:,:,i) = double(semanticseg(data(:,:,i), kwargs.network)) - 1;
    end

    if ~isempty(kwargs.crop)
        binarized = padarray(binarized, [kwargs.crop(1), kwargs.crop(2)], kwargs.padval, 'pre');
        binarized = padarray(binarized, [sz(1)-kwargs.crop(1)-kwargs.crop(3), sz(2)-kwargs.crop(2)-kwargs.crop(4)], kwargs.padval, 'post');
    end

    intermittency = mean(binarized, 3, 'omitmissing');

    % fillmissing
    if kwargs.fillmiss ~= "none"
        intermittency = fillmissing2(intermittency, kwargs.fillmiss);
    end

    varargout{1} = intermittency;
    varargout{2} = binarized;

end