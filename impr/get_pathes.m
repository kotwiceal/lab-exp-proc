function pathes = get_pathes(folder, named)
%% Get all filenames in specified folder with subfolders.
%% The function takes following arguments:
% folder: [char array]
%% The function returns following results:
% pathes: [k×l string array]
    
        arguments
            folder char
            named.sub logical = false
            named.extension char = '.vc7'
        end
    
        if named.sub
            dir_obj = dir(fullfile(folder, '**', strcat('*', named.extension)));
        else
            dir_obj = dir(fullfile(folder, strcat('*', named.extension)));
        end
    
        pathes = ""; temporary = {};
        for i = 1:length(dir_obj)
            pathes(i, 1) = fullfile(dir_obj(i).folder, dir_obj(i).name); 
            temporary{i, 1} = fileparts(dir_obj(i).folder);
        end
        temporary = unique(temporary);
        try
            pathes = reshape(pathes, [], length(temporary));
        catch
            disp('reshape error')
        end
    end