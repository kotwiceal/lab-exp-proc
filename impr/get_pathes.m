function pathes = get_pathes(folder)
%% Get all filenames in specified folder with subfolders.
%% The function takes following arguments:
% folder: [char array]
%% The function returns following results:
% pathes: [k×l string array]

    path = dir(folder); path(1:2) = []; pathes = "";
    for i = 1:length(path)
        temporary = dir(fullfile(folder, path(i).name));
        if (length(temporary) ~= 1)
            temporary(1:2) = [];
            for j = 1:size(temporary, 1)
                pathes(j, i) = fullfile(temporary(j).folder, temporary(j).name);
            end
        else
            pathes(1, i) = fullfile(temporary.folder, temporary.name);
        end
    end
end