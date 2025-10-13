function varargout = plotn(varargin, kwargs, axargs)
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'numeric', 'cell'})}
    end
    
    arguments (Input)
        kwargs.plot {mustBeMember(kwargs.plot, {'plot', 'imagesc', 'contour', 'contourf', 'mesh'})} = 'plot'
        kwargs.dims (1,:) {mustBeInteger, mustBePositive} = []
        kwargs.ax {mustBeMember(kwargs.ax, {'1-1', '1-n'})} = '1-1' % figure-subplot
        kwargs.tile2fig (1,1) logical = false % convert tiles to standalone figures
        kwargs.roi {mustBeMember(kwargs.roi, {'1-1', '1-n'})} = '1-1'
    end

    arguments (Input)
        axargs.fontsize = {10, 'pixel'};
        axargs.set = {'colorscale', 'linear', 'LineStyleCyclingMethod', 'aftercolor', ...
            'LineStyleOrder', '-', 'LineStyleOrderIndex', 1};
        axargs.axis = 'auto';
        axargs.colorscale = 'linear';
        axargs.xscale = 'linear';
        axargs.yscale = 'linear';
        axargs.zscale = 'linear';
        axargs.xlabel = '';
        axargs.ylabel = '';
        axargs.zlabel = '';
        axargs.xlim = 'auto';
        axargs.ylim = 'auto';
        axargs.zlim = 'auto';
        axargs.clim = 'auto';
        axargs.grid = 'on';
        axargs.box = 'on';
        axargs.pbaspect = [1,1,1];
        axargs.hold = 'on';
        axargs.colormap = 'turbo';
        axargs.xticks = 'auto';
        axargs.yticks = 'auto';
        axargs.zticks = 'auto';
        axargs.xticklabels = 'auto';
        axargs.yticklabels = 'auto';
        axargs.zticklabels = 'auto';
        axargs.xtickangle = 0;
        axargs.ytickangle = 0;
        axargs.ztickangle = 0;
        axargs.fontname = 'default';
        axargs.legend = {'show', false}
        axargs.colorbar = {'show', false}
        axargs.colororder = 'gem'
    end
    
    arguments (Output, Repeating)
        varargout
    end

    if isempty(kwargs.dims)
        switch kwargs.plot
            case 'plot'
                kwargs.dims = 1;
            otherwise
                kwargs.dims = [1, 2];
        end
    end

    kwargs.dims = [1, 2];

    % parse data to cell array
    data = cell(numel(kwargs.dims) + 1, 1);
    [data{:}] = gridcellargs(varargin{:}, dims = kwargs.dims);

    % prepare axarg
    nestparamlist = cellstr(["fontsize", "set", "legend", "colorbar"]);
    % cellfun(@(s) assignin('caller', 'axargs', sprintf('setfield(axargs, %s, {axargs.(%s)})', s, s)), nestparamlist)

    % prepare function handlers
    funcs = cellfun(@(s) str2func(s), fieldnames(axargs), UniformOutput = false);
    funcs = cell2struct(funcs,fieldnames(axargs));
    funcs.colorscale = @(ax,val) set(ax, colorscale = val);
    funcs.legend = @(varargin) handle_legend(varargin{1}, varargin{2:end});
    funcs.colorbar = @(varargin) handle_colorbar(varargin{1}, varargin{2:end});
    funcnames = string(fieldnames(funcs));

    % parse arguments
    [axfuncx, axparams] = parseargs(axnum, axargs);

    % replace custom function handlers
    axfuncx = cellfun(@(axfunc) cellfun(@(f) ...
        terop(strcmp(f,funcnames),str2func(f),funcs.(f)), axfunc, ...
        UniformOutput = false), axfuncx, UniformOutput = false);

    % plot

    % customize axes appearance
    axsu = unique(axs);
    cellfun(@(ax,axfunc,axparam) cellfun(@(f,p) f(ax,p{:}), ...
        axfunc, axparam), axsu, axfuncx, axparams)

    varargout{1} = [];

end

function varargout = gridcellargs(varargin, kwargs)
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
    varargin = cellfun(@(v) terop(isa(v,'cell'), v, {v}), varargin, UniformOutput = false);

    % data = cellfun(@(s) terop(isempty(varargin{nargin}), varargin{nargin-1}, varargin{nargin}), ...
    %     varargin{nargin-1:nargin}, UniformOutput = false);
    data = cell(numel(varargin{nargin}), 1);
    for i = 1:numel(varargin{nargin})
        data{i} = terop(isempty(varargin{nargin}{i}), varargin{nargin-1}{i}, varargin{nargin}{i});
    end

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

function handle_legend(ax, param)
    arguments
        ax matlab.graphics.axis.Axes
        param.show (1,1) logical = true
        param.title {mustBeA(param.title, {'char', 'string'})} = ''
        param.orientation {mustBeMember(param.orientation, {'vertical', 'horizontal'})} = 'vertical'
        param.location (1,:) char {mustBeMember(param.location, {'north','south','east','west', ...
            'northeast','northwest','southeast','southwest','northoutside','southoutside', ...
            'eastoutside','westoutside','northeastoutside','northwestoutside', ...
            'southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        param.displayname (1,:) {mustBeA(param.displayname, {'char', 'string', 'cell'})} = {}
        param.interpreter {mustBeMember(param.interpreter, {'latex', 'tex', 'none'})} = 'tex'
    end
    if param.show
        l = legend(ax, param.displayname, Location = param.location, ...
            Orientation = param.orientation, Interpreter = param.interpreter); 
        title(l, param.title, FontWeight = 'normal', Interpreter = param.interpreter)
    end
end

function handle_colorbar(ax, param)
    arguments
        ax matlab.graphics.axis.Axes
        param.show (1,1) logical = true
        param.clabel {mustBeA(param.clabel, {'char', 'string'})} = ''
        param.orientation {mustBeMember(param.orientation, {'vertical', 'horizontal'})} = 'vertical'
        param.location (1,:) char {mustBeMember(param.location, {'north','south','east','west', ...
            'northeast','northwest','southeast','southwest','northoutside','southoutside', ...
            'eastoutside','westoutside','northeastoutside','northwestoutside', ...
            'southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        param.Exponent (1,:) double = []
        param.cTickLabelFormat (1,:) char = '%0.1f'
        param.fontsize (1,:) double = []
        param.interpreter {mustBeMember(param.interpreter, {'latex', 'tex', 'none'})} = 'tex'
    end
    if param.show
        c = colorbar(ax, location = param.location, orientation = param.orientation);
        if ~isempty(param.Exponent)
            c.Ruler.Exponent = param.Exponent;
            c.Ruler.TickLabelFormat = param.cTickLabelFormat;  
        end
        set(c.Label, String = param.clabel, Interpreter = param.interpreter, ...
            FontSize = param.fontsize)
    end
end