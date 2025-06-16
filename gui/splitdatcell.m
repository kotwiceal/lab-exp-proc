function varargout = splitdatcell(varargin, kwargs)
    %% Split data to cell array.

    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'numeric', 'cell'})}
    end
    arguments (Input)      
        kwargs.dims (1,:) double = [1, 2]
        kwargs.grid (1,1) logical = true
    end
    arguments (Output, Repeating)
        varargout cell
    end

    % wrap to cell
    for i = 1:nargin; if ~isa(varargin{i}, 'cell'); varargin{i} = {varargin{i}}; end; end

    data = varargin{nargin};
    temp = data; data = {};
    szd = cell(numel(temp), 1);
    for i = 1:numel(temp)
        szd{i} = size(temp{i});
        if isrow(temp{i}); temp{i} = temp{i}'; end
        temp2 = squeeze(num2cell(temp{i}, kwargs.dims));
        data = cat(1, data, temp2{:});
    end

    % generate grid
    if kwargs.grid
        if nargin == 1
            grid = cell(numel(data), 1);
            for i = 1:numel(data)
                sz = size(data{i}); szc = cell(1, ndims(data{i}));
                for j = 1:numel(szc); szc{j} = 1:sz(j); end
                temp = cell(1, ndims(data{i})); 
                [temp{:}] = ndgrid(szc{:});
                grid{i} = temp;
            end
            temp = grid; grid = cell(numel(kwargs.dims), 1);
            for i = 1:numel(kwargs.dims)
                for j = 1:numel(data)
                    grid{i} = cat(1, grid{i}, {temp{j}{i}});
                end
            end
        else
            numelin = zeros(nargin-1, 1);
            for i = 1:nargin-1; numelin(i) = numel(varargin{i}); end
            if ~isscalar(unique(numelin)); error('grid cell array must have same size'); end
    
            grid = cell(nargin-1, 1);
            % grid dims loop
            for i = 1:nargin-1
                temp = varargin{i}; 
                % slice loop
                for j = 1:numel(temp)
                    sz = size(temp{j});
                    if isrow(temp{j}); temp{j} = temp{j}'; end
                    if numel(sz) == numel(szd{j}) && ~iscolumn(temp{j})
                        if isscalar(unique(sz == szd{j}))
                            temp2 = squeeze(num2cell(temp{j}, kwargs.dims));
                        else
                            error('grid and data sizes must be same'); 
                        end
                    else
                        if ~isscalar(unique(sz(kwargs.dims) == szd{j}(kwargs.dims)))
                            error('grid and data sizes must be same'); 
                        else
                            linind = 1:numel(szd{j});
                            linind(kwargs.dims) = [];
                            sliceind = szd{j};
                            sliceind(kwargs.dims) = [];
                            repind = ones(1,numel(szd{j}));
                            repind(linind) = sliceind;
                        end
                        temp2 = squeeze(num2cell(repmat(temp{j}, repind), kwargs.dims));
                    end
                    grid{i} = cat(1, grid{i}, {temp2{:}}');
                end
            end
        end
    end

    varargout = cell(1, numel(kwargs.dims) + 1);

    for i = 1:numel(kwargs.dims)
        varargout{i} = grid{i};
    end

    varargout{numel(kwargs.dims) + 1} = data;

end