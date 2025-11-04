function [stack, group, dim] = wraparrbycell(varargin, kwargs)
    %% Split array to cells.

    % sz = {2,2}
    % x1 = rand(sz{:}); y1 = rand(sz{:}); z1 = rand(sz{:});
    % x2 = rand(sz{:}); y2 = rand(sz{:}); z2 = rand(sz{:});
    % {x1,x2}, {y1,y2}, {z1,z2} -> {{x1,y1,z1},{x2,y2,z2}}, [2,2]
    % {[],x2}, {[],y2}, {z1,z2} -> {{[],[],z1},{x2,y2,z2}}, [2,2]
    % {[],x2}, {y1,y2}, {[],z2} -> {{[],y1},{x2,y2,z2}}, [1,2]
    % {x1,x2}, {[],y2}, {[],z2} -> ({{x1},{x2,y2,z2}}, [1,2]) | ({{[],[],x1},{x2,y2,z2}}, [2,2])

    % sz = {2,2,2}
    % x1 = rand(sz{:}); y1 = rand(sz{:}); z1 = rand(sz{:});
    % x2 = rand(sz{:}); y2 = rand(sz{:}); z2 = rand(sz{:});
    % {x1,x2}, {y1,y2}, {z1,z2} -> {{x1(:,:,1),y1(:,:,1),z1(:,:,1)}, {x1(:,:,2),y1(:,:,2),z1(:,:,2)}, {x2(:,:,1),y2(:,:,1),z2(:,:,1)}, {x2(:,:,2),y2(:,:,2),z2(:,:,2)}}, [2,2,2,2]

    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'numeric', 'cell'})}
    end
    arguments (Input)      
        kwargs.dims (1,:) double = []
    end
    arguments (Output)
        stack (1,:) cell
        group (1,:) double
        dim (1,:) double
    end

    % wrap to cell
    varargin = cellfun(@(v) terop(isa(v, 'cell'), v, {v}), varargin, UniformOutput = false);
    data = reshape([varargin{:}], [], nargin);
    data = cellfun(@(i) data(i,:), num2cell(1:size(data,1)), UniformOutput = false);

    stack = {}; group = []; dims = kwargs.dims; dim = [];
    if isempty(dims); dims = nan(1, numel(data)); end

    for i = 1:numel(data)
        sz = cellfun(@(x) size(x), data{i}, UniformOutput = false);
        nd = cellfun(@(x) ndims(x), data{i});
        ne = find(cellfun(@(x) ~isempty(x), data{i}));
        if isnan(dims(i)); dims(i) = nd(ne(end)); end

        % create grid
        if isscalar(ne)
            temp = cell(1, dims(i));
            szc = cellfun(@(x) 1:x, num2cell(sz{ne}), UniformOutput = false);
            [temp{:}] = ndgrid(szc{:});
            data{i} = [temp, data{i}(ne)];
        end

        % truncate empty trail cells
        ne = find(cellfun(@(x) ~isempty(x), data{i}));
        data{i} = data{i}(1:ne(end));

        % flat data
        nd = numel(data{i})-1;
        szc = cellfun(@(d) cellfun(@(s,a) terop(a <= nd, s, ones(1, s)), ...
            num2cell(size(d)), num2cell(1:ndims(d)), UniformOutput = false), ...
            data{i}, UniformOutput = false);
        temp = cellfun(@(d, s) reshape(mat2cell(d, s{:}), [], 1), data{i}, szc, UniformOutput = false);

        % repeat grid
        num = cellfun(@(x) numel(x), temp); 
        if isscalar(unique(num))
            num = ones(1, numel(num));
        else
            num(~(num(end) == num)) = num(end); num(end) = 1;
        end
        temp = cellfun(@(t, n) repmat(t, n, 1), temp, num2cell(num), UniformOutput = false);

        % wrap data
        temp = reshape([temp{:}], [], numel(data{i}));
        temp = cellfun(@(i) temp(i,:), num2cell(1:size(temp,1)), UniformOutput = false);
        group = cat(1, group, repmat(i, numel(temp), 1));
        dim = cat(1, dim, repmat(dims(i), numel(temp), 1));
        
        % stack data
        stack = cat(2, stack, temp);
    end

end