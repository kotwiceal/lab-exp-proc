function histprobe(dplot, dims, varargin, opt, phist, popt, pax, pset, pclb, plgd, plin, proi)
arguments (Input)
        dplot {mustBeMember(dplot, {'plot', 'contour', 'contourf', 'imagesc', 'surf', 'pcolor', 'plot3'})}
        dims
    end
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'double', 'cell'})}
    end
    arguments (Input)
        opt.dispnameroi (1,1) logical = false
        % phist.edges (1,:) {mustBeA(phist.edges, {'double', 'cell'})} = []
        % phist.binmethod {mustBeMember(phist.binmethod, {'auto', 'scott', 'fd', 'integers', 'sturges', 'sqrt'})} = 'auto'
        phist.normalization {mustBeMember(phist.normalization, {'count', ...
            'probability', 'percentage', 'countdensity', 'cumcount', 'pdf', 'cdf'})} = 'count'
        %% cellplot
        popt.parent = []
        popt.axpos (1,:) double = []
        popt.docked (1,1) logical = false
        popt.split (1,1) logical = false
        popt.merge (1,:) {mustBeA(popt.merge, {'double', 'cell'})} = [] % merge axes children to one axis
        popt.probe (1,:) double = []
        popt.addax = []
        popt.customize (1,1) logical = true
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
        pax.linestyleorder {mustBeMember(pax.linestyleorder, {'.', 'o', 's', ...
            '<', '>', '^', 'd', '*', 'mixedstyles', 'mixedmarkers'})} = 'mixedstyles'
        % `set(ax,...)` properties
        pset.layer {mustBeMember(pset.layer, {'bottom', 'top'})} = 'top'
        pset.colorscale {mustBeMember(pset.colorscale, {'linear', 'log'})} = 'linear'
        pset.tag {mustBeA(pset.tag, {'char', 'string', 'cell'})} = ''
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
        plgd.lbackgroundalpha {mustBeA(plgd.lbackgroundalpha, {'double', 'cell'})} = 1
        plgd.lnumcolumns {mustBeA(plgd.lnumcolumns, {'double', 'cell'})} = 1
        plgd.ltextcolor {mustBeA(plgd.ltextcolor, {'double', 'char', 'string', 'cell'})} = []
        plgd.ledgecolor {mustBeA(plgd.ledgecolor, {'double', 'char', 'string', 'cell'})} = []
        % line properties
        plin.cyclingmethod {mustBeMember(plin.cyclingmethod, {'withcolor', 'beforecolor', 'aftercolor'})} = 'withcolor'
        plin.linestyle {mustBeMember(plin.linestyle, {'-', '--', ':', '-.', 'none'})} = '-'
        plin.levels {mustBeA(plin.levels, {'double', 'cell'})} = []
        plin.labelcolor {mustBeA(plin.labelcolor, {'double', 'char', 'string', 'cell'})} = []
        plin.facecolor {mustBeMember(plin.facecolor, {'flat', 'interp', 'none', 'red', 'blue', 'white', 'black'})} = 'flat'
        plin.edgecolor {mustBeMember(plin.edgecolor , {'flat', 'interp', 'none', 'red', 'blue', 'white', 'black'})} = 'flat'
        plin.view {mustBeA(plin.view, {'double', 'cell'})} = [0, 90]
        plin.displayname {mustBeA(plin.displayname, {'char', 'string', 'cell'})} = ''
        plin.ltag {mustBeA(plin.ltag, {'char', 'string', 'cell'})} = ''
        % roi properties
        proi.draw {mustBeMember(proi.draw, {'none', 'drawpoint', 'drawline', ...
            'drawrectangle', 'drawpolygon', 'drawpolyline', 'drawxline', ...
            'drawyline', 'drawxrange', 'drawyrange'})} = 'none'
        proi.target (1,:) {mustBeA(proi.target, {'double', 'cell'})} = 1
        proi.number (1,:) {mustBeA(proi.number, {'double', 'cell'})} = 1
        proi.rposition {mustBeA(proi.rposition, {'double', 'cell'})} = []
        proi.rlabel {mustBeA(proi.rlabel, {'char', 'string', 'cell'})} = ''
        proi.rinteraction {mustBeMember(proi.rinteraction , {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        proi.rstripecolor = 'none'
        proi.ralpha (1,1) double = 1
        proi.rtag {mustBeA(proi.rtag, {'char', 'string', 'cell'})} = ''
        proi.rmarkersize = []
        proi.rlinewidth = []
        proi.rvisible {mustBeMember(proi.rvisible, {'on', 'off'})} = 'on'
        proi.rcolororder {mustBeMember(proi.rcolororder, {'on', 'off'})} = 'on'
        proi.rlinealign {mustBeMember(proi.rlinealign, {'on', 'off'})} = 'off'
        proi.rnumlabel {mustBeMember(proi.rnumlabel, {'on', 'off'})} = 'off'
        proi.rlabelalpha (1,1) double = 1
    end

    switch numel(varargin)
        case 2
            % Z,D
            data = varargin(1);
            probe = cat(2, {[]}, varargin(2));
        case 3
            % Z,M,D
            data = varargin(1);
            probe = varargin(2:3);
        case 4
            % X,Y,Z,D
            data = varargin(1:3);
            probe = cat(2, {[]}, varargin(4));
        case 5
            % X,Y,Z,M,D
            data = varargin(1:3);
            probe = varargin(4:5);
        otherwise
            return
    end

    args = namedargs2cell(phist);

    sarg = struct;
    sarg.plot = @(d) terop(isa(d,'cell'), 'contourf', 'plot');
    sarg.edges = probe(1);
    sarg.data = probe(end);
    sarg.funcs = @(x,f,e) f(x{:},e{:},args{:});

    num = max(structfun(@(s) terop(isa(s,'cell'), numel(s), 1), sarg));
    sarg = parseargs(num, sarg, ans = 'struct');

    probe{1} = cellfun(@(e) e(2:end)-diff(e)/2, sarg.edges, ...
        UniformOutput = false);

    edges = cellfun(@(e) e(2:end)-diff(e)/2, sarg.edges, ...
        UniformOutput = false);
    sarg.edges = cellfun(@(e) terop(isempty(e), {100}, e), sarg.edges, ...
        UniformOutput = false); 

    % medges = cell(numel(edges),1);
    % [medges{:}] = ndgrid(edges{:});


    % args = cat(2, edges, namedargs2cell(phist));
    % funcs = @(x) histcounts(x{:},args{:});
    % funcs = @(x) histcounts2(x{:},linspace(0,60),linspace(0,1));
    % funcs = @(x) histcounts2(x{:},linspace(0,60),linspace(0,1));


    % edges = edges(2:end)-diff(edges)/2;

    args = cat(2, namedargs2cell(popt), namedargs2cell(pax), namedargs2cell(pset), ...
        namedargs2cell(pclb), namedargs2cell(plgd), namedargs2cell(plin), ...
        namedargs2cell(proi));

    varargin = cat(2, data, probe);

    % varargin = cat(2, varargin(1:end-1), {edges(:)}, varargin(end));

    pplot = cellfun(@(p,d) p(d), sarg.plot, sarg.data, UniformOutput = false);
    funcs = cellfun(@(f,e,d) @(x) f(x,terop(isa(d,'cell'),@histcounts2,@histcounts),e), ...
        sarg.funcs, sarg.edges, sarg.data, UniformOutput = false);

    cellprobe(dplot,pplot,funcs,dims,varargin{:},args{:})
    
end