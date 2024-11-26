%% Generate a navigation page
publish('docs\pub_main.m');
%% Generate function anotation by LLM (Ollama) via API
folderscripts = 'cta';
folderdocs = 'docs';
folderdescr = 'docs\descr';
folderexamp = 'docs\examp';
files = dir(fullfile(folderscripts,'\*.m'));
files = {files.name};
maxOutputLines = 10;
action = "Explain the following MATLAB function. Use MATLAB comment syntax";

for i = 1:numel(files)
    % load script as text
    text = fileread(fullfile(folderscripts,files{i}));
    % request LLM
    response = requestllm(action + text);
    % store response and modify
    writelines(response, fullfile(folderdescr, strcat('descr_', files{i})))
    descr = readlines(fullfile(folderdescr, strcat('descr_', files{i})));
    descr = "% " + descr;
    descr = cat(1, "%% Description", descr);
    writelines(descr, fullfile(folderdescr, strcat('descr_', files{i})))
    % combine description and example sections and store
    descr = readlines(fullfile(folderdescr, strcat('descr_', files{i})));
    examp = readlines(fullfile(folderexamp, strcat('examp_', files{i})));
    writelines(cat(1, descr, examp), fullfile(folderdocs, strcat('pub_', files{i})))
    % publish documentation
    publish(fullfile(folderdocs, strcat('pub_', files{i})), maxOutputLines = maxOutputLines);
end