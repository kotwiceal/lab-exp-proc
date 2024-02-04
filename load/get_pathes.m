function pathes = get_pathes(folder, kwargs)
%% Get all filenames in specified folder with subfolders.
%% The function takes following arguments:
%   folder:             [char array]
%   subfolders:         [logical]
%   extension:          [char array]
%% The function returns following results:
%   pathes:             [k×... string array]
%% Examples:
%% get .vc7 filenames from specified folder
% filenames = get_pather('\LVExport\u25mps\y_00');
%% get .vc7 filenames from specified folder with subfolders
% filenames = get_pather('\LVExport\u25mps\', subfolders = true);
%% get .dat filenames from specified folder with subfolders
% filenames = get_pather('\LVExport\u25mps\', extension = 'dat', subfolders = true);

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
    try
        pathes = reshape(pathes, [], numel(temporary));
    catch
        disp('reshape error')
    end
end