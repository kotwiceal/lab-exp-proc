function obscontpast(filename, imagename, param)
    %% Paste media link by markdown placeholder.

    arguments
        filename {mustBeTextScalar}
        imagename {mustBeTextScalar}
        param.fig (1,1) logical = true
        param.size (1,:) {mustBeInteger, mustBeInRange(param.size, 1, 1000)} = 400
        param.pattern {mustBeTextScalar} = '%%'
        param.extenstion {mustBeTextScalar} = ".md"
    end

    if ~isfile(filename)
        filename = fullfile(pwd, filename);
    end

    [~, ~, extenstion] = fileparts(filename);
    if param.extenstion ~= extenstion; return; end

    [~, name] = fileparts(imagename);

    if param.fig
        if isempty(param.size)
            imagename = strcat("![[",imagename,"]]"," ![[",name,".fig]]");
        else
            imagename = strcat("![[",imagename,"\|", num2str(param.size), "]]"," ![[",name,".fig]]");
        end
    else
        if isempty(param.size)
            imagename = strcat("![[",imagename,"]]");
        else
            imagename = strcat("![[",imagename,"\|", num2str(param.size), "]]");
        end
    end
    text = string(fileread(filename));
    
    tf = contains(text, param.pattern);
    
    if tf
        % replace first matched
        index = strfind(text, param.pattern);
        text = char(text);
        text(index(1)+(0:numel(param.pattern)-1)) = '%#';
        text = string(text);

        text = strrep(text, '%#', imagename);
    else
        text = strcat(text, imagename);
    end
    
    writelines(text, filename)
end