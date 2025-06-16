function varargout = guipointdist(data, marker, kwargs)
    %% Interactive visualization 1D data by given marker on 2D field.
    
    %% Examples:
    %% 1. Visualize 2D fields and plot 1D data by corresponding marker with subscript [5, 6]
    % % ndim(spec) = = ndim(intlotspec) + 1
    % % size(spec) = [1d data, x-axis, y-axis, case]
    % % size(intlotspec) = [x-axis, y-axis, case]
    % % node mode
    % guipointdist(data = intlotspec, point = spec, displayname = {'dbd', 'ref.'}, aspect = 'image', mask = [5, 7])
    % % spatial mode: size(x) = size(intlotspec, [1, 2]); size(y) = size(intlotspec, [1, 2]);
    % guipointdist(data = intlotspec, point = spec, displayname = {'dbd', 'ref.'}, aspect = 'image', mask = [5, 7], x = x, y = y)

    arguments
        data {mustBeA(data, {'numeric', 'cell'})} % matrix/page-wise array
        marker {mustBeA(marker, {'numeric', 'cell'})} % marker data
        kwargs.mx {mustBeA(kwargs.mx, {'numeric', 'cell'})} = [] % marker data coordinate
        kwargs.x {mustBeA(kwargs.x, {'numeric', 'cell'})} = [] % longitudinal coordinate matrix/pase-wise array
        kwargs.y {mustBeA(kwargs.y, {'numeric', 'cell'})} = [] % tranversal coordinate matrix/pase-wise array
        kwargs.mhandle (1,:) {mustBeA(kwargs.mhandle, {'double', 'function_handle'})} = []
        %% roi parameters
        kwargs.axtarget (1,:) double = [] % order of targer ROI axis
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = [] % predefined position of ROI markers
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % interaction behaviour of ROI instances
        kwargs.number (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.number, 1)} = 1 % number of ROI instances
        %% axis parameters
        kwargs.arrangement (1,:) char {mustBeMember(kwargs.arrangement, {'flow', 'vertical', 'horizontal'})} = 'flow'
        kwargs.hold (1,:) char {mustBeMember(kwargs.hold, {'on', 'off'})} = 'off'
        kwargs.grid (1,:) char {mustBeMember(kwargs.grid, {'on', 'off'})} = 'on'
        kwargs.box (1,:) char {mustBeMember(kwargs.box, {'on', 'off'})} = 'on'
        kwargs.xlim (:,:) {mustBeA(kwargs.xlim, {'double', 'cell'})} = [] % x-axis limit
        kwargs.ylim (:,:) {mustBeA(kwargs.ylim, {'double', 'cell'})} = [] % y-axis limit
        kwargs.xlabel (1,:) {mustBeA(kwargs.xlabel, {'char', 'cell'})} = {} % x-axis label of field subplot
        kwargs.ylabel (1,:) {mustBeA(kwargs.ylabel, {'char', 'cell'})} = {} % y-axis label of field subplot
        kwargs.clabel (1,:) {mustBeA(kwargs.clabel, {'char', 'cell'})} = {} % color-axis label of field subplot
        kwargs.clim (:,:) {mustBeA(kwargs.clim, {'double', 'cell'})} = [] % color-axis limit
        kwargs.displayname (1,:) {mustBeA(kwargs.displayname, {'char', 'cell'})} = {} % list of labels
        kwargs.mdisplayname string = [] % list of labels
        kwargs.mxlabel (1,:) char = [] % x-axis label of marker subplot
        kwargs.mylabel (1,:) char = [] % y-axis label of marker subplot
        kwargs.mxlim (1,:) double = [] % x-axis limit of marker subplot
        kwargs.mylim (1,:) double = [] % y-axis limit of marker subplot
        kwargs.mxscale (1,:) char {mustBeMember(kwargs.mxscale, {'linear', 'log'})} = 'log'
        kwargs.myscale (1,:) char {mustBeMember(kwargs.myscale, {'linear', 'log'})} = 'log'
        kwargs.legend logical = false % show legend
        kwargs.docked logical = false % docker figure
        kwargs.colormap (1,:) char = 'turbo' % colormap
        kwargs.colorbar (1,1) logical = true % show colorbar
        kwargs.colortype (1,:) char {mustBeMember(kwargs.colortype, {'roi', 'data'})} = 'roi'
        kwargs.fontsize (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.fontsize, 1)} = 10 % axis font size
        kwargs.aspect (1,:) {mustBeA(kwargs.aspect, {'char', 'cell'}), mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        kwargs.maspect (1,:) char {mustBeMember(kwargs.maspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        kwargs.colorbarloc (1,:) char = 'eastoutside'
        kwargs.roilabel (1,1) logical = false;
        % legend location
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = [] % figure global title
        kwargs.filename (1,:) char = [] % filename of storing figure
        kwargs.extension (1,:) char = '.png' % extention of storing figure
    end

    xi = ones(1, kwargs.number); yi = ones(1, kwargs.number); rois = {};

    if ~isa(data, 'cell'); data = {data}; end
    if ~isa(marker, 'cell'); marker = {marker}; end
    if numel(data) ~= numel(marker); error('data and marker must be cell array same size'); end
    if ~isa(kwargs.x, 'cell'); kwargs.x = repmat({kwargs.x}, 1, numel(data)); end
    if ~isa(kwargs.y, 'cell'); kwargs.y = repmat({kwargs.y}, 1, numel(data)); end
    if isempty(kwargs.mx); for i = 1:numel(marker); kwargs.mx{i} = 1:size(marker{i}, 1); end; end
    if ~isa(kwargs.mx, 'cell'); kwargs.mx = repmat({kwargs.mx}, 1, numel(data)); end
    if numel(data) ~= numel(kwargs.mx); error('data and mx must be cell array same size'); end
    if ~isa(kwargs.mask, 'cell'); kwargs.mask = repmat({kwargs.mask}, 1, numel(data)); end
    if numel(data) ~= numel(kwargs.mask); error('data and mask must be cell array same size'); end
    if isempty(kwargs.mhandle); kwargs.mhandle = @(x)x; end

    function result = getdatafunc()
        result = struct();
        temp = {}; masks = {};
        for i = 1:numel(rois)
            for j = 1:numel(rois{i})
                temp{i,j} = squeeze(marker{i}(:,yi(j,i),xi(j,i),:));
                masks{i,j} = rois{i}{j}.Position;
            end
        end
        result.data = temp;
        result.mask = masks;
        % store figure
        if ~isempty(kwargs.filename)
            savefig(gcf, strcat(kwargs.filename, '.fig'))
            exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
        end
    end

    function eventmoving(~, ~)
        % snap to nodes
        for j = 1:numel(rois)
            for i = 1:numel(rois{j})
                if rois{j}{i}.Position ~= rois{j}{i}.UserData.PreviousPosition
                    [~, indt] = min(abs(kwargs.x{j}-rois{j}{i}.Position(1)).*abs(kwargs.y{j}-rois{j}{i}.Position(2)), [], 'all');
                    [yi(i,j), xi(i,j)] = ind2sub(size(data{j}, [1, 2]), indt);
                    rois{j}{i}.Position = [kwargs.x{j}(yi(i,j),xi(i,j)), kwargs.y{j}(yi(i,j),xi(i,j))];
                    if kwargs.roilabel
                        rois{j}{i}.Label = jsonencode([yi(i,j),xi(i,j)]);
                        rois{j}{i}.LabelAlpha = 0.5;
                    end
                    rois{j}{i}.UserData.PreviousPosition = rois{j}{i}.Position;
                end
            end
        end
    end

    function eventmoved(~, ~)
        % plot 1D data
        cla(axevent); hold(axevent, 'on'); box(axevent, 'on'); grid(axevent, 'on'); axis(axevent, kwargs.maspect);
        set(axevent, XScale = kwargs.mxscale, YScale = kwargs.myscale, FontSize = kwargs.fontsize);
        for i = 1:numel(rois)
            for j = 1:numel(rois{i})
                temp = kwargs.mhandle(squeeze(marker{i}(:,yi(j,i),xi(j,i),:)));
                switch kwargs.colortype
                    case 'roi'
                        plot(axevent, kwargs.mx{i}, temp, Color = rois{i}{j}.Color)
                    case 'data'
                        plot(axevent, kwargs.mx{i}, temp)
                end
            end
        end
        if ~isempty(kwargs.mxlabel); xlabel(axevent, kwargs.mxlabel); end
        if ~isempty(kwargs.mylabel); ylabel(axevent, kwargs.mylabel); end
        if ~isempty(kwargs.mxlim); xlim(axevent, kwargs.mxlim); end
        if ~isempty(kwargs.mylim); ylim(axevent, kwargs.mylim); end
        if ~isempty(kwargs.displayname); legend(axevent, kwargs.mdisplayname, Location = kwargs.location); end
    end

    function pltfunc = initplothandl(data)
        % define plot/select function
        pltfunc = {};
        for i = 1:numel(data)
            if isempty(kwargs.x{i}) && isempty(kwargs.y{i})
                if ismatrix(data{i})
                    pltfunc = cat(1, pltfunc, {@(ax) imagesc(ax, data{i})});
                    [kwargs.x{i}, kwargs.y{i}] = meshgrid(1:size(data{i}, 2), 1:size(data{i}, 1));
                else
                    kwargs.x{i} = zeros(size(data{i})); kwargs.y{i} = zeros(size(data{i}));
                    for j = 1:size(data{i}, 3)
                        pltfunc = cat(1, pltfunc, {@(ax) imagesc(ax, data{i}(:,:,j))});
                        [kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j)] = meshgrid(1:size(data{i}, 2), 1:size(data{i}, 1));
                    end
                end
            else
                if ismatrix(kwargs.x{i}) && ismatrix(kwargs.y{i}) && ismatrix(data{i})
                    pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}, kwargs.y{i}, data{i}, 100, 'LineStyle', 'None')});
                else
                    if ismatrix(kwargs.x{i}) && ismatrix(kwargs.y{i}) && ~ismatrix(data{i})
                        sz = [size(kwargs.x{i}), size(kwargs.y{i})];
                        if numel(unique(sz)) == ndims(kwargs.x{i})
                            for j = 1:size(data{i}, 3)
                                pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}, kwargs.y{i}, data{i}(:,:,j), 100, 'LineStyle', 'None')});
                            end
                        else
                            error('x and y must be have same size')
                        end
                    end
    
                    if ~ismatrix(kwargs.x{i}) && ~ismatrix(kwargs.y{i}) && ~ismatrix(data{i})
                        sz = [size(kwargs.x{i}), size(kwargs.y{i}), size(data{i})];
                        if numel(unique(sz)) == ndims(kwargs.x{i})
                            for j = 1:size(data{i}, 3)
                                pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j), data{i}(:,:,j), 100, 'LineStyle', 'None')});
                            end
                        else
                            error('x and y must be have same size')
                        end
                    end
                end
            end
        end
    end

    function plotdata()
        for i = 1:numel(pltfunc)
            hold(ax{i}, kwargs.hold);
            pltfunc{i}(ax{i}); 
            box(ax{i}, kwargs.box); grid(ax{i}, kwargs.grid);
            set(ax{i}, FontSize = kwargs.fontsize);
            if ~isempty(kwargs.aspect); axis(ax{i}, kwargs.aspect{i}); end
            if ~isempty(kwargs.xlim{i}); xlim(ax{i}, kwargs.xlim{i}); end
            if ~isempty(kwargs.ylim{i}); ylim(ax{i}, kwargs.ylim{i}); end
            if ~isempty(kwargs.clim{i}); clim(ax{i}, kwargs.clim{i}); end
            if ~isempty(kwargs.xlabel); xlabel(ax{i}, kwargs.xlabel{i}); end
            if ~isempty(kwargs.ylabel); ylabel(ax{i}, kwargs.ylabel{i}); end
            if ~isempty(kwargs.displayname); title(ax{i}, kwargs.displayname{i}, 'FontWeight', 'Normal'); end
            if kwargs.colorbar; clb = colorbar(ax{i}, kwargs.colorbarloc); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel{i}); end; end
        end
    end

    function update(data)
        pltfunc = initplothandl(data);
        plotdata();
        initrois();
    end

    function initrois()
        % initialize ROI instances
        if isempty(kwargs.axtarget)
            kwargs.axtarget(1) = 1;
            for i = 1:numel(data)-1
                kwargs.axtarget(i+1) = kwargs.axtarget(i) + size(data{i}, 3);
            end
        end
        rois = {};
        for i = 1:numel(kwargs.axtarget)
            temp = guiselectregion(ax{kwargs.axtarget(i)}, moving = @eventmoving, moved = @eventmoved, shape = 'point', ...
                mask = kwargs.mask{i}, interaction = kwargs.interaction, number = kwargs.number);
            rois = cat(2, rois, {temp});
        end
    
        for i = 1:numel(rois)
            for j = 1:numel(rois{i})
                rois{i}{j}.UserData.PreviousPosition = [nan, nan]; 
            end
        end
        eventmoving(); eventmoved();
    end

    % create plot handles
    pltfunc = initplothandl(data);

    % create figure and redefine appearance paremeter
    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout(kwargs.arrangement, TileSpacing = 'tight'); colormap(kwargs.colormap);
    if isa(kwargs.xlabel, 'char'); kwargs.xlabel = repmat({kwargs.xlabel}, 1, numel(pltfunc)); end
    if isa(kwargs.ylabel, 'char'); kwargs.ylabel = repmat({kwargs.ylabel}, 1, numel(pltfunc)); end
    if isa(kwargs.aspect, 'char'); kwargs.aspect = repmat({kwargs.aspect}, 1, numel(pltfunc)); end
    if isa(kwargs.clabel, 'char'); kwargs.clabel = repmat({kwargs.clabel}, 1, numel(pltfunc)); end
    if isa(kwargs.xlim, 'double'); kwargs.xlim = repmat({kwargs.xlim}, 1, numel(pltfunc)); end
    if isa(kwargs.ylim, 'double'); kwargs.ylim = repmat({kwargs.ylim}, 1, numel(pltfunc)); end
    if isa(kwargs.clim, 'double'); kwargs.clim = repmat({kwargs.clim}, 1, numel(pltfunc)); end
    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    % create axis
    ax = cell(1, numel(pltfunc));
    for i = 1:numel(pltfunc)
        ax{i} = nexttile; 
    end
    
    % create aux axis
    axevent = nexttile; hold(axevent, 'on'); box(axevent, 'on'); grid(axevent, 'on');

    % plot data
    plotdata();

    initrois();

    varargout{1} = @getdatafunc;
    varargout{2} = axevent;
    varargout{3} = @update;

    % store figure
    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end

function snaphandler(src, pos, kwargs)
    arguments
        src
        pos
        kwargs.sz (1,:) double = []
    end
    switch class(src)
        case 'images.roi.Rectangle'
            curpos = src.Position;
            vertexes = [curpos(1), curpos(2); curpos(1)+curpos(3), curpos(2); ...
                curpos(1)+curpos(3), curpos(2)+curpos(4); curpos(1), curpos(2)+curpos(4)];
            k = dsearchn(pos, vertexes);
            src.UserData.linind = k;
            actvertexes = pos(k,:);
            actvertexes = sort(actvertexes, 1);
            actpos = [actvertexes(1,1), actvertexes(1,2), ...
                actvertexes(4,1)-actvertexes(1,1), actvertexes(4,2)-actvertexes(1,2)];
            src.Position = actpos;
        otherwise
            k = dsearchn(pos, src.Position);
            src.Position = pos(k,:);
            src.UserData.linind = k;
    end
    if ~isempty(kwargs.sz)
        src.UserData.subind = cell(numel(kwargs.sz), 1);
        [src.UserData.subind{:}] = ind2sub(kwargs.sz, src.UserData.linind);
    end
end