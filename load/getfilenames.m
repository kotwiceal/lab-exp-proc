function pathes = getfilenames(folder, kwargs)
%% Get all filenames in specified folder with subfolders.
%% The function takes following arguments:
%   folder:             [char array]        - folder path
%   subfolders:         [logical]           - search files in subfolders
%   extension:          [char array]        - extension of searched files
%% The function returns following results:
%   pathes:             [k×... string array]
%% Examples:
%% 1. Get .vc7 filenames from specified folder:
% filenames = getfilenames('\LVExport\u25mps\y_00');
%% 2. Get .vc7 filenames from specified folder with subfolders:
% filenames = getfilenames('\LVExport\u25mps\', subfolders = true);
%% 3. Get .dat filenames from specified folder with subfolders:
% filenames = getfilenames('\LVExport\u25mps\', extension = 'dat', subfolders = true);

    arguments
        folder char
        kwargs.subfolders logical = false
        kwargs.extension char = '.vc7'
    end

    if kwargs.subfolders
        dir_obj = dir(fullfile(folder, '**', strcat('*', kwargs.extension)));
    else
        dir_obj = dir(fullfile(folder, strcat('*', kwargs.extension)));
    end

    pathes = ""; temporary = {};
    for i = 1:length(dir_obj)
        pathes(i, 1) = fullfile(dir_obj(i).folder, dir_obj(i).name); 
        temporary{i, 1} = dir_obj(i).folder;
    end
    temporary = unique(temporary);
    if pathes == ""; pathes = []; end
    try
        pathes = reshape(pathes, [], numel(temporary));
    catch
    end
end