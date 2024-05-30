function data = loadfiles(input, kwargs)
    %% Read text/binary files set.

    arguments
        input (:,:) {mustBeA(input, {'string', 'cell', 'char'})}
        kwargs.folder (1,:) char = []
        kwargs.subfolders (1,1) logical = false
        kwargs.Delimiter (1,:) char = '\t'
        kwargs.DecimalSeparator (1,:) char = '.'
        kwargs.extension (1,:) char = '.txt'
        kwargs.origin (:,:) double = [1, 1]
        kwargs.format (1,:) char {mustBeMember(kwargs.format, {'ascii', 'binary'})} = 'ascii'
        kwargs.precision (1,:) char = 'int16'
        kwargs.machinefmt (1,:) char = 'b'
        kwargs.VariableNamingRule (1,:) char {mustBeMember(kwargs.VariableNamingRule, {'modify', 'preserve'})} = 'preserve'
    end
    
    data = [];

    if isa(input, 'char'); input = string(input); end

    if isfolder(input)
        kwargs.folder = input;
        kwargs.filenames = getfilenames(kwargs.folder, extension = kwargs.extension, subfolders = kwargs.subfolders);
    else
        kwargs.filenames = input;
    end
    
    switch kwargs.format
        case 'ascii'
            for i = 1:numel(kwargs.filenames)
                temporary = readtable(kwargs.filenames(i), 'Delimiter', kwargs.Delimiter, 'DecimalSeparator', kwargs.DecimalSeparator, ...
                    'VariableNamingRule', kwargs.VariableNamingRule);
                if isvector(kwargs.origin)
                    temporary = table2array(temporary(kwargs.origin(1):end, kwargs.origin(2):end));
                else
                    if isnan(kwargs.origin(1,2)); kwargs.origin(1,2) = size(temporary,1)-kwargs.origin(1,1); end
                    if isnan(kwargs.origin(2,2)); kwargs.origin(2,2) = size(temporary,2)-kwargs.origin(2,1); end
                    temporary = table2array(temporary(kwargs.origin(1,1):kwargs.origin(1,2), kwargs.origin(2,1):kwargs.origin(2,2)));
                end
                data = cat(ndims(temporary) + 1, data, temporary); 
            end
        case 'binary'
            id = fopen(kwargs.filenames(1), 'r');
            test = fread(id, kwargs.precision, kwargs.machinefmt);
            fclose(id);

            temporary = zeros(numel(test), numel(kwargs.filenames));
            temporary(:, 1) = test;

            for i = 2:numel(kwargs.filenames) 
                id = fopen(kwargs.filenames(i), 'r');
                temporary(:, i) = fread(id, kwargs.precision, kwargs.machinefmt);
                fclose(id);
            end

            data = temporary;
    end

end