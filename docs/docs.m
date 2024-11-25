%% Generate function anotation by LLM (Ollama) via API
folderscripts = 'cta';
folderdocs = 'docs';
files = dir(fullfile(folderscripts,'\*.m'));
files = {files.name};
maxOutputLines = 20;
action = "Explain the following MATLAB function. Use MATLAB comment syntax";

for i = 1:numel(files)
    text = fileread(fullfile(folderscripts,files{i}));
    response = requestllm(action+text);
    writelines(response, fullfile(folderdocs, strcat('pub_', files{i})))
    res = readlines(fullfile(folderdocs, strcat('pub_', files{i})));
    res = "%"+res;
    writelines(res, fullfile(folderdocs, strcat('pub_', files{i})))
    publish(fullfile(folderdocs, strcat('pub_', files{i})), maxOutputLines = maxOutputLines)
end