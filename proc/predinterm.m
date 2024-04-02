function varargout = predinterm(data, kwargs)
    %% Predict trained CNN to process intermittency.

    arguments
        data double % multidimensional data
        % version of convolutional neural network
        kwargs.version (1,:) char {mustBeMember(kwargs.version, {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6'})} = '0.1'
        kwargs.network = [] % instance of sequence network
        kwargs.map (1,:) double = [0, 1.5] % mapping data range to specified
        kwargs.crop (1,4) double = [] % crop data: [x0, y0, width, height]
        kwargs.padval (1,1) double = nan % padding value
        % method of filling missing data
        kwargs.fillmissmeth (1,:) char {mustBeMember(kwargs.fillmissmeth, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
    end

    sz = size(data);

    d = dir(fullfile(fileparts(mfilename('fullpath')), '..'));
    folder = d(1).folder;

    if isempty(kwargs.network)
        temporary = load(fullfile(folder, 'net', strcat('cnn_interm_v', kwargs.version, '.mat')));
        kwargs.network = temporary.net;
    end

    if ~isempty(kwargs.crop)
        data = data(kwargs.crop(1):kwargs.crop(1)+kwargs.crop(3)-1,kwargs.crop(2):kwargs.crop(2)+kwargs.crop(4)-1,:);
    end

    for i = 1:size(data, 3)
        temporary = uint8(mat2gray(data(:,:,i), kwargs.map) * 255);
        binarized(:, :, i) = double(semanticseg(temporary, kwargs.network)) - 1;
    end

    if ~isempty(kwargs.crop)
        binarized = padarray(binarized, [kwargs.crop(1), kwargs.crop(2)], kwargs.padval, 'pre');
        binarized = padarray(binarized, [sz(1)-kwargs.crop(1)-kwargs.crop(3), sz(2)-kwargs.crop(2)-kwargs.crop(4)], kwargs.padval, 'post');
    end

    intermittency = mean(binarized, 3, 'omitmissing');

    % fillmissing
    if kwargs.fillmissmeth ~= "none"
        intermittency = fillmissing2(intermittency, kwargs.fillmissmeth);
    end

    varargout{1} = intermittency;
    varargout{2} = binarized;
end