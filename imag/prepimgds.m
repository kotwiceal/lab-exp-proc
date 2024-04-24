function prepimgds(varargin, kwargs)
    %% Create image datastore in specified local folder.
        
    %% Examples:
    %% 1. Rescale data, combine data slices by third dimension and store colored images by specified path:
    % prepimgds(data.vm, data.dwdl, data.l2, rescale = {[0.7, 1.2], [0, 1e-2], [0, 1e-2]}, ...
    %   folder = '\test', extension = '.bmp');

    arguments (Repeating)
        varargin (:,:,:) double % data
    end

    arguments
        kwargs.folder (1,:) {mustBeA(kwargs.folder, {'char', 'string'})} = '' % storing path
        kwargs.extension (1,:) char = '.png' % extension of storing images
        kwargs.rescale (1,:) cell = {} % rescale data
    end

    % validate data size
    sz = cell(1, numel(varargin));
    for i = 1:numel(varargin); sz{i} = size(varargin{i}); end
    if numel(unique(cell2mat(sz))) ~= 3; error('data must be same size'); end

    % validate rescale cell array
    if isempty(kwargs.rescale); kwargs.rescale = repmat({[0, 1]}, 1, numel(varargin)); end
    if numel(kwargs.rescale) ~= numel(varargin); error('rescale cell array must correspond to input data'); end

    % rescale data
    for i = 1:numel(varargin); varargin{i} = rescale(varargin{i}, 0, 255, 'InputMin', kwargs.rescale{i}(1), 'InputMax', kwargs.rescale{i}(2)); end

    % stack data
    data = cat(4, varargin{:}); data = permute(data, [1, 2, 4, 3]);
    sz = size(data);

    % validate folder
    if isempty(kwargs.folder); error('specify a folder to export images'); end
    try mkdir(kwargs.folder); catch; end

    for i = 1:sz(4)
        filename = fullfile(kwargs.folder, strcat(num2str(i), kwargs.extension));
        img = reshape(data(:,:,:,i), sz(1), []);
        img = ind2rgb(round(img), turbo);
        imwrite(img, filename);
    end

end