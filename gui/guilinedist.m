function getdata = guilinedist(data, kwargs)
    %% Visualize data distribution along specified lines.

    %% Examples:
    %% 1. Show distribution along horizontal projection of drawn line, 2D field is presented in spatial coordinates:
    % guilinedist(data.vmn(:,:,1), x = data.x, z = data.z);
    %% 2. Show distribution along vertical projection of drawn line, 2D field is presented in node coordinates:
    % guilinedist(data.vmn(:,:,1), proj = 'vert');
    %% 3. Show several distributions along drawn line, 2D field is presented in node coordinates:
    % guilinedist(data.vmn(:,:,1:5), proj = 'line');
    %% 4. show distribution along several drawn lines, 2D field is presented in node coordinates:
    % guilinedist(gca, data.vmn(:,:,1:5), proj = 'line', number = 3);
    %% 5. show transversal profiles averaged along CFi vortex direction 
    % res = guilinedist(data.vmn, angle = -22, x = data.x, z = data.z, proj = 'line', clim = [-0.1, 0.1], ylabel = 'u/u_e', ...
    %     mask = [250, 140, 5, 40], docked = true, shape = 'rect');
    
    arguments
        data double
        kwargs.x double = [] % spatial coordinate
        kwargs.y double = [] % spatial coordinate
        % type projection of distribution
        kwargs.proj (1,:) char {mustBeMember(kwargs.proj, {'horz', 'vert', 'line'})} = 'horz'
        kwargs.angle (1,1) double = -22 % rotation angle of selected frame
        % type of data centering
        kwargs.center (1,:) char {mustBeMember( kwargs.center, {'none', 'poly1', 'mean'})} = 'none'
        % window funtion to weight data
        kwargs.winfun char {mustBeMember(kwargs.winfun, {'none', 'hann', 'hamming', 'tukey'})} = 'none'
        kwargs.tukey (1,1) double = 1; % tukey window function parameter
        %% roi and axis parameters
        kwargs.arrangement (1,:) char {mustBeMember(kwargs.arrangement, {'flow', 'vertical', 'horizontal'})} = 'flow'
        kwargs.frame (1,:) double {mustBeInteger} = [] % position of interactive subplot
        % shape of selection tool
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'line', 'rect'})} = 'line'
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = [] % two row vertex to line selection; edge size to rectangle selection
        % region selection behaviour
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.number (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(kwargs.number, 1)} = 1 % count of selection regions
        kwargs.xlabel (1,:) char = 'x, mm' % y-axis label
        kwargs.ylabel (1,:) char = 'z, mm' % y-axis label
        kwargs.xlim (1,:) double = [] % x-axis limit
        kwargs.ylim (1,:) double = [] % y-axis limit
        kwargs.clim (1,:) double = [] % colorbar limit
        kwargs.mxlim (1,:) double = [] % x-axis limit
        kwargs.mylim (1,:) double = [] % y-axis limit
        kwargs.mxlabel (1,:) char = 'x, mm' % y-axis label
        kwargs.mylabel (1,:) char = 'intermittency' % y-axis label
        kwargs.displayname (1,:) string = [] % list of labeled curves
        kwargs.mdisplayname (1,:) = [] % list of labeled curves
        kwargs.legend (1,1) logical = false % show legend flag
        kwargs.docked (1,1) logical = false % docked figure flag
        kwargs.colormap (1,:) char = 'turbo' % colormap name
        kwargs.colorbar (1,1) logical = false
        kwargs.clabel (1,:) char = []
        % axis aspect ratio
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto', 'square', 'image'})} = 'equal'
        % legend location name
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title (1, :) char = [] % figure title
        kwargs.filename (1, :) char = [] % filename of storing figure
        kwargs.extension (1, :) char = '.png' % filename of storing figure
        kwargs.showrotframe (1,1) logical = true % supporing figure to show rotated frames
        % aspect ratio of line-distribution subplot 
        kwargs.maspect (1,:) char {mustBeMember(kwargs.maspect , {'equal', 'square', 'auto'})} = 'square'
        kwargs.fontsize (1,1) double = 14
    end

    warning off

    xi = []; zi = []; raw = []; mask = []; sz = size(data); X = [];
    if numel(sz) == 2; sz(3) = 1; end

    % define variables
    data_fit = cell(1, size(data, 3));

    % define display type   
    if isempty(kwargs.x) && isempty(kwargs.y)
        disptype = 'node'; 
        [x, y] = meshgrid(1:sz(2), 1:sz(1));
    else
        disptype = 'spatial';
        x = kwargs.x; y = kwargs.y;
    end

    % define funtion handle to probe data
    switch kwargs.shape
        case 'line'
            switch disptype
                case 'node'  
                    for j = 1:prod(sz(3:end))
                        [xi, zi] = ndgrid(1:sz(1), 1:sz(2));
                        [xo, zo, io] = prepareSurfaceData(xi, zi, data(:,:,j));
                        data_fit{j} = fit([zo, xo], io, 'linearinterp');
                    end
                case 'spatial'
                    if ismatrix(kwargs.x) && ismatrix(kwargs.y)
                        for j = 1:prod(sz(3:end))
                            [xo, zo, io] = prepareSurfaceData(kwargs.x, kwargs.y, data(:,:,j)); 
                            data_fit{j} = fit([xo, zo], io, 'linearinterp');
                        end
                    else
                        for j = 1:prod(sz(3:end))
                            [xo, zo, io] = prepareSurfaceData(kwargs.x(:,:,j), kwargs.y(:,:,j), data(:,:,j)); 
                            data_fit{j} = fit([xo, zo], io, 'linearinterp');
                        end
                    end
            end
        case 'rect'
            switch disptype
                case 'node'
                    select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', permute = [2, 1]);
                    selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', permute = [2, 1]);
                    selectz = @(roiobj) guigetdata(roiobj, y, shape = 'cut', permute = [2, 1]);
                case 'spatial'
                    select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', x = x, z = y);
                    selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', x = x, z = y);
                    selectz = @(roiobj) guigetdata(roiobj, y, shape = 'cut', x = x, z = y);
            end
    end

    % if isempty(kwargs.displayname); kwargs.legend = false; else; kwargs.legend = true; end

    function customize_appearance()
        %% change figure appearance
        if isempty(kwargs.mxlabel)
            switch disptype
                case 'node'  
                    switch kwargs.proj
                        case 'horz'
                            xlabel(ax, 'x_{n}'); ylabel(ax, 'value');
                        case 'vert'
                            xlabel(ax, 'z_{n}'); ylabel(ax, 'value');
                        case 'line'
                            switch kwargs.shape
                                case 'line'
                                    xlabel(ax, 'l_{n}'); ylabel(ax, 'value');
                                case 'rect'
                                    xlabel(ax, 'z_{n}'); ylabel(ax, 'value');
                            end
                    end
                case 'spatial'
                    switch kwargs.proj
                        case 'horz'
                            xlabel(ax, 'x, mm'); ylabel(ax, 'value');
                        case 'vert'
                            xlabel(ax, 'z, mm'); ylabel(ax, 'value');
                        case 'line'
                            switch kwargs.shape
                                case 'line'
                                    xlabel(ax, 'l, mm'); ylabel(ax, 'value');
                                case 'rect'
                                    xlabel(ax, 'z, mm'); ylabel(ax, 'value');
                            end
                    end
            end
        else
            xlabel(ax, kwargs.mxlabel);
        end
        if ~isempty(kwargs.mylabel); ylabel(ax, kwargs.mylabel); end
        if ~isempty(kwargs.mxlim); xlim(ax, kwargs.mxlim); end
        if ~isempty(kwargs.mylim); ylim(ax, kwargs.mylim); end
        if kwargs.legend; legend(ax, kwargs.mdisplayname, 'Location', kwargs.location); end
        axis(ax, kwargs.maspect)
    end

    function eventline(~, ~)
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');  set(ax, FontSize = kwargs.fontsize);
        for i = 1:length(rois)
            mask{i} = rois{i}.Position;
            xi = linspace(rois{i}.Position(1,1), rois{i}.Position(2,1));
            zi = linspace(rois{i}.Position(1,2), rois{i}.Position(2,2));
            X = []; raw = [];
            for j = 1:prod(sz(3:end))
                raw(:, i, j) = data_fit{j}(xi, zi);
            end
            switch kwargs.proj
                case 'horz'
                    X = xi;
                case 'vert'
                    X = zi;
                case 'line'
                    X = hypot(xi - xi(1), zi - zi(1));
            end
            centerdata();
            % weightdata();
            if length(rois) == 1
                if isempty(kwargs.displayname)
                    for j = 1:prod(sz(3:end))
                        plot(ax, X, raw(:, i, j))
                    end
                else
                    for j = 1:prod(sz(3:end))
                        plot(ax, X, raw(:, i, j), 'DisplayName', kwargs.displayname(j))
                    end
                end
            else
                for j = 1:prod(sz(3:end))
                    plot(ax, X, raw(:, i, j), 'Color', rois{i}.Color)
                end
            end
        end
        customize_appearance();
    end

    function eventrect(~, ~)
        % raw = cell(1, numel(rois));
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on'); set(ax, FontSize = kwargs.fontsize);
        for i = 1:numel(rois)
            mask(:,:,i) = rois{i}.Position;
            frame = select(rois{i});
            xi = selectx(rois{i});
            zi = selectz(rois{i});
            switch kwargs.proj
                case 'horz'
                    xi = mean(xi, 1); zi = mean(zi, 2);
                    X{i} = xi;
                    raw{i} = squeeze(mean(frame, 1));
                case 'vert'
                    xi = mean(xi, 2); zi = mean(zi, 2);
                    X{i} = zi;
                    raw{i} = squeeze(mean(frame, 2));
                case 'line'
                    framer = imfilter(frame, fspecial('motion', size(frame, 2), kwargs.angle));
                    xi = mean(xi, 1); zi = mean(zi, 2);
                    X{i} = zi;
                    raw(:,i) = squeeze(mean(framer, 2));
                    if kwargs.showrotframe
                        cla(axmon); montage(mat2gray(frame, cl(:,:,1)), Parent = axmon); colormap(axmon, kwargs.colormap);
                        cla(axmonrot); montage(mat2gray(framer, cl(:,:,1)), Parent = axmonrot); colormap(axmonrot, kwargs.colormap);
                    end
            end
            % centerdata();
            % weightdata();
            szw = size(raw{i});
            for j = 1:prod(szw(2:end))
                plot(ax, X{i}, raw{i}(:,j), 'Color', rois{i}.Color)
            end
            % if length(rois) == 1
            %     if isempty(kwargs.displayname)
            %         for i = 1:numel(raw)
            %             plot(ax, X{i}, raw{i})
            %         end
            %     else
            %         for i = 1:numel(raw)
            %             plot(ax, X{i}, raw{i}, 'DisplayName', kwargs.displayname(i))
            %         end
            %     end
            % else
            %     for i = 1:numel(raw)
            %         plot(ax, X{i}, raw{i}, 'Color', rois{i}.Color)
            %     end
            % end
        end
        customize_appearance();
    end

    function centerdata()
        switch kwargs.center
            case 'poly1'
                for i = 1:prod(sz(3:end))
                    [xip, yip] = prepareCurveData(X, raw(:, i));
                    rawft = fit(xip, yip, 'poly1');
                    raw(:, i) = raw(:, i) - rawft(X);
                end
            case 'mean'
                raw = normalize(raw, 1, 'center');
        end
    end

    function weightdata()
        for i = 1:numel(raw)
            szr = size(raw{i});
            switch kwargs.winfun
                case 'hann'
                    win = hann(szr(1));
                case 'tukey'
                    win = tukeywin(szr(1), kwargs.tukey);
                case 'humming'
                    win = humming(szr(1));
                otherwise
                    win = ones(szr(1), 1);
            end
            win = repmat(win, 1, szr(2));
            raw{i} = raw{i}.*win;
        end
    end

    function result = getdatafunc()
        % raw = reshape(raw, [size(raw, 1), sz(3:end)]);
        result = struct(x = xi, z = zi, raw = {raw}, mask = {mask}, X = {X});
    end

    if isempty(kwargs.frame); kwargs.frame = 1:prod(sz(3:end)); end
    if ndims(kwargs.clim) == 3;  cl = kwargs.clim; else; cl = repmat(kwargs.clim, 1, 1, prod(sz(3:end))); end
    if isa(kwargs.clabel, 'char'); kwargs.clabel = repmat({kwargs.clabel}, 1, numel(kwargs.frame)); end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout(kwargs.arrangement);
    switch disptype
        case 'node'
            if isempty(kwargs.xlabel); kwargs.xlabel = 'x_{n}'; end
            if isempty(kwargs.ylabel); kwargs.ylabel = 'z_{n}'; end
            for i = kwargs.frame
                nexttile; imagesc(data(:,:,i)); xlabel(kwargs.xlabel); ylabel(kwargs.ylabel); colormap(kwargs.colormap); axis(kwargs.aspect);
                if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
                if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                set(gca, FontSize = kwargs.fontsize);
                if kwargs.colorbar; clb = colorbar(); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel{i}); end; end
                if ~isempty(kwargs.xlim); xlim(kwargs.xlim); end
                if ~isempty(kwargs.ylim); ylim(kwargs.ylim); end
            end
        case 'spatial'
            if isempty(kwargs.xlabel); kwargs.xlabel = 'x, mm'; end
            if isempty(kwargs.ylabel); kwargs.ylabel = 'z, mm'; end
            if ismatrix(kwargs.x) && ismatrix(kwargs.y)
                for i = kwargs.frame
                    nexttile; contourf(kwargs.x, kwargs.y, data(:,:,i), 100, 'LineStyle', 'None'); 
                    xlabel(kwargs.xlabel); ylabel(kwargs.ylabel); colormap(kwargs.colormap); hold on; grid on; box on;
                    if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    set(gca, FontSize = kwargs.fontsize);
                    if kwargs.colorbar; clb = colorbar(); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel{i}); end; end
                    if ~isempty(kwargs.xlim); xlim(kwargs.xlim); end
                    if ~isempty(kwargs.ylim); ylim(kwargs.ylim); end
                end
            else
                for i = kwargs.frame
                    nexttile; contourf(kwargs.x(:,:,i), kwargs.y(:,:,i), data(:,:,i), 100, 'LineStyle', 'None'); 
                    xlabel(kwargs.xlabel); ylabel(kwargs.ylabel); colormap(kwargs.colormap); hold on; grid on; box on;
                    if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    set(gca, FontSize = kwargs.fontsize);
                    if kwargs.colorbar; clb = colorbar(); if ~isempty(kwargs.clabel); ylabel(clb, kwargs.clabel{i}); end; end
                    if ~isempty(kwargs.xlim); xlim(kwargs.xlim); end
                    if ~isempty(kwargs.ylim); ylim(kwargs.ylim); end
                end
            end
    end

    axroi = gca; nexttile; ax = gca; hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');

    switch kwargs.shape
        case 'line'
            rois = guiselectregion(axroi, moved = @eventline, shape = 'line', ...
                mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);
            eventline();
        case 'rect'
            if kwargs.showrotframe && kwargs.proj == "line"
                nexttile; axmon = gca; hold(axmon, 'on'); box(axmon, 'on'); grid(axmon, 'on');
                nexttile; axmonrot = gca; hold(axmonrot, 'on'); box(axmonrot, 'on'); grid(axmonrot, 'on');
            end
            rois = guiselectregion(axroi, moved = @eventrect, shape = 'rect', ...
                mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);
            eventrect();
    end

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

    getdata = @getdatafunc;

end