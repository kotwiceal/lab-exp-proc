function varargout = loadcta(folder, kwargs)
%% Import hot-wire data from specified folder with/without subfolders.
%% The function takes following arguments:
%   folder:             [char array]
%   subfolders:         [1×1 logical]
%   extension:          [char array]
%% The function returns following results:
%   scan:               [n×10×m×... double] 
%   data:               [k×11×m×... double]
%   raw:                [l×3×k double]

% n - number of samples at spectra processing, k - number of measurements, l - number of measurement samples
%% Examples:
%% get scan, data, raw from specified folder
% [scan, data, raw] = loadcta('\turb_jet_noise\test')
%% get scan, data, raw from specified folder with subfolders
% [scan, data, raw] = loadcta('\turb_jet_noise\test2', subfolders = true)
%% get structure contained scan, data, raw from specified folder with subfolders
% data = loadcta('\turb_jet_noise\test2', subfolders = true, output = 'struct')

    arguments
        folder char
        kwargs.subfolders logical = false
        kwargs.datadelimiter char = '\t'
        kwargs.scandelimiter char = '\t'
        kwargs.rawdelimiter char = '\t'
        kwargs.dataseparator char = '.'
        kwargs.scanseparator char = ','
        kwargs.rawseparator char = ','
        kwargs.output (1,:) char {mustBeMember(kwargs.output, {'struct', 'array'})} = 'array'
    end

    warning off

    scan = []; data = []; raw = [];

    filenames.data = get_pathes(folder, extension = 'dat', subfolders = kwargs.subfolders);
    indraw = contains(filenames.data, 'raw');
    filenames.raw = filenames.data(indraw);
    filenames.data = filenames.data(~indraw);
    filenames.scan = get_pathes(folder, extension = 'txt', subfolders = kwargs.subfolders);
    indscan = contains(filenames.scan, 'scan');
    filenames.scan = filenames.scan(indscan);

    for i = 1:numel(filenames.data)
        data = cat(3, data, table2array(readtable(filenames.data(i), 'Delimiter', kwargs.datadelimiter, 'DecimalSeparator', kwargs.dataseparator))); 
    end

    data = reshape(data, [size(data, 1:2), size(filenames.data)]);

    for i = 1:numel(filenames.raw)
        temporary = readtable(filenames.raw(i), 'Delimiter', kwargs.rawdelimiter, 'DecimalSeparator', kwargs.rawseparator);
        temporary = table2array(temporary(5:end, 2:end));
        raw = cat(2, raw, temporary); 
    end
    chsz = size(temporary, 2);
    raw = reshape(raw, [size(raw, 1), chsz, size(filenames.raw)]);

    for i = 1:numel(filenames.scan)
        scan = cat(3, scan, table2array(readtable(filenames.scan(i), 'Delimiter', kwargs.scandelimiter, 'DecimalSeparator', kwargs.scanseparator))); 
    end

    switch kwargs.output
        case 'struct'
            result.scan = scan;
            result.data = data;
            result.raw = raw;
            varargout{1} = result;
        case 'array'
            varargout{1} = scan;
            varargout{2} = data;
            varargout{3} = raw;
    end

end