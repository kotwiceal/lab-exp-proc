function varargout = guiplot(varargin, kwargs, kwargsplt, figparam, axparamset, axparamfunc, axparamaxis, ...
    pltparam, roiparam, lgd, clb, inter)
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'numeric', 'cell'})}
    end
    arguments (Input)
        kwargs.dims (1,:) {mustBeInteger, mustBePositive} = []
        kwargs.ax {mustBeMember(kwargs.ax, {'1-1', '1-n'})} = '1-1' % figure-subplot
        kwargs.tile2fig (1,1) logical = false % convert tiles to standalone figures
        kwargs.roi {mustBeMember(kwargs.roi, {'1-1', '1-n'})} = '1-1'
        kwargsplt.plot char {mustBeMember(kwargsplt.plot, {'plot', 'imagesc', 'contour', 'contourf', 'mesh'})} = 'plot'
        kwargsplt.title {mustBeA(kwargsplt.title, {'char', 'string', 'cell'})} = ''
        kwargsplt.sgtitle (1,:) char = ''
        kwargsplt.imtileticks (1,1) logical = false 
        figparam.docked (1,1) logical = false
        figparam.arrangement {mustBeMember(figparam.arrangement, {'flow', 'vertical', 'horizontal'})} = 'flow'
        figparam.TileSpacing {mustBeMember(figparam.TileSpacing , {'loose', 'compact', 'tight', 'none'})} = 'loose'
        figparam.Padding {mustBeMember(figparam.Padding, {'loose', 'compact', 'tight'})} = 'loose'
        %% parameters for `set(ax, arg{:})`
        axparamset.xscale {mustBeMember(axparamset.xscale, {'linear', 'log'}), mustBeA(axparamset.xscale, {'char', 'cell'})} = 'linear'
        axparamset.yscale {mustBeMember(axparamset.yscale, {'linear', 'log'}), mustBeA(axparamset.yscale, {'char', 'cell'})} = 'linear'
        axparamset.zscale {mustBeMember(axparamset.zscale, {'linear', 'log'}), mustBeA(axparamset.zscale, {'char', 'cell'})} = 'linear'
        axparamset.colorscale {mustBeMember(axparamset.colorscale, {'linear', 'log'}), mustBeA(axparamset.colorscale, {'char', 'cell'})} = 'linear'
        axparamset.fontsize {mustBeInteger, mustBePositive} = 10
        %% parameters for `xlabel(ax, arg{:})` and so on
        axparamfunc.xlabel {mustBeA(axparamfunc.xlabel, {'char', 'cell'})} = ''
        axparamfunc.ylabel {mustBeA(axparamfunc.ylabel, {'char', 'cell'})} = ''
        axparamfunc.zlabel {mustBeA(axparamfunc.zlabel, {'char', 'cell'})} = ''
        axparamfunc.xlim {mustBeA(axparamfunc.xlim, {'char', 'double', 'cell'})} = 'auto'
        axparamfunc.ylim {mustBeA(axparamfunc.ylim, {'char', 'double', 'cell'})} = 'auto'
        axparamfunc.zlim {mustBeA(axparamfunc.zlim, {'char', 'double', 'cell'})} = 'auto'
        axparamfunc.clim {mustBeA(axparamfunc.clim, {'char', 'double', 'cell'})} = 'auto'
        axparamfunc.grid {mustBeMember(axparamfunc.grid, {'off', 'on'}), mustBeA(axparamfunc.grid, {'char', 'cell'})} = 'on'
        axparamfunc.box {mustBeMember(axparamfunc.box, {'off', 'on'}), mustBeA(axparamfunc.box, {'char', 'cell'})} = 'on'
        axparamfunc.pbaspect (1,3) {mustBePositive, mustBeNumeric} = [1, 1, 1]
        axparamfunc.hold {mustBeMember(axparamfunc.hold, {'off', 'on'}), mustBeA(axparamfunc.hold, {'char', 'cell'})} = 'off'
        axparamfunc.colormap {mustBeMember(axparamfunc.colormap, {'parula','turbo','hsv','hot','cool','spring','summer','autumn',...
            'winter','gray','bone','copper','pink','sky','abyss','jet','lines','colorcube','prism','flag','white'}), ...
            mustBeA(axparamfunc.colormap, {'char', 'cell'})} = 'turbo'
        axparamfunc.xticks (1,:) = 'auto'
        axparamfunc.yticks (1,:) = 'auto'
        axparamfunc.zticks (1,:) = 'auto'
        axparamfunc.xticklabels (1,:) = 'auto'
        axparamfunc.yticklabels (1,:) = 'auto'
        axparamfunc.zticklabels (1,:) = 'auto'
        axparamfunc.xtickangle (1,1) = 0
        axparamfunc.ytickangle (1,1) = 0
        axparamfunc.ztickangle (1,1) = 0
        %% parameters for `axis(ax, arg{:})`
        axparamaxis.aspect {mustBeMember(axparamaxis.aspect, {'auto', 'equal', 'image', 'square'}), mustBeA(axparamaxis.aspect, {'char', 'cell'})} = 'auto'
        axparamaxis.limits (1,:) {mustBeNumeric} = []
        %% parameters for `plot(ax, data{:}, arg{:})` and so on
        pltparam.marker {mustBeMember(pltparam.marker, {'none', 'o', 's', '<', '>', '^', 'd', '.'}), mustBeA(pltparam.marker, {'char', 'cell'})} = 'none'
        pltparam.linestyle {mustBeMember(pltparam.linestyle, {'none', '-', '--', '.-', ':'}), mustBeA(pltparam.linestyle, {'char', 'cell'})} = '-'
        pltparam.linewidth (1,1) double = 0.75
        pltparam.levels (1,:) double = 50
        pltparam.alphadata (1,1) double = 1
        pltparam.color (:,:) = []
        %% ROI parameters
        roiparam.draw {mustBeMember(roiparam.draw, {'none', 'drawpoint', 'drawline', 'drawrectangle', 'drawpolygon', 'drawpolyline'}), ...
            mustBeA(roiparam.draw, {'char', 'cell'})} = 'none'
        roiparam.target (1,:) cell = {}
        roiparam.interaction {mustBeMember(roiparam.interaction, {'all', 'none', 'translate'}), ...
            mustBeA(roiparam.interaction, {'char', 'cell'})} = 'all'
        roiparam.position (1,:) cell = {}
        roiparam.number (1,:) cell = {}
        roiparam.label {mustBeA(roiparam.label, {'char', 'cell'})} = ''
        %% `legend` parameters
        lgd.legend (1,:) logical = false
        lgd.ltitle (1,:) {mustBeA(lgd.ltitle, {'char', 'string'})} = ''
        lgd.lorientation {mustBeMember(lgd.lorientation, {'vertical', 'horizontal'})} = 'vertical'
        lgd.llocation (1,:) char {mustBeMember(lgd.llocation, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        lgd.displayname (1,:) {mustBeA(lgd.displayname, {'char', 'string', 'cell'})} = {}
        lgd.linterpreter {mustBeMember(lgd.linterpreter, {'latex', 'tex', 'none'})} = 'tex'
        %% `colorbar` parmeters
        clb.colorbar (1,:) logical = false
        clb.clabel {mustBeA(clb.clabel, {'char', 'cell'})} = ''
        clb.corientation {mustBeMember(clb.corientation, {'vertical', 'horizontal'})} = 'vertical'
        clb.clocation (1,:) char {mustBeMember(clb.clocation, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','bestoutside','layout','none'})} = 'eastoutside'
        clb.cExponent (1,:) double = []
        clb.cTickLabelFormat (1,:) char = '%0.1f'
        clb.cfontsize (1,:) = []
        clb.cinterpreter {mustBeMember(clb.cinterpreter, {'latex', 'tex', 'none'})} = 'tex'
        %% text interpreter
        inter.xinterpreter {mustBeMember(inter.xinterpreter, {'latex', 'tex', 'none'})} = 'tex'
        inter.yinterpreter {mustBeMember(inter.yinterpreter, {'latex', 'tex', 'none'})} = 'tex'
        inter.zinterpreter {mustBeMember(inter.zinterpreter, {'latex', 'tex', 'none'})} = 'tex'
        inter.tinterpreter {mustBeMember(inter.tinterpreter, {'latex', 'tex', 'none'})} = 'tex'
    end
    arguments (Output, Repeating)
        varargout
    end

    if isempty(kwargs.dims)
        switch kwargsplt.plot
            case 'plot'
                kwargs.dims = 1;
            otherwise
                kwargs.dims = [1, 2];
        end
    end

    % parse data to cell array
    data = cell(numel(kwargs.dims) + 1, 1);
    [data{:}] = splitdatcell(varargin{:}, dims = kwargs.dims);

    if figparam.docked; fg = figure(WindowStyle = 'docked'); else; clf; fg = gcf; end
    tl = tiledlayout(figparam.arrangement, TileSpacing = figparam.TileSpacing, Padding = figparam.Padding);

    switch kwargs.ax
        case '1-n'
            kwargsplt.target = nexttile(tl);
        case '1-1'
            kwargsplt.target = tl;
    end

    % prepare and combine named argumetns for axis appeariance
    temp = cellfun(@namedargs2cell, {kwargsplt, axparamset, axparamfunc, axparamaxis, pltparam, lgd, clb, inter}, UniformOutput = false);
    arg = {}; for i = 1:numel(temp); arg = cat(2, arg, temp{i}); end

    % plot data
    [plts, axs] = plotdatcell(data{:}, arg{:});

    % convert tiles to standalone figures
    if kwargs.tile2fig
        hax = findobj('type', 'axes');
        hclb = findobj('type','colorbar');
        for i = 1:length(hax)
            if figparam.docked; f = figure(WindowStyle = 'docked'); else; f = figure; end
            copyobj([hclb(i), hax(i)], f)
            set(gca, Units = 'normalized', Position = [0.1 0.2 0.7 0.6])
        end
        delete(fg)
    end

    varargout{1} = data;

    % create roi instances
    if roiparam.draw ~= "none"

        if isempty(roiparam.target); roiparam.target = {1}; end
        if isempty(roiparam.number); roiparam.number = {1}; end
        if isempty(roiparam.position); roiparam.position = {[]}; end
        
        if isa(roiparam.interaction, 'char'); roiparam.interaction = {roiparam.interaction}; end
        if isa(roiparam.label, 'char'); roiparam.label = {roiparam.label}; end
    
        if isscalar(roiparam.target); roiparam.target = repelem(roiparam.target, 1, numel(roiparam.draw)); end
        if isscalar(roiparam.number); roiparam.number = repelem(roiparam.number, 1, numel(roiparam.draw)); end
        if isscalar(roiparam.position); roiparam.position = repelem(roiparam.position, 1, numel(roiparam.draw)); end
        if isscalar(roiparam.interaction); roiparam.interaction = repelem(roiparam.interaction, 1, numel(roiparam.draw)); end
        if isscalar(roiparam.label); roiparam.label = repelem(roiparam.label, 1, numel(roiparam.draw)); end
    
        target = cell(1, numel(roiparam.target));
    
        for i = 1:numel(roiparam.target)
            if isempty(roiparam.target{i}); target{i} = axs{i}; else; target{i} = plts{roiparam.target{i}}; end
        end
        roiparam = rmfield(roiparam, 'target');

        args = namedargscomb(target, roiparam, ans = 'arg');
    
        rois = cellfun(@(arg) guiroi(arg{:}), args, UniformOutput = false);
    
        varargout{2} = rois;

    end

end