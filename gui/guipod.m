function varargout = guipod(varargin, kwargs)
    arguments (Repeating, Input)
        varargin
    end
    arguments (Input)
        kwargs.plot = 'contourf'    % only contourf available now
        kwargs.position {mustBeA(kwargs.position, {'double', 'cell'})} = [] 
        % polygons positions
        kwargs.number (1, :) double = inf           % expected number of polygons
        kwargs.modelist (1, :) double = [1, 2, 3, 4]   % choose which modes to show
        kwargs.xlabel {mustBeA(kwargs.xlabel, {'char', 'string', 'cell'})} = ''
        kwargs.ylabel {mustBeA(kwargs.ylabel, {'char', 'string', 'cell'})} = ''
        kwargs.clabel {mustBeA(kwargs.clabel, {'char', 'string', 'cell'})} = ''
        kwargs.ncount (:, :) double = 100 % levels contourf param for modes plot
    end
    
    if isa(kwargs.position, 'double'); kwargs.position = {kwargs.position}; end

    data = varargin;
    data{end} = data{end}(:,:,1);
    
    data = guiplot(data{:}, plot = kwargs.plot, linestyle = 'none', docked = true, ...
        aspect = 'equal', xlabel=kwargs.xlabel, ylabel=kwargs.ylabel, colorbar=true, ...
        clabel=kwargs.clabel);

    ind = zeros(size(data{end}{1}));
    
    polys = {};
    i = 1;
    while true
        try
            if isempty(kwargs.position{1})
                pol = drawpolygon();
            else
                if numel(kwargs.position) + 1 == i; break; end
                pol = drawpolygon(Position = kwargs.position{i});
            end
            ind = inpolygon(data{1}{1}, data{2}{1}, pol.Position(:, 1), pol.Position(:, 2)) | ind;
            polys{i} = pol;
            i = i + 1;
        catch
            break;
        end
    end

    cellfun(@(r) addlistener(r, 'ROIMoved', @getres), polys, UniformOutput = false);
    
    resu = getres();

    varargout{1} = @getres;
    
    function res = getres(s, e)
        ind = zeros(size(data{end}{1}));
        position = {};
        for c=1:numel(polys)
            ind = inpolygon(data{1}{1}, data{2}{1}, polys{c}.Position(:, 1), polys{c}.Position(:, 2)) | ind;
            position{c} = polys{c}.Position;
        end
        
        % data{end}{1} = data{end}{1}.*ind;

        x = varargin{end}.*ind;
        
        s = size(x);

        x = shiftdim(x, 2);
        x = x(:, :);
        x = x';

        [U, S, V] = procpod(x, s, ind);
        res = struct(position = {position}, U=U, S=S, V=V);
        
        
        for i=1:numel(kwargs.modelist)
            try delete(nexttile(i+1)); catch; end
            nexttile(i+1);
            xax = data{1}{1};
            yax = data{2}{1};
            contourf(xax, yax, U(:, :, kwargs.modelist(i)), kwargs.ncount, LineStyle="none");
            axis square;
            xlabel(kwargs.xlabel)
            ylabel(kwargs.ylabel)
            c = colorbar;
            ylabel(c, "Mode amplitude")
            title("Mode #" + int2str(kwargs.modelist(i)))
            xarr = find(sum(ind, 1)');
            zarr = find(sum(ind, 2));
            xlim([xax(1, xarr(1)), xax(1, xarr(end))])
            ylim([yax(zarr(end), 1), yax(zarr(1), 1)])
        end
    end
end