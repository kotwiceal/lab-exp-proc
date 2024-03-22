function guipointdist(field, marker, kwargs)
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
        field double % matrix/pase-wise array
        marker double % marker data
        kwargs.mx double = [] % marker data coordinate
        kwargs.x double = [] % longitudinal coordinate matrix/pase-wise array
        kwargs.y double = [] % tranversal coordinate matrix/pase-wise array
        %% roi parameters
        kwargs.axtarget (1,1) double = 1 % order of targer ROI axis
        kwargs.mask (1,:) double = [] % predefined position of ROI markers
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % interaction behaviour of ROI instances
        kwargs.number (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.number, 1)} = 1 % number of ROI instances
        %% axis parameters
        kwargs.xlim (1,:) double = [] % x-axis limit
        kwargs.ylim (1,:) double = [] % y-axis limit
        kwargs.xlabel (1,:) char = [] % x-axis label of field subplot
        kwargs.ylabel (1,:) char = [] % y-axis label of field subplot
        kwargs.clabel (1,:) char = [] % color-axis label of field subplot
        kwargs.mxlabel (1,:) char = [] % x-axis label of marker subplot
        kwargs.mylabel (1,:) char = [] % y-axis label of marker subplot
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.clim (:,:) double = [] % color-axis limit
        kwargs.displayname string = [] % list of labels
        kwargs.legend logical = false % show legend
        kwargs.docked logical = false % docker figure
        kwargs.colormap (1,:) char = 'turbo' % colormap
        kwargs.colorbar logical = true % show colorbar
        kwargs.fontsize (1,1) double = 10 % axis font size
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'equal' % axis ratio
        % legend location
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = [] % figure global title
        kwargs.filename (1,:) char = [] % filename of storing figure
        kwargs.extension (1,:) char = '.png' % extention of storing figure
    end

    xi = ones(1, kwargs.number); yi = ones(1, kwargs.number); ax = cell(1, size(field, 3));

    function eventmoving(~, ~)
        % binding to nodes
        for i = 1:length(rois)
            [~, indt] = min(abs(kwargs.x-rois{i}.Position(1)).*abs(kwargs.y-rois{i}.Position(2)), [], 'all');
            [yi(i), xi(i)] = ind2sub(size(field, [1, 2]), indt);
            rois{i}.Position = [kwargs.x(yi(i),xi(i)), kwargs.y(yi(i),xi(i))];
        end
    end

    function eventmoved(~, ~)
        % plot 1D data
        cla(axevent); hold(axevent, 'on'); box(axevent, 'on'); grid(axevent, 'on');
        set(axevent, XScale = kwargs.xscale, YScale = kwargs.yscale, FontSize = kwargs.fontsize);
        for i = 1:length(rois)
            plot(axevent, kwargs.mx, squeeze(marker(:,yi(i),xi(i),:)))
        end
        if ~isempty(kwargs.mxlabel); xlabel(axevent, kwargs.mxlabel); end
        if ~isempty(kwargs.mylabel); ylabel(axevent, kwargs.mylabel); end
        if ~isempty(kwargs.displayname); legend(axevent, kwargs.displayname); end
    end

    if isempty(kwargs.mx); kwargs.mx = 1:size(marker, 1); end

    % initialize figure
    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
    if ~isvector(kwargs.clim);  cl = kwargs.clim; else; cl = repmat(kwargs.clim, size(field, 3), 1); end
    isnode = isempty(kwargs.x) && isempty(kwargs.y);
    if isnode
        pltfunc = @(data) imagesc(data);
        [kwargs.x, kwargs.y] = meshgrid(1:size(field, 2), 1:size(field, 1));
    else
        pltfunc = @(data) contourf(kwargs.x, kwargs.y, data, 100, 'LineStyle', 'None');
    end

    % plot 2D data
    for i = 1:size(field, 3)
        ax{i} = nexttile; pltfunc(field(:,:,i));
        colormap(kwargs.colormap);
        if ~isempty(cl); clim(cl(i,:)); end
        if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
        if kwargs.colorbar
            clb = colorbar();
            if ~isempty(kwargs.clabel)
                ylabel(clb, kwargs.clabel);
            end
        end
        axis(kwargs.aspect); set(gca, FontSize = kwargs.fontsize);
        if ~isempty(kwargs.xlabel); xlabel(kwargs.xlabel); end
        if ~isempty(kwargs.ylabel); ylabel(kwargs.ylabel); end
    end
    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    % initialize ROI instances
    axevent = nexttile; hold(axevent, 'on'); box(axevent, 'on'); grid(axevent, 'on');
    rois = guiselectregion(ax{kwargs.axtarget}, moving = @eventmoving, moved = @eventmoved, shape = 'point', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);
    eventmoving(); eventmoved();

    % store figure
    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end