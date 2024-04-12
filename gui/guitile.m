function getdata = guitile(data, kwargs)
    %% Visualize multiframe data.

    arguments
        data {mustBeA(data, {'double', 'cell'})} % matrix/pase-wise array
        kwargs.x {mustBeA(kwargs.x, {'double', 'cell'})} = [] % longitudinal coordinate matrix/pase-wise array
        kwargs.y {mustBeA(kwargs.y, {'double', 'cell'})} = [] % tranversal coordinate matrix/pase-wise array
        %% roi parameters
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'none', 'rect', 'poly'})} = 'none'
        kwargs.mask (:,:) {mustBeA(kwargs.mask, {'double', 'cell'})} = []
        kwargs.number (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.number, 1)} = 1
        %% axis parameters
        kwargs.xlim (:,:) {mustBeA(kwargs.xlim, {'double', 'cell'})} = [] % x-axis limit
        kwargs.ylim (:,:) {mustBeA(kwargs.ylim, {'double', 'cell'})} = [] % y-axis limit
        kwargs.xlabel (1,:) {mustBeA(kwargs.xlabel, {'char', 'cell'})} = {} % x-axis label of field subplot
        kwargs.ylabel (1,:) {mustBeA(kwargs.ylabel, {'char', 'cell'})} = {} % y-axis label of field subplot
        kwargs.clabel (1,:) {mustBeA(kwargs.clabel, {'char', 'cell'})} = {} % color-axis label of field subplot
        kwargs.clim (:,:) {mustBeA(kwargs.clim, {'double', 'cell'})} = [] % color-axis limit
        kwargs.displayname (1,:) {mustBeA(kwargs.displayname, {'char', 'cell'})} = {} % list of labels
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

    function result = getdatafunc()
        result = struct(data = [], mask = [], x = [], y = []);
        if kwargs.shape ~= "none"
            for i = 1:numel(rois)
                for j = 1:numel(rois{i})
                    result.data{i,j} = selecthandle{i}(rois{i}{j});
                    result.mask{i,j} = rois{i}{j}.Position;
                    result.x{i,j} = selecthandlex{i}(rois{i}{j});
                    result.y{i,j} = selecthandley{i}(rois{i}{j});
                end
            end
        end

        if ~isempty(kwargs.filename)
            savefig(gcf, strcat(kwargs.filename, '.fig'))
            exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
        end
    end

    if isa(data, 'double'); data = {data}; end
    if isa(kwargs.x, 'double') && isempty(kwargs.x); kwargs.x = repmat({kwargs.x}, 1, numel(data)); end
    if isa(kwargs.y, 'double') && isempty(kwargs.y); kwargs.y = repmat({kwargs.y}, 1, numel(data)); end

    % define plot/select function
    pltfunc = {}; selecthandle = {}; selecthandlex = {}; selecthandley = {};
    for i = 1:numel(data)
        if isempty(kwargs.x{i}) && isempty(kwargs.y{i})
            if ismatrix(data{i})
                pltfunc = cat(1, pltfunc, {@() imagesc(data{i})});
                selecthandle = cat(1, selecthandle, {@(roiobj) guigetdata(roiobj, data{i}, shape = 'raw', permute = [2, 1])});
                [kwargs.x{i}, kwargs.y{i}] = meshgrid(1:size(data{i}, 2), 1:size(data{i}, 1));
                selecthandlex = cat(1, selecthandlex, {@(roiobj) guigetdata(roiobj, kwargs.x{i}, shape = 'raw', permute = [2, 1])});
                selecthandley = cat(1, selecthandley, {@(roiobj) guigetdata(roiobj, kwargs.y{i}, shape = 'raw', permute = [2, 1])});
            else
                kwargs.x{i} = zeros(size(data{i})); kwargs.y{i} = zeros(size(data{i}));
                for j = 1:size(data{i}, 3)
                    pltfunc = cat(1, pltfunc, {@() imagesc(data{i}(:,:,j))});
                    selecthandle = cat(1, selecthandle, {@(roiobj) guigetdata(roiobj, data{i}(:,:,j), shape = 'raw')});
                    [kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j)] = meshgrid(1:size(data{i}, 2), 1:size(data{i}, 1));
                end
            end
        else
            if ismatrix(kwargs.x{i}) && ismatrix(kwargs.y{i}) && ismatrix(data{i})
                pltfunc = cat(1, pltfunc, {@() contourf(kwargs.x{i}, kwargs.y{i}, data{i}, 100, 'LineStyle', 'None')});
                selecthandle = cat(1, selecthandle, {@(roiobj) guigetdata(roiobj, data{i}, shape = 'raw', x = kwargs.x{i}, z = kwargs.y{i})});
                selecthandlex = cat(1, selecthandlex, {@(roiobj) guigetdata(roiobj, kwargs.x{i}, shape = 'raw', x = kwargs.x{i}, z = kwargs.y{i})});
                selecthandley = cat(1, selecthandley, {@(roiobj) guigetdata(roiobj, kwargs.y{i}, shape = 'raw', x = kwargs.x{i}, z = kwargs.y{i})});
            else
                if ismatrix(kwargs.x{i}) && ismatrix(kwargs.y{i}) && ~ismatrix(data{i})
                    sz = [size(kwargs.x{i}), size(kwargs.y{i})];
                    if numel(unique(sz)) == ndims(kwargs.x{i})
                        for j = 1:size(data{i}, 3)
                            pltfunc = cat(1, pltfunc, {@() contourf(kwargs.x{i}, kwargs.y{i}, data{i}(:,:,j), 100, 'LineStyle', 'None')});
                            selecthandle = cat(1, selecthandle, {@(roiobj) guigetdata(roiobj, data{i}(:,:,j), shape = 'raw', x = kwargs.x{i}, z = kwargs.y{i})});
                            selecthandlex = cat(1, selecthandlex, {@(roiobj) guigetdata(roiobj, kwargs.x{i}, shape = 'raw', x = kwargs.x{i}, z = kwargs.y{i})});
                            selecthandley = cat(1, selecthandley, {@(roiobj) guigetdata(roiobj, kwargs.y{i}, shape = 'raw', x = kwargs.x{i}, z = kwargs.y{i})});
                        end
                    else
                        error('x and y must be have same size')
                    end
                end

                if ~ismatrix(kwargs.x{i}) && ~ismatrix(kwargs.y{i}) && ~ismatrix(data{i})
                    sz = [size(kwargs.x{i}), size(kwargs.y{i}), size(data{i})];
                    if numel(unique(sz)) == ndims(kwargs.x{i})
                        for j = 1:size(data{i}, 3)
                            pltfunc = cat(1, pltfunc, {@() contourf(kwargs.x{i}(:,:,j), kwargs.y{i}(:,:,j), data{i}(:,:,j), 100, 'LineStyle', 'None')});
                            selecthandle = cat(1, selecthandle, {@(roiobj) guigetdata(roiobj, data{i}(:,:,j), shape = 'raw', x = kwargs.x{i}(:,:,j), z = kwargs.y{i}(:,:,j))});
                            selecthandlex = cat(1, selecthandlex, {@(roiobj) guigetdata(roiobj, kwargs.x{i}(:,:,j), shape = 'raw', x = kwargs.x{i}(:,:,j), z = kwargs.y{i}(:,:,j))});
                            selecthandley = cat(1, selecthandley, {@(roiobj) guigetdata(roiobj, kwargs.y{i}(:,:,j), shape = 'raw', x = kwargs.x{i}(:,:,j), z = kwargs.y{i}(:,:,j))});
                        end
                    else
                        error('x and y must be have same size')
                    end
                end
            end
        end
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow'); colormap(kwargs.colormap);
    if isa(kwargs.xlabel, 'char'); kwargs.xlabel = repmat({kwargs.xlabel}, 1, numel(pltfunc)); end
    if isa(kwargs.ylabel, 'char'); kwargs.ylabel = repmat({kwargs.ylabel}, 1, numel(pltfunc)); end
    if isa(kwargs.aspect, 'char'); kwargs.aspect = repmat({kwargs.aspect}, 1, numel(pltfunc)); end
    if isa(kwargs.clabel, 'char'); kwargs.clabel = repmat({kwargs.clabel}, 1, numel(pltfunc)); end
    if isa(kwargs.xlim, 'double'); kwargs.xlim = repmat({kwargs.xlim}, 1, numel(pltfunc)); end
    if isa(kwargs.ylim, 'double'); kwargs.ylim = repmat({kwargs.ylim}, 1, numel(pltfunc)); end
    if isa(kwargs.clim, 'double'); kwargs.clim = repmat({kwargs.clim}, 1, numel(pltfunc)); end

    % plot 2D fields
    ax = cell(1, numel(pltfunc));
    for i = 1:numel(pltfunc)
        ax{i} = nexttile; pltfunc{i}(); 
        set(gca, FontSize = kwargs.fontsize);
        if ~isempty(kwargs.aspect); axis(kwargs.aspect{i}); end
        if ~isempty(kwargs.xlim{i}); xlim(kwargs.xlim{i}); end
        if ~isempty(kwargs.ylim{i}); ylim(kwargs.ylim{i}); end
        if ~isempty(kwargs.clim{i}); clim(kwargs.clim{i}); end
        if ~isempty(kwargs.xlabel); xlabel(kwargs.xlabel{i}); end
        if ~isempty(kwargs.ylabel); ylabel(kwargs.ylabel{i}); end
        if ~isempty(kwargs.displayname); title(kwargs.displayname{i}, 'FontWeight', 'Normal'); end
        if kwargs.colorbar; clb = colorbar(); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel{i}); end; end
    end

    rois = {}; 
    if isa(kwargs.mask, 'double'); kwargs.mask = repmat({kwargs.mask}, 1, numel(ax)); end
    if kwargs.shape ~= "none"
        for i = 1:numel(ax)
            temp = guiselectregion(ax{i}, shape = kwargs.shape, ...
                mask = kwargs.mask{i}, interaction = 'all', number = kwargs.number);
            rois = cat(2, rois, {temp});
        end
        clear temp;
    end

    getdata = @getdatafunc;

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end