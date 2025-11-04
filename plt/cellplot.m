function [plts, axs, rois] = cellplot(plotname, varargin, popt, pax, pset, pclb, plgd, plin, proi)
    arguments (Input)
        plotname {mustBeMember(plotname, {'plot', 'contour', 'contourf', 'imagesc', 'surf'})}
    end
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'double', 'cell'})}
    end
    arguments (Input)
        popt.axpos (1,:) double = []
        popt.docked (1,1) logical = false
        popt.figstand (1,1) logical = false
        % axis properties
        pax.axis {mustBeMember(pax.axis, {'tight', 'normal', 'manual', 'padded', 'tickaligned', ...
            'auto', 'auto x', 'auto y', 'auto xy', 'fill', 'equal', 'image', 'square', 'vis3d', ...
            'auto', 'auto z', 'auto xz', 'auto yz'})} = 'auto'
        pax.xscale {mustBeMember(pax.xscale, {'linear', 'log'})} = 'linear'
        pax.yscale {mustBeMember(pax.yscale, {'linear', 'log'})} = 'linear'
        pax.zscale {mustBeMember(pax.zscale, {'linear', 'log'})} = 'linear'
        pax.xlabel (1,:) {mustBeA(pax.xlabel, {'char', 'string', 'cell'})} = ''
        pax.ylabel (1,:) {mustBeA(pax.ylabel, {'char', 'string', 'cell'})} = ''
        pax.zlabel (1,:) {mustBeA(pax.zlabel, {'char', 'string', 'cell'})} = ''
        pax.xlim (1,:) {mustBeA(pax.xlim, {'double', 'char', 'string', 'cell'})} = 'auto'
        pax.ylim (1,:) {mustBeA(pax.ylim, {'double', 'char', 'string', 'cell'})} = 'auto'
        pax.zlim (1,:) {mustBeA(pax.zlim, {'double', 'char', 'string', 'cell'})} = 'auto'
        pax.clim (1,:) {mustBeA(pax.clim, {'double', 'char', 'string', 'cell'})} = 'auto'
        pax.grid {mustBeMember(pax.grid, {'on', 'off'})} = 'on'
        pax.box {mustBeMember(pax.box, {'on', 'off'})} = 'on'
        pax.pbaspect (1,3) double = [1,1,1];
        pax.hold {mustBeMember(pax.hold, {'on', 'off'})} = 'on'
        pax.colormap {mustBeMember(pax.colormap, {'parula','turbo','hsv','hot','cool','spring','summer','autumn',...
            'winter','gray','bone','copper','pink','sky','abyss','jet','lines','colorcube','prism','flag','white'})} = 'turbo'
        pax.xticks (1,:) = 'auto'
        pax.yticks (1,:) = 'auto'
        pax.zticks (1,:) = 'auto'
        pax.xticklabels (1,:) = 'auto'
        pax.yticklabels (1,:) = 'auto'
        pax.zticklabels (1,:) = 'auto'
        pax.xtickangle (1,1) double = 0;
        pax.ytickangle (1,1) double = 0;
        pax.ztickangle (1,1) double = 0;
        pax.fontname = 'default'
        pax.title (1,:) {mustBeA(pax.title, {'char', 'string', 'cell'})} = ''
        pax.subtitle (1,:) {mustBeA(pax.subtitle, {'char', 'string', 'cell'})} = ''
        pax.colororder {mustBeMember(pax.colororder, {'gem', 'gem12', ...
            'glow', 'glow12', 'sail', 'reef', 'meandow', 'dye', 'earth'})} = 'gem'
        pax.linestyleorder {mustBeMember(pax.linestyleorder, {'mixedstyles', 'mixedmarkers'})} = 'mixedstyles'
        % `set(ax,...)` properties
        pset.layer {mustBeMember(pset.layer, {'bottom', 'top'})} = 'top'
        pset.colorscale {mustBeMember(pset.colorscale, {'linear', 'log'})} = 'linear'
        % colobar properties
        pclb.colorbar {mustBeMember(pclb.colorbar, {'on', 'off'})} = 'off'
        pclb.clabel {mustBeA(pclb.clabel, {'char', 'string', 'cell'})} = ''
        pclb.clocation {mustBeMember(pclb.clocation, {'north', 'south', 'east', ...
            'west', 'northoutside', 'southoutside', 'eastoutside', 'westoutside', 'manual', ...
            'layout'})} = 'eastoutside'
        pclb.corientation {mustBeMember(pclb.corientation, {'vertical', 'horizontal'})} = 'vertical'
        pclb.cinterpreter {mustBeMember(pclb.cinterpreter, {'latex', 'tex', 'none'})} = 'tex'
        pclb.cexponent (1,1) double = 0
        % legend properties
        plgd.legend {mustBeMember(plgd.legend, {'on', 'off'})} = 'off'
        plgd.ltitle {mustBeA(plgd.ltitle, {'char', 'string', 'cell'})} = ''
        plgd.llocation {mustBeMember(plgd.llocation, {'north','south','east','west', ...
            'northeast','northwest','southeast','southwest','northoutside','southoutside', ...
            'eastoutside','westoutside','northeastoutside','northwestoutside', ...
            'southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        plgd.lorientation {mustBeMember(plgd.lorientation , {'vertical', 'horizontal'})} = 'vertical'
        plgd.linterpreter {mustBeMember(plgd.linterpreter , {'latex', 'tex', 'none'})} = 'tex'
        % line properties
        plin.cyclingmethod {mustBeMember(plin.cyclingmethod, {'withcolor', 'beforecolor', 'aftercolor'})} = 'withcolor'
        plin.linestyle {mustBeMember(plin.linestyle, {'-', '--', ':', '-.', 'none'})} = '-'
        plin.levels (1,:) double = []
        plin.labelcolor (1,:) double = []
        % plin.displayname (1,:) = []
        % roi properties
        proi.draw {mustBeMember(proi.draw, {'none', 'drawpoint', 'drawline', ...
            'drawrectangle', 'drawpolygon', 'drawpolyline', 'drawxrange', 'drawyrange'})} = 'none'
        proi.target (1,:) = []
        proi.number (1,:) = []
    end
    %% plot

    if ~isa(plotname, 'cell'); plotname = {plotname}; end
    if isscalar(plotname) & isa(varargin{1}, 'cell'); plotname = repmat(plotname, 1, numel(varargin{1})); end
    plt = struct(plot = 1, contour = 2, contourf = 2, imagesc = 2, surf = 2);
    dims = cellfun(@(p) plt.(p), plotname);

    pltfunc = cellfun(@(p) str2func(p), plotname, UniformOutput = false);

    % parse data
    [data, dg] = wraparrbycell(varargin{:}, dims = dims);
    dgn = splitapply(@numel, dg, dg);

    % create data-axis map 
    ag = zeros(1, numel(data));
    if isempty(popt.axpos); popt.axpos = zeros(1, numel(dgn)); end
    for i = 1:numel(popt.axpos)
        ind = i == dg;
        if isnan(popt.axpos(i))
            ag(ind) = (1:dgn(i)) + max(ag);
        else
            if popt.axpos(i) == 0
                ag(ind) = 1 + max(ag);
            else
                ag(ind) = popt.axpos(i);
            end
        end
    end

    [dg; ag];

    % create axes
    if popt.docked; fig = figure(WindowStyle = 'docked'); else; clf; fig = gcf; end
    tl = tiledlayout(fig, 'flow');
    axs = cellfun(@(~) nexttile(tl), num2cell(1:max(ag(:))), UniformOutput = false);

    % plot
    cellfun(@(a) hold(a,'on'), axs, UniformOutput = false)
    cellfun(@(a,d,g) {pltfunc{g}(axs{a}, d{:}), colorbar(axs{a}), legend(axs{a})}, ...
        num2cell(ag), data, num2cell(dg), UniformOutput = false);
 
    % gather axes children
    plts = setdiff(findobj('-depth',4), findobj('-depth',3), 'stable');

    %% customize
    % customize axes appearance
    % define specific name functions (`xlabel(ax, ...)` et al.)
    fax = cellfun(@(s) str2func(s), fieldnames(pax), UniformOutput = false);
    % define `set(ax, ...)` functions
    fset = cellfun(@(param) @(ax, val) set(ax, param, val), fieldnames(pset), UniformOutput = false);
    % collect functions
    fax = cell2struct(cat(1, fax, fset), cat(1, fieldnames(pax), fieldnames(pset)));
    % merge structures
    pax = cat(2, namedargs2cell(pax), namedargs2cell(pset));
    pax = cell2struct(pax(2:2:end), pax(1:2:end), 2);
    cellapply(axs, fax, pax)

    % customize colorbars appearance
    fclb = pclb;
    fclb.colorbar = @(obj, value) set(obj, 'Visible', value);
    fclb.clabel = @(obj, value) set(obj.Label, 'String', value);
    fclb.clocation = @(obj, value) set(obj, 'Location', value);
    fclb.corientation = @(obj, value) set(obj, 'Orientation', value);
    fclb.cinterpreter = @(obj, value) set(obj.Label, 'Interpreter', value);
    fclb.cexponent = @(obj, value) set(obj.Ruler, 'Exponent', value, 'TickLabelFormat', '%0.1f');
    cellapply(num2cell(findobj(fig, 'Type', 'ColorBar')), fclb, pclb)

    % customize legends appearance
    flgd = plgd;
    flgd.legend = @(obj, value) set(obj, 'Visible', value);
    flgd.ltitle = @(obj, value) set(obj.Title, 'String', value);
    flgd.llocation = @(obj, value) set(obj, 'Location', value);
    flgd.lorientation = @(obj, value) set(obj, 'Orientation', value);
    flgd.linterpreter = @(obj, value) set(obj, 'Interpreter', value);
    cellapply(num2cell(findobj(fig, 'Type', 'Legend')), flgd, plgd)

    % customize line
    fcond = @(obj, param, value) teropf(isempty(value), [], @() set(findobj(obj.Children, '-property', param), param, value));
    % temp = @(obj, param, value) cellfun(@(c,d) set(c, param, d), num2cell(findobj(obj.Children, '-property', param)), value(:));
    % fcond2 = @(obj, param, value) teropf(isempty(value), [], @() temp(obj, param, value));
    fplin = plin;
    fplin.cyclingmethod = @(obj, cyclingmethod) set(obj, LineStyleCyclingMethod = cyclingmethod);
    fplin.linestyle = @(obj, value) fcond(obj, 'LineStyle', value);
    fplin.levels = @(obj, value) fcond(obj, 'LevelList', value);
    fplin.labelcolor = @(obj, value) fcond(obj, 'LabelColor', value);
    % fplin.displayname = @(obj, value) fcond2(obj, 'Displayname', value);
    cellapply(axs, fplin, plin)

    %% roi
    if ~strcmp(proi.draw, "none")
        if ~isa(proi.draw, 'cell'); proi.draw = {proi.draw}; end
        rois = cellfun(@(target, draw) guiroi(plts(target), draw), ...
            num2cell(proi.target), proi.draw, UniformOutput = false);
    else
        rois = [];
    end

    %% convert tiles to standalone figures
    if popt.figstand
        hax = findobj(fig, 'type', 'axes');
        hclb = findobj(fig, 'type', 'colorbar');
        for i = 1:length(hax)
            if popt.docked; f = figure(WindowStyle = 'docked'); else; f = figure; end
            if i <= numel(hclb)
                obj = [hclb(i), hax(i)];
            else
                obj = [hax(i)];
            end
            copyobj(obj, f)
            set(gca, Units = 'normalized', Position = [0.1 0.2 0.7 0.6])
        end
        delete(fig)
    end

end

function cellapply(objs, hdls, params)
    [funcs, params] = parseargs(numel(objs), params);
    funcs = cellfun(@(func) cellfun(@(f) hdls.(f), func, ...
        UniformOutput = false), funcs, UniformOutput = false);
    cellfun(@(obj,func,param) cellfun(@(f,p) f(obj,p{:}), func(:), param(:), UniformOutput = false), ...
        objs(:), funcs(:), params(:), UniformOutput = false)
end