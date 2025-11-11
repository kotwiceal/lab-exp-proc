function pointprobe(plotname, varargin, popt)
    arguments (Input)
        plotname {mustBeMember(plotname, {'plot', 'contour', 'contourf', 'imagesc', 'surf', 'pcolor', 'plot3'})}
    end
    arguments (Input, Repeating)
        varargin {mustBeA(varargin, {'double', 'cell'})}
    end
    arguments (Input)
        popt.marker = 2
        popt.target = 1
        % popt.marker = []
        popt.dims = []
    end
    
    % switch nargin
    %     case 2
    %         data = varargin{1};
    %         marker = varargin{2};
    %     case 3
    % 
    % 
    % end

    % if ~isa(plotname, 'cell'); plotname = {plotname}; end
    % if isscalar(plotname) & isa(varargin{1}, 'cell'); plotname = repmat(plotname, 1, numel(varargin{1})); end
    % plt = struct(plot = 1, contour = 2, contourf = 2, imagesc = 2, surf = 2);
    % dims = cellfun(@(p) plt.(p), plotname);

    % pltfunc = cellfun(@(p) str2func(p), plotname, UniformOutput = false);

    data = {}; marker = {};
    nm = 1:numel(varargin{1}); nm(popt.marker) = [];
    for i = 1:numel(varargin)
        data{i} = varargin{i}(nm);
        marker{i} = varargin{i}(popt.marker);
    end

    addax = 1;

    [plts, axs, rois] = cellplot(plotname, data{:}, draw = 'drawpoint', addax = addax, ...
        xlabel={'x','t'},ylabel={'y','a'},number=3);

    funcs = @(r) roislicedata(r, popt.target, marker{2}{1}, popt.dims, shape = 'trim');

    axroi = axs{end-addax+1:end};
    if ~isa(axroi, 'cell'); axroi = {axroi}; end

    rois = num2cell(flip(findobj('type','images.roi.Point')));

    d = cellfun(@(r) funcs(r), rois, UniformOutput = false);

    cellfun(@(r,d) setfield(r.UserData,'index'))

    cellplot('plot', cell2arr(d), parent = axroi, customize = false);

    cellfun(@(r) addlistener(r, 'ROIMoved', @event), rois);

    function event(~, evt)
        d = funcs(evt.Source);
        cellfun(@(obj,ydata) set(obj, 'YData', ydata), ...
            num2cell(flip(axroi{1}.Children)), mat2cell(d, size(d,1), ones(1,size(d,2)))')
    end

end