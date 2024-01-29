function varargout = predinterm(data, kwargs)
%% Predict trained CNN to process intermittency.
%% The function takes following arguments:
%   data:                       [n×m... double]     - multidimensional data
%   network:                    [object]            - instance of sequence network
%   version:                    [char array]        - version of convolutional neural network
%   map:                        [1×2 double]        - mapping data range to specified
%   crop:                       [1×4 double]        - crop data: [x0, y0, width, height]
%% The function returns following results:
%   intermittency:              [n×m double]
%   binarized:                  [n×m... double]

    arguments
        data double
        kwargs.version (1,:) char {mustBeMember(kwargs.version, {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6'})} = '0.1'
        kwargs.network = []
        kwargs.map double = [0, 1.5]
        kwargs.crop double = []
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
        binarized = padarray(binarized, [kwargs.crop(1), kwargs.crop(2)], 0, 'pre');
        binarized = padarray(binarized, [sz(1)-kwargs.crop(1)-kwargs.crop(3), sz(2)-kwargs.crop(2)-kwargs.crop(4)], 0, 'post');
    end

    intermittency = mean(binarized, 3);

    varargout{1} = intermittency;
    varargout{2} = binarized;
end