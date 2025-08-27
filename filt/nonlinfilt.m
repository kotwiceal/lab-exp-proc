function result = nonlinfilt(method, varargin, kwargs, opts, pool)
    %% Filter data by multi dimensional sliding window and multi argument nonlinear kernel.
    
    arguments (Input)
        method function_handle %% non-linear kernel function
    end

    arguments (Repeating, Input)
        varargin % data
    end

    arguments (Input)
        kwargs.filtdim {mustBeA(kwargs.filtdim, {'double', 'cell'})} = [] % data dimension to apply filter
        kwargs.kernel {mustBeA(kwargs.kernel, {'double', 'cell'})} = [] % window size
        kwargs.stride {mustBeA(kwargs.stride, {'double', 'cell'})} = [] % window stride
        kwargs.offset {mustBeA(kwargs.offset, {'double', 'cell'})} = [] % window offset
        kwargs.cast (1,:) char {mustBeMember(kwargs.cast, {'int8', 'int16', 'int32', 'int64'})} = 'int32' % cast type of evaluated filter indexes
        kwargs.padval {mustBeA(kwargs.padval, {'double', 'char', 'string', 'logical', 'cell'})} = nan % padding value
        % enable multi dimensional slicing
        % if is not empty `param.filtdim` than `param.kernel` will be modified like `param.kernel = [nan, ..., param.filtdim, ..., nan]`
        kwargs.slice (1,1) logical = false
        opts.verbose logical {mustBeScalarOrEmpty} = false % enable logger
        opts.ans {mustBeMember(opts.ans, {'array', 'cell', 'filedatastore'})} = 'array' % returned data type 
        %% advance parallel processing settings
        % the main sliding window parallel loop will slice and store data 
        % than the filedatastore inistance will be initialized and 
        % evaluate `method` using build-in parallel loop 
        opts.usefiledatastore (1, 1) logical = false 
        opts.useparallel (1,1) logical = false % is parallel evaluation

        % data evalutation approach: `readall` load all data from datastore
        % than apply `method`; `writeall` slicing load data from datastore
        % and save result in the buffer new filedatastore
        opts.extract {mustBeMember(opts.extract, {'readall', 'writeall'})} = 'readall'
        pool.poolsize (1,:) double = 16
        pool.resources {mustBeA(pool.resources, {'char', 'string', 'cell'}), mustBeMember(pool.resources, {'Processes', 'Threads'})} = 'Threads'
    end

    arguments (Output)
        result
    end

    % parse pool parameters
    if isa(pool.poolsize, 'double'); pool.poolsize = num2cell(pool.poolsize); end
    if isscalar(pool.poolsize); pool.poolsize = repmat(pool.poolsize, 1, 2); end
    if isa(pool.resources, 'char'); pool.resources = string(pool.resources); end
    if isscalar(pool.resources); pool.resources = repmat(pool.resources, 1, 2); end
    if ~isa(pool.resources, 'cell'); pool.resources = cellstr(pool.resources); end
    % prepare pool
    poolarg = cellfun(@(x,y){x,y}, pool.resources, pool.poolsize, UniformOutput = false);
    poolswitcher(poolarg{1}{:});

    timer = tic;

    if opts.usefiledatastore
        opts.folder = makefolder();
        opts.method = method;
        method = @(varargin) matfilesaveker(opts.folder, varargin{:});
    end

    % flat vector data
    for i = 1:numel(varargin)
        if isvector(varargin{i}); varargin{i} = varargin{i}(:); end
    end

    % evaluate size
    kwargs.szarg = cellfun(@size, varargin, UniformOutput = false);

    % evaluate filter passing
    filtevalh = memoize(@filteval);
    arg = namedargs2cell(kwargs);
    kwargs = filtevalh(arg{:});

    % append padding
    for i = 1:kwargs.narg
        for j = 1:size(kwargs.outbound{i}, 1)
            padsize = zeros(1, size(kwargs.outbound{i}, 1));
            padsize(j) = kwargs.outbound{i}(j, 1);
            if sum(padsize) ~= 0
                varargin{i} = padarray(varargin{i}, padsize, kwargs.padval{i}{j}, 'pre');
            end

            padsize = zeros(1, size(kwargs.outbound{i}, 1));
            padsize(j) = kwargs.outbound{i}(j, 2);
            if sum(padsize) ~= 0
                varargin{i} = padarray(varargin{i}, padsize, kwargs.padval{i}{j}, 'post');
            end
        end
    end

    % parallel iteration
    result = cell(kwargs.numfilt, 1);
    for k = 1:kwargs.numfilt
        dataslice = cell(1, kwargs.narg);
        for i = 1:kwargs.narg   
            kernel = kwargs.kernel{i}(:,k);
            stride = kwargs.stride{i}(:,k);
            temporary = cell(1, kwargs.ndimsarg{i});
            for j = 1:kwargs.ndimsarg{i}
                temporary{j} = stride(j) + (0:kernel(j));
            end
            dataslice{i} = varargin{i}(temporary{:});
        end
        result{k} = method(dataslice{:}, k); 
    end

    if opts.usefiledatastore
        varargin = cellfun(@(x) [], varargin, UniformOutput = false);

        dsf = fileDatastore(opts.folder, FileExtensions = '.mat', ReadFcn = @ReadFcn);
        dsft = transform(dsf, @(x) {opts.method(x{1:end-1}), x{end}});

        % change pool context
        poolswitcher(poolarg{2}{:});

        switch opts.extract
            case 'readall'
                result = readall(dsft, UseParallel = opts.useparallel);
            case 'writeall'
                opts.foldersec = makefolder();
                writeall(dsft, opts.foldersec, WriteFcn = @WriteFcn, ...
                    UseParallel = opts.useparallel, ...
                    FolderLayout = 'flatten');

                dsfr = fileDatastore(opts.foldersec, FileExtensions = '.mat', ReadFcn = @ReadFcn);
                dsft = transform(dsfr, @(x) {x{1:end-1}, x{end}});

                result = readall(dsft, UseParallel = opts.useparallel);

                % remove datastore folders
                cellfun(@(x) rmdir(x, 's'), dsfr.Folders);
        end
        
        % remove datastore folders
        cellfun(@(x) rmdir(x, 's'), dsf.Folders);
        
        % soft filter iteration
        [~, index] = sort(cell2mat(result(:, end)));
        result = result(index, 1:end-1);
    end

    switch opts.ans
        case 'array'
            tf = isscalar(result);
            result = cell2arr(result);
            if isvector(result)
                shape = kwargs.szfilt;
            else
                szout = size(result);
                if ~tf; szout = szout(1:end-1); end
                shape = [szout, kwargs.szfilt];
            end
            result = squeeze(reshape(result, shape));
    end

    if opts.verbose; disp(strcat("nonlinfilt: elapsed time is ", num2str(toc(timer)), " seconds")); end

end

function y = matfilesaveker(folder, varargin)
    save(fullfile(folder, strcat('part', num2str(varargin{end}), '.mat')), 'varargin')
    y = [];
end

function y = ReadFcn(x)
    y = struct2cell(load(x));
    y = y{:};
end

function WriteFcn(data, writeInfo, ~)
    save(writeInfo.SuggestedOutputName, 'data')
end

function folder = makefolder()
    folder = fullfile(tempdir, strrep(string(datetime), ':', '-'));
    if isfolder(folder); rmdir(folder, 's'); end
    mkdir(folder)
end