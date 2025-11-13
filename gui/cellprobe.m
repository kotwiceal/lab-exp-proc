function cellprobe(nplot, mnplot, funcs, dims, varargin, opt, popt, pax, pset, pclb, plgd, plin, proi)
    arguments (Input)
        nplot {mustBeMember(nplot, {'plot', 'contour', 'contourf', 'imagesc', 'surf', 'pcolor', 'plot3'})}
        mnplot {mustBeMember(mnplot, {'plot', 'contour', 'contourf', 'imagesc', 'surf', 'pcolor', 'plot3'})}
        funcs
        dims
    end
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'double', 'cell'})}
    end
    arguments (Input)
        opt.dispnameroi (1,1) logical = false
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
            'drawrectangle', 'drawpolygon', 'drawpolyline', 'drawxrange', 'drawyrange'})} = 'none'
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
            marker = varargin(2);
        case 3
            % Z,M,D
            data = varargin(1);
            marker = varargin(2:3);
        case 4
            % X,Y,Z,D
            data = varargin(1:3);
            marker = varargin(4);
        case 5
            % X,Y,Z,M,D
            data = varargin(1:3);
            marker = varargin(4:5);
        otherwise
            return
    end

    sarg = struct;
    sarg.plot = mnplot;
    sarg.draw = proi.draw;
    sarg.funcs = funcs;
    sarg.dims = dims;
    sarg.target = num2cell(proi.target);
    sarg.number = num2cell(proi.number);
    sarg.data = marker{end};

    num = max(structfun(@(s) terop(isa(s,'cell'), numel(s), 1), sarg));
    sarg = parseargs(num, sarg, ans = 'struct');
    
    % prepare options
    popt.addax = num; % to do axis merging by copy axis obj
    proi.draw = sarg.draw;
    proi.number = sarg.number;
    proi.target = sarg.target;
    opts = cat(2, namedargs2cell(popt), namedargs2cell(pax), namedargs2cell(pset), ...
        namedargs2cell(pclb), namedargs2cell(plgd), namedargs2cell(plin), ...
        namedargs2cell(proi));
    [~, axs, ~] = cellplot(nplot, data{:}, opts{:});

    % define axis objects for ROI handler results
    axroi = axs(end-popt.addax+1:end);

    for i = 1:num

        % define data slicing handler
        fslice = @(r) roislicedata(r, r.UserData.target, dims, sarg.data{i}, ...
            fill = 'none', shape = 'trim');
        
        func = @(r) sarg.funcs{i}(fslice(r));

        % get all ROI objects
        rois = flip(findobj(axs{1}.Parent,'type','images.roi'));
    
        % define group mask
        gr = arrayfun(@(r) r.UserData.group, rois);

        % select member of group ROI objects
        rois = rois(gr == i);

        rois = num2cell(rois);

        % set tag to ROI objects
        cellfun(@(r, t) set(r, 'Tag', strcat(num2str(i),"-",t)), rois, num2cell(string(1:numel(rois))'))

        % set handler to ROI user data
        cellfun(@(r, t) set(r, 'UserData', setfield(r.UserData, 'func', func)), rois);

        % set plot method to ROI user data
        cellfun(@(r, t) set(r, 'UserData', setfield(r.UserData, 'plot', sarg.plot{i})), rois);

        % marker = [];
        % if isscalar(marker); markerx = {[]}; else; markerx = marker{1}; end
    
        % plot ROI handler results
        cellfun(@(r,t) cellplot(sarg.plot{i}, func(r), parent = {axroi{i}}, customize = false, ltag = r.Tag), ...
            rois, UniformOutput = false);
    
        % set tags to axis childrens
        cellfun(@(r) set(r, 'UserData', setfield(r.UserData, 'plt', findobj(axroi{i},'Tag',r.Tag))), rois);
    
        % set display name according to ROI label property
        if opt.dispnameroi; cellfun(@(r) arrayfun(@(p) set(p, 'DisplayName', r.Label), r.UserData.plt), rois); end
    
        % register event
        cellfun(@(r) addlistener(r, 'ROIMoved', @event), rois);

    end

    function event(~, evt)
        roi = evt.Source;
        d = roi.UserData.func(roi);
        switch roi.UserData.plot
            case 'plot'
                d = d(:,:); d = mat2cell(d, size(d,1), ones(1,size(d,2)));
                cellfun(@(plt,d) set(plt, 'YData', d), num2cell(roi.UserData.plt)', d);
            otherwise
                d = d(:,:,:); d = mat2cell(d, size(d,1), size(d,2), ones(1,size(d,3)));
                cellfun(@(plt,d) set(plt, 'ZData', d), num2cell(roi.UserData.plt)', d);
        end
    end
    
end