function varargout = loadcta(folder, kwargs)
    %% Import hot-wire data from specified folder with/without subfolders.
    %% The function takes following arguments:
    %   folder:             [1×n char]          - folder path
    %   subfolders:         [1×1 logical]       - search files in subfolders
    %   rawtype:            [1×m char]          - type of raw file reading
    %   numch:              [1×1 double]        - number of ADC channels
    %% The function returns following results:
    %   scan:               [n×10×m×... double] 
    %   data:               [k×11×m×... double]
    %   raw:                [l×3×k double]
    
    % n - number of samples at spectra processing, k - number of measurements, l - number of measurement samples
    %% Examples:
    %% 1. Get scan, data, raw from specified folder:
    % [scan, data, raw] = loadcta('\turb_jet_noise\test')
    %% 2. Get scan, data, raw from specified folder with subfolders:
    % [scan, data, raw] = loadcta('\turb_jet_noise\test2', subfolders = true)
    %% 3. Get structure contained scan, data, raw from specified folder with subfolders:
    % data = loadcta('\turb_jet_noise\test2', subfolders = true, output = 'struct')
    
        arguments
            folder (1,:) char
            kwargs.subfolders (1,1) logical = false
            kwargs.datadelimiter (1,:) char = '\t'
            kwargs.scandelimiter (1,:) char = '\t'
            kwargs.rawdelimiter (1,:) char = '\t'
            kwargs.dataseparator (1,:) char = '.'
            kwargs.scanseparator (1,:) char = ','
            kwargs.rawseparator (1,:) char = ','
            kwargs.rawextension (1,:) char = '.dat'
            kwargs.rawtype (1,:) char {mustBeMember(kwargs.rawtype, {'ascii', 'bin'})} = 'bin'
            kwargs.numch (1,1) double = 2
            kwargs.output (1,:) char {mustBeMember(kwargs.output, {'struct', 'array'})} = 'struct'
            kwargs.parload (1,1) logical = false
            kwargs.calib (1,1) logical = true
        end
    
        warning on
    
        scan = []; data = []; raw = [];
    
        % get filenames
        filenames.dat = getfilenames(folder, extension = '.dat', subfolders = kwargs.subfolders);
        filenames.txt = getfilenames(folder, extension = '.txt', subfolders = kwargs.subfolders);
        filenames.raw = filenames.dat(contains(filenames.dat, 'raw'));
        filenames.data = filenames.dat(~contains(filenames.dat, 'raw'));
        filenames.scan = filenames.txt(contains(filenames.txt, 'scan'));
        filenames.cal = filenames.txt(contains(filenames.txt, 'cal'));
    
        % load spectra
        try
            for i = 1:numel(filenames.data)
                data = cat(3, data, table2array(readtable(filenames.data(i), 'Delimiter', kwargs.datadelimiter, 'DecimalSeparator', kwargs.dataseparator))); 
            end
            data = reshape(data, [size(data, 1:2), size(filenames.data)]);
        catch
            warning("data loading failed")
        end
    
        % load raw
        try
            switch kwargs.rawtype
                case 'ascii'
                    for i = 1:numel(filenames.raw)
                        temporary = readtable(filenames.raw(i), 'Delimiter', kwargs.rawdelimiter, 'DecimalSeparator', kwargs.rawseparator, ...
                            'VariableNamingRule', 'preserve');
                        temporary = table2array(temporary(5:end, 2:end));
                        raw = cat(2, raw, temporary); 
                    end
                    chsz = size(temporary, 2);
                    raw = reshape(raw, [size(raw, 1), chsz, size(filenames.raw)]);
                case 'bin'
                    id = fopen(filenames.raw(1), 'r');
                    test = fread(id, 'int16', 'b');
                    fclose(id);
    
                    temporary = zeros(numel(test), numel(filenames.raw));
                    temporary(:, 1) = test;
    
                    if kwargs.parload
                        parfor i = 2:numel(filenames.raw)   
                            id = fopen(filenames.raw(i), 'r');
                            temporary(:, i) = fread(id, 'int16', 'b');
                            fclose(id);
                        end
                    else
                        for i = 2:numel(filenames.raw) 
                            id = fopen(filenames.raw(i), 'r');
                            temporary(:, i) = fread(id, 'int16', 'b');
                            fclose(id);
                        end
                    end
                    raw = permute(reshape(temporary, kwargs.numch, [], numel(filenames.raw)), [2, 1, 3]);
                    raw = raw(3:end,:,:);
            end
        catch
            warning("raw loading failed")
        end
    
        % load scan
        try
            for i = 1:numel(filenames.scan)
                scan = cat(3, scan, table2array(readtable(filenames.scan(i), 'Delimiter', kwargs.scandelimiter, 'DecimalSeparator', kwargs.scanseparator))); 
            end
        catch 
            warning("scan loading failed")
        end
    
        % load cal
        try
            if ~isempty(filenames.cal) && kwargs.calib
                mes = "calibration loading failed";
                temporary = readtable(filenames.cal, 'Delimiter', 'tab', 'VariableNamingRule', 'Preserve');
                voltmap = table2array(temporary(1:3,1:2));
                coef = table2array(temporary(6,:));
    
                mes = "calibration applying failed";
                % convert to voltage
                sz = size(raw); if ismatrix(raw); sz(3) = 1; end
                raw = permute(permute(raw,[2, 1, 3]).*voltmap(1:sz(2),2)+voltmap(1:sz(2),1), [2, 1, 3]);
    
                % convert to velocity
                eccor = ((coef(5)-coef(4))./(coef(5)-scan(1:sz(3),10))).^0.5;
                raw(:,1,:) = permute(coef(1)*((squeeze(raw(:,1,:)).*eccor').^2-coef(3)).^coef(2), [1, 3, 2]);
                raw = real(raw);
            end
        catch
            warning(mes);
        end
    
        % return
        switch kwargs.output
            case 'struct'
                result = struct();
                if ~isempty(scan); result.scan = scan; end
                if ~isempty(data); result.data = data; end
                if ~isempty(raw); result.raw = raw; end
                varargout{1} = result;
            case 'array'
                varargout{1} = scan;
                varargout{2} = data;
                varargout{3} = raw;
        end
    
    end