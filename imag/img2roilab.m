function S = img2roilab(data, kwargs)
    %% Create polygon masks by closed regions of binary images.

    arguments
        data double
        kwargs.maxVertexes (1,1) double = 40
        kwargs.filename (1,:) char = []
        kwargs.transpose (1,1) logical = true
        kwargs.table (1,1) logical = true
        kwargs.tableVarName (1,:) char = 'wedge'
    end

    if kwargs.transpose; data = pagetranspose(data); end

    sz = size(data);
    if ismatrix(data); sz(3) = 1; end

    S = cell(prod(sz(3:end)), 1);
    for i = 1:prod(sz(3:end))
        temp = bwboundaries(data(:,:,i));
        for j = 1:numel(temp)
            szt = size(temp{j});
            if szt(1) > kwargs.maxVertexes
                stepind = ceil(szt(1)/kwargs.maxVertexes);
                temp{j} = temp{j}(1:stepind:end,:);
            end
        end
        S{i,1} = temp;
    end

    if kwargs.table
        S = array2table(S, VariableNames = {kwargs.tableVarName});
    end

    if ~isempty(kwargs.filename)
        save(kwargs.filename, 'S')
    end

end