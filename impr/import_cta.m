function [scan, data, raw] = import_cta(folder, named)
%% Import hot-wire data from specified folder with/without subfolders.
%% The function takes following arguments:
%   folder:             [char array]
%   subfolders:         [logical]
%   extension:          [char array]
%% The function returns following results:
%   scan:               [n×l0×k×... double]
%   data:               [k×11×... double]
%   raw:                [l×m double]
%% Examples:
%% get scan & data from specified folder
% [scan, data, raw] = import_cta('\turb_jet_noise\test')
%% get scan & data from specified folder with subfolders
% [scan, data, raw] = import_cta('\turb_jet_noise\test2', subfolders = true)

    arguments
        folder char
        named.subfolders logical = false
        named.datadelimiter char = '\t'
        named.scandelimiter char = '\t'
        named.rawdelimiter char = '\t'
        named.dataseparator char = '.'
        named.scanseparator char = ','
        named.rawseparator char = ','
    end

    scan = []; data = []; raw = [];

    filenames.data = get_pathes(folder, extension = 'dat', subfolders = named.subfolders);
    indraw = contains(filenames.data, "raw");
    filenames.raw = filenames.data(indraw);
    filenames.data = filenames.data(~indraw);
    filenames.scan = get_pathes(folder, extension = 'txt', subfolders = named.subfolders);

    for i = 1:numel(filenames.data)
        data = cat(3, data, table2array(readtable(filenames.data(i), 'Delimiter', named.datadelimiter, 'DecimalSeparator', named.dataseparator))); 
    end

    data = reshape(data, [size(data, 1:2), size(filenames.data)]);

    for i = 1:numel(filenames.raw)
        temporary = readtable(filenames.raw(i), 'Delimiter', named.rawdelimiter, 'DecimalSeparator', named.rawseparator);
        temporary = table2array(temporary(5:end, 2:end));
        raw = cat(2, raw, temporary); 
    end
    chsz = size(temporary, 2);
    raw = reshape(raw, [size(raw, 1), chsz, size(filenames.raw)]);

    for i = 1:numel(filenames.scan)
        scan = cat(3, scan, table2array(readtable(filenames.scan(i), 'Delimiter', named.scandelimiter, 'DecimalSeparator', named.scanseparator))); 
    end

end