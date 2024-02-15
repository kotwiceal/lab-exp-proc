function varargout = loadcta(folder, kwargs)
%% Import hot-wire data from specified folder with/without subfolders.
%% The function takes following arguments:
%   folder:             [1×n char]          - folder path
%   subfolders:         [1×1 logical]       - search files in subfolders
%   rawtype:            [1×m char]          - type of raw file reading
%   numch:              [1×1 double]        - number of ADC channels
%% The function returns following results:
%   scan:               [n×10×m×... double] 
%   data:               [k×11×m×... double]
%   raw:                [l×3×k double]

% n - number of samples at spectra processing, k - number of measurements, l - number of measurement samples
%% Examples:
%% 1. Get scan, data, raw from specified folder:
% [scan, data, raw] = loadcta('\turb_jet_noise\test')
%% 2. Get scan, data, raw from specified folder with subfolders:
% [scan, data, raw] = loadcta('\turb_jet_noise\test2', subfolders = true)
%% 3. Get structure contained scan, data, raw from specified folder with subfolders:
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
        kwargs.rawtype (1,:) char {mustBeMember(kwargs.rawtype, {'ascii', 'bin'})} = 'bin'
        kwargs.numch (1,1) double = 2
        kwargs.output (1,:) char {mustBeMember(kwargs.output, {'struct', 'array'})} = 'struct'
    end

    warning off

    scan = []; data = []; raw = [];

    % get filenames
    filenames.data = getfilenames(folder, extension = 'dat', subfolders = kwargs.subfolders);
    indraw = contains(filenames.data, 'raw');
    filenames.raw = filenames.data(indraw);
    filenames.data = filenames.data(~indraw);
    filenames.scan = getfilenames(folder, extension = 'txt', subfolders = kwargs.subfolders);
    indscan = contains(filenames.scan, 'scan');
    filenames.scan = filenames.scan(indscan);

    % load spectra
    try
        for i = 1:numel(filenames.data)
            data = cat(3, data, table2array(readtable(filenames.data(i), 'Delimiter', kwargs.datadelimiter, 'DecimalSeparator', kwargs.dataseparator))); 
        end
        data = reshape(data, [size(data, 1:2), size(filenames.data)]);
    catch
        disp("loadcta: data loading is failed")
        data = [];
    end

    % load raw
    try
        switch kwargs.rawtype
            case 'ascii'
                for i = 1:numel(filenames.raw)
                    temporary = readtable(filenames.raw(i), 'Delimiter', kwargs.rawdelimiter, 'DecimalSeparator', kwargs.rawseparator);
                    temporary = table2array(temporary(5:end, 2:end));
                    raw = cat(2, raw, temporary); 
                end
                chsz = size(temporary, 2);
                raw = reshape(raw, [size(raw, 1), chsz, size(filenames.raw)]);
            case 'bin'
                temporary = [];
                for i = 1:numel(filenames.raw)
                    id = fopen(filenames.raw(i), 'r');
                    temporary = cat(2, temporary, fread(id, 'int16', 'b'));
                    fclose(id);
                end
                raw = reshape(temporary, [size(temporary,1)/kwargs.numch, kwargs.numch, numel(filenames.raw)]);
        end
    catch
        disp("loadcta: raw loading is failed")
        raw = [];
    end

    % load scan
    try
        for i = 1:numel(filenames.scan)
            scan = cat(3, scan, table2array(readtable(filenames.scan(i), 'Delimiter', kwargs.scandelimiter, 'DecimalSeparator', kwargs.scanseparator))); 
        end
    catch 
        disp("loadcta: scan loading is failed")
        scan = [];
    end

    % return
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