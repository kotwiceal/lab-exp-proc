function varargout = guicta(kwargs)
    %% Visualize CTA scanning results.
    
    arguments
        kwargs.spec {mustBeA(kwargs.spec, {'double', 'cell'})} % matrix/pase-wise array
        kwargs.x {mustBeA(kwargs.x, {'double', 'cell'})} = [] % longitudinal coordinate matrix/pase-wise array
        kwargs.y {mustBeA(kwargs.y, {'double', 'cell'})} = [] % tranversal coordinate matrix/pase-wise array
        kwargs.f (1,:) double = []
        kwargs.intspec {mustBeA(kwargs.intspec, {'double', 'function_handle'})} = []
        kwargs.amp {mustBeA(kwargs.amp, {'double', 'cell'})} = []
        kwargs.freqrange (1,:) double = []
        %% roi parameters
        kwargs.axtarget (1,:) double = [] % order of targer ROI axis
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = [] % predefined position of ROI markers
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % interaction behaviour of ROI instances
        kwargs.number (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.number, 1)} = 1 % number of ROI instances
        %% axis parameters
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
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.legend logical = false % show legend
        kwargs.docked logical = false % docker figure
        kwargs.colormap (1,:) char = 'turbo' % colormap
        kwargs.colorbar (1,1) logical = true % show colorbar
        kwargs.fontsize (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.fontsize, 1)} = 10 % axis font size
        kwargs.aspect (1,:) {mustBeA(kwargs.aspect, {'char', 'cell'}), mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        % legend location
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = [] % figure global title
        kwargs.filename (1,:) char = [] % filename of storing figure
        kwargs.extension (1,:) char = '.png' % extention of storing figure
    end

    if isa(kwargs.spec, 'double'); kwargs.spec = {kwargs.spec}; end
    if isempty(kwargs.f); for i = 1:numel(kwargs.spec); kwargs.f{i} = 1:size(kwargs.spec{i}, 1); end; end
    if isa(kwargs.f, 'double'); kwargs.f = repmat({kwargs.f}, 1, numel(kwargs.spec)); end
    df = kwargs.f{1}(2)-kwargs.f{1}(1);
    freq2ind = @(ind) kwargs.f{1}>=ind(1)&kwargs.f{1}<=ind(2);
    if isempty(kwargs.intspec); kwargs.intspec = @(spec, freq) reshape(sqrt(abs(df*sum(spec(freq2ind(freq), :)))), [], size(kwargs.spec, 2:ndims(kwargs.spec))); end
    
    % initiate amplitude cell array
    if isempty(kwargs.amp)
        % full frequency range
        if isempty(kwargs.freqrange); kwargs.freqrange = [1, size(kwargs.spec{1}, 1)]; end
        procamp();
    end
    
    xi = ones(1, kwargs.number); yi = ones(1, kwargs.number); rois = {}; roisrect = {}; pltfunc = {}; kwargs.specpoint = {};
    if isa(kwargs.amp, 'double'); kwargs.amp = {kwargs.amp}; end
    if isa(kwargs.x, 'double'); kwargs.x = repmat({kwargs.x}, 1, numel(kwargs.amp)); end
    if isa(kwargs.y, 'double'); kwargs.y = repmat({kwargs.y}, 1, numel(kwargs.amp)); end
    if numel(kwargs.amp) ~= numel(kwargs.f); error('amp and f must be cell array same size'); end
    if isa(kwargs.mask, 'double'); kwargs.mask = repmat({kwargs.mask}, 1, numel(kwargs.amp)); end
    if numel(kwargs.amp) ~= numel(kwargs.mask); error('kwargs.amp and mask must be cell array same size'); end
    initflag = true;

    % create plot handles
    initplotfunc();

    % create figure and redefine appearance paremeter
    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow'); colormap(kwargs.colormap);
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
    for i = 1:numel(pltfunc); ax{i} = nexttile; end

    % create axis
    axpoint = nexttile; hold(axpoint, 'on'); box(axpoint, 'on'); grid(axpoint, 'on'); 
    xlim(axpoint, [min(kwargs.f{1}), max(kwargs.f{1})]);

    % plot data
    plotdata();
    % initialize point roi
    initpointrois();
    eventpointmoved();

    % store figure
    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

    varargout{1} = @() getdata();

    %% functions

    function procamp()
        %% process amplitude by given frequency range
        for i = 1:numel(kwargs.spec)
            kwargs.amp{i} = kwargs.intspec(kwargs.spec{i}, kwargs.freqrange);
        end
    end

    function eventrectmoved(~, ~)
        %% event of interactive frequency range selection
        kwargs.freqrange = [roisrect{1}.Position(1), roisrect{1}.Position(1)+roisrect{1}.Position(3)];
        temp = get(axpoint, 'YLim'); 
        roisrect{1}.Position = [roisrect{1}.Position(1), temp(1), roisrect{1}.Position(3), temp(2)-temp(1)];
        procamp()
        initplotfunc();
        plotdata();
        initpointrois();
    end

    function eventpointmoving(~, ~)
        %% binding to nodes
        for j = 1:numel(rois)
            for i = 1:numel(rois{j})
                if rois{j}{i}.Position ~= kwargs.mask{j}{i}
                    [~, indt] = min(abs(kwargs.x{j}-rois{j}{i}.Position(1)).*abs(kwargs.y{j}-rois{j}{i}.Position(2)), [], 'all');
                    [yi(i,j), xi(i,j)] = ind2sub(size(kwargs.amp{j}, [1, 2]), indt);
                    rois{j}{i}.Position = [kwargs.x{j}(yi(i,j),xi(i,j)), kwargs.y{j}(yi(i,j),xi(i,j))];
                    kwargs.mask{j}{i} = rois{j}{i}.Position;
                end
            end
        end
    end

    function eventpointmoved(~, ~)
        %% plot spectra
        cla(axpoint); hold(axpoint, 'on'); box(axpoint, 'on'); grid(axpoint, 'on');
        set(axpoint, XScale = kwargs.xscale, YScale = kwargs.yscale, FontSize = kwargs.fontsize);
        kwargs.specpoint = cell(1, numel(rois));
        for i = 1:numel(rois)
            kwargs.specpoint{i} = cell(1, numel(rois{i}));
            for j = 1:numel(rois{i})
                kwargs.specpoint{i}{j} = squeeze(kwargs.spec{i}(:,yi(j,i),xi(j,i),:));
                plot(axpoint, kwargs.f{i}, kwargs.specpoint{i}{j})
            end
        end
        if ~isempty(kwargs.mxlabel); xlabel(axpoint, kwargs.mxlabel); end
        if ~isempty(kwargs.mylabel); ylabel(axpoint, kwargs.mylabel); end
        if ~isempty(kwargs.mxlim); xlim(axpoint, kwargs.mxlim); end
        if ~isempty(kwargs.mylim); xlim(axpoint, kwargs.mylim); end
        if ~isempty(kwargs.displayname); legend(axpoint, kwargs.mdisplayname, Location = kwargs.location); end
        xlim(axpoint, [min(kwargs.f{1}), max(kwargs.f{1})]);
        initrecroi();
    end

    function initplotfunc()
        %% initialize plot functions
        pltfunc = {};
        for i = 1:numel(kwargs.amp)
            if isempty(kwargs.x{i}) && isempty(kwargs.y{i})
                if ismatrix(kwargs.amp{i})
                    [kwargs.x{i}, kwargs.y{i}] = meshgrid(1:size(kwargs.amp{i}, 2), 1:size(kwargs.amp{i}, 1));
                    pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}, kwargs.y{i}, kwargs.amp{i}, 100, 'LineStyle', 'None')});
                else
                    kwargs.x{i} = zeros(size(kwargs.amp{i})); kwargs.y{i} = zeros(size(kwargs.amp{i}));
                    for j = 1:size(kwargs.amp{i}, 3)
                        [kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j)] = meshgrid(1:size(kwargs.amp{i}, 2), 1:size(kwargs.amp{i}, 1));
                        pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j), kwargs.amp{i}(:,:,j), 100, 'LineStyle', 'None')});
                    end
                end
            else
                if ismatrix(kwargs.x{i}) && ismatrix(kwargs.y{i}) && ismatrix(kwargs.amp{i})
                    pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}, kwargs.y{i}, kwargs.amp{i}, 100, 'LineStyle', 'None')});
                else
                    if ismatrix(kwargs.x{i}) && ismatrix(kwargs.y{i}) && ~ismatrix(kwargs.amp{i})
                        sz = [size(kwargs.x{i}), size(kwargs.y{i})];
                        if numel(unique(sz)) == ndims(kwargs.x{i})
                            for j = 1:size(kwargs.amp{i}, 3)
                                pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}, kwargs.y{i}, kwargs.amp{i}(:,:,j), 100, 'LineStyle', 'None')});
                            end
                        else
                            error('x and y must be have same size')
                        end
                    end
    
                    if ~ismatrix(kwargs.x{i}) && ~ismatrix(kwargs.y{i}) && ~ismatrix(kwargs.amp{i})
                        sz = [size(kwargs.x{i}), size(kwargs.y{i}), size(kwargs.amp{i})];
                        if numel(unique(sz)) == ndims(kwargs.x{i})
                            for j = 1:size(kwargs.amp{i}, 3)
                                pltfunc = cat(1, pltfunc, {@(ax) contourf(ax, kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j), kwargs.amp{i}(:,:,j), 100, 'LineStyle', 'None')});
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
            pltfunc{i}(ax{i}); 
            set(ax{i}, FontSize = kwargs.fontsize);
            if ~isempty(kwargs.aspect); axis(ax{i}, kwargs.aspect{i}); end
            if ~isempty(kwargs.xlim{i}); xlim(ax{i}, kwargs.xlim{i}); end
            if ~isempty(kwargs.ylim{i}); ylim(ax{i}, kwargs.ylim{i}); end
            if ~isempty(kwargs.clim{i}); clim(ax{i}, kwargs.clim{i}); end
            if ~isempty(kwargs.xlabel); xlabel(ax{i}, kwargs.xlabel{i}); end
            if ~isempty(kwargs.ylabel); ylabel(ax{i}, kwargs.ylabel{i}); end
            if ~isempty(kwargs.displayname); title(ax{i}, kwargs.displayname{i}, 'FontWeight', 'Normal'); end
            if kwargs.colorbar; clb = colorbar(ax{i}); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel{i}); end; end
        end
    end

    function initpointrois()
        %% initialize point roi
        if isempty(kwargs.axtarget)
            kwargs.axtarget(1) = 1;
            for i = 1:numel(kwargs.amp)-1
                kwargs.axtarget(i+1) = kwargs.axtarget(i) + size(kwargs.amp{i}, 3);
            end
        end
        rois = {};
        for i = 1:numel(kwargs.axtarget)
            temp = guiselectregion(ax{kwargs.axtarget(i)}, moving = @eventpointmoving, moved = @eventpointmoved, shape = 'point', ...
                mask = kwargs.mask{i}, interaction = kwargs.interaction, number = kwargs.number);
            rois = cat(2, rois, {temp});
        end
        for i = 1:numel(rois)
            if isempty(kwargs.mask{i}); kwargs.mask{i} = cell(1,numel(rois{i})); end
            if isa(kwargs.mask{i}, 'double'); kwargs.mask{i} = {kwargs.mask{i}}; end
            if initflag
                for j = 1:numel(rois{i})
                    kwargs.mask{i}{j} = [nan, nan];
                end
            end
        end
        initflag = false;
        eventpointmoving(); 
    end

    function initrecroi()
        %% initialize rectangle roi
        temp = get(axpoint, 'YLim'); 
        roisrect = guiselectregion(axpoint, moved = @eventrectmoved, shape = 'rect', ...
            mask = [kwargs.freqrange(1), temp(1), kwargs.freqrange(2)-kwargs.freqrange(1), temp(2)-temp(1)], interaction = kwargs.interaction, number = 1);
        eventrectmoved();
    end

    function result = getdata()
        result.amp = kwargs.amp;
        result.spec = kwargs.specpoint;
        result.mask = kwargs.mask;
    end

end