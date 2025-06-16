function arrayFileDatastore(folder, varargin, opts)
    %% Split specified arrays and store data partitions.
    arguments (Input)
        folder {mustBeFolder}
    end
    arguments (Input, Repeating)
        varargin
    end
    arguments (Input)
        opts.IterationDimension (:,1) cell = {}
    end

    if isempty(opts.IterationDimension); opts.IterationDimension = cellfun(@ndims, varargin, UniformOutput = false); end

    dsa = cellfun(@(x, y) arrayDatastore(x, IterationDimension = y), varargin, opts.IterationDimension, ...
        UniformOutput = false);

    dsc = combine(dsa{:});
   
    n = numpartitions(dsc, gcp);

    parfor i = 1:n
        subds = partition(dsc, n, i);
        k = 0;
        while hasdata(subds)
            data = read(subds);
            s = struct(data = {data});
            save(fullfile(folder, strcat('part', num2str(i), '_', num2str(k), '.mat')), '-fromstruct', s)
            k = k + 1;
        end
    end

end