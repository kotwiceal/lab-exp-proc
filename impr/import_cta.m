function [scan, data] = import_cta(folder, named)
%% Import hot-wire data from specified folder with/without subfolders.
%% The function takes following arguments:
%   folder:             [char array]
%   subfolders:         [logical]
%   extension:          [char array]
%% The function returns following results:
%   scan:               [n×l0×k×... double]
%   data:               [k×11×... double]
%% Examples:
%% get scan & data from specified folder
% [scan, data] = import_cta('\turb_jet_noise\test')
%% get scan & data from specified folder with subfolders
% [scan, data] = import_cta('\turb_jet_noise\test2', subfolders = true)

    arguments
        folder char
        named.subfolders logical = false
        named.datadelimiter char = '\t'
        named.scandelimiter char = '\t'
        named.dataseparator char = '.'
        named.scanseparator char = ','
    end

    scan = []; data = [];

    filenames.data = get_pathes(folder, extension = 'dat', subfolders = named.subfolders);
    filenames.scan = get_pathes(folder, extension = 'txt', subfolders = named.subfolders);

    for i = 1:numel(filenames.data)
        data = cat(3, data, table2array(readtable(filenames.data(i), 'Delimiter', named.datadelimiter, 'DecimalSeparator', named.dataseparator))); 
    end

    data = reshape(data, [size(data, 1:2), size(filenames.data)]);

    for i = 1:numel(filenames.scan)
        scan = cat(3, scan, table2array(readtable(filenames.scan(i), 'Delimiter', named.scandelimiter, 'DecimalSeparator', named.scanseparator))); 
    end

end