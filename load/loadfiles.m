function [data, filenames] = loadfiles(input, kwargs)
    %% Read text/binary files set.

    arguments
        input (:,:) {mustBeA(input, {'string', 'cell', 'char'})}
        kwargs.folder (1,:) char = []
        kwargs.subfolders (1,1) logical = false
        kwargs.Delimiter (1,:) char = '\t'
        kwargs.DecimalSeparator (1,:) char = '.'
        kwargs.extension (1,:) char = '.txt'
        kwargs.rows (1,:) {mustBeA(kwargs.rows, {'double', 'cell'})} = 1
        kwargs.cols (1,:) {mustBeA(kwargs.cols, {'double', 'cell'})} = 1
        kwargs.format (1,:) char {mustBeMember(kwargs.format, {'ascii', 'binary'})} = 'ascii'
        kwargs.precision (1,:) char = 'int16'
        kwargs.machinefmt (1,:) char = 'b'
        kwargs.VariableNamingRule (1,:) char {mustBeMember(kwargs.VariableNamingRule, {'modify', 'preserve'})} = 'preserve'
    end
    
    if isa(input, 'char'); input = string(input); end

    if isfolder(input)
        kwargs.folder = input;
        kwargs.filenames = getfilenames(kwargs.folder, extension = kwargs.extension, subfolders = kwargs.subfolders);
    else
        kwargs.filenames = input;
    end

    data = cell(1, numel(kwargs.filenames)); sz = size(kwargs.filenames);

    if isa(kwargs.rows, 'double')
        kwargs.rows = repmat({kwargs.rows}, 1, numel(kwargs.filenames));
    end
    
    if isa(kwargs.cols, 'double')
        kwargs.cols = repmat({kwargs.cols}, 1, numel(kwargs.filenames));
    end

    switch kwargs.format
        case 'ascii'
            for i = 1:numel(kwargs.filenames)
                temporary = readtable(kwargs.filenames(i), 'Delimiter', kwargs.Delimiter, 'DecimalSeparator', kwargs.DecimalSeparator, ...
                    'VariableNamingRule', kwargs.VariableNamingRule);

                if isscalar(kwargs.rows{i})
                    kwargs.rows{i} = [kwargs.rows{i}(1,1), size(temporary, 1)-kwargs.rows{i}(1,1)+1];
                end

                if isscalar(kwargs.cols{i})
                    kwargs.cols{i} = [kwargs.cols{i}(1,1), size(temporary, 2)-kwargs.cols{i}(1,1)+1];
                end
                
                temporary = table2array(temporary(kwargs.rows{i}(1,1):kwargs.rows{i}(1,2), ...
                    kwargs.cols{i}(1,1):kwargs.cols{i}(1,2)));

                data{i} = temporary; 
            end
        case 'binary'
            for i = 1:numel(kwargs.filenames) 
                id = fopen(kwargs.filenames(i), 'r');
                temporary = fread(id, kwargs.precision, kwargs.machinefmt);
                fclose(id);
                data{i} = temporary;
            end
    end

    szd = zeros(numel(data), 2);
    for i = 1:numel(data)
        szd(i,:) = size(data{i});
    end

    if numel(unique(szd(:))) == 2
        data = reshape(cell2mat(data), [szd(1,:), numel(data)]);
    else
        data = reshape(data, sz);
    end

    filenames = kwargs.filenames;

end