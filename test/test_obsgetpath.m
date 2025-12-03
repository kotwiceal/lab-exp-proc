%%
folder = 'H:\projects\obs-lab-logs'
mdfile = 'logs/2025-11-13/2025-11-13 12-16-06.md'
%%
clc
exts = ["fig", "png", "gif"];
p  = dir(fullfile(folder, 'files', 'plots', '*.fig'));
p = arrayfun(@(f,n) fullfile(f,n), [p(:).folder, ""], [p(:).name, ""])
p = p(1:end-1);
p