function getdata = guilinedist(data, kwargs)
%% Visualize data distribution along specified lines.
%% The function takes following arguments:
%   data:               [n×m... double]                 - three dimensional data
%   x:                  [n×m double]                    - spatial coordinate
%   z:                  [n×m double]                    - spatial coordinate
%   proj:               [1×l1 char]                     - type projection of distribution
%   shape:              [char array]                    - shape of selection tool
%   mask:               [double]                        - two row vertex to line selection; edge size to rectangle selection
%   interaction:        [1×l2 char]                     - region selection behaviour
%   number:             [1×1 int]                       - count of selection regions
%   xlim:               [1×2 double]                    - x-axis limit
%   ylim:               [1×2 double]                    - y-axis limit
%   clim:               [1×2 double]                    - colorbar limit
%   ylabel:             [1×l3 char]                     - y-axis label
%   displayname:        [string array]                  - list of labeled curves
%   legend:             [1×1 logical]                   - show legend flag
%   docked:             [1×1 logical]                   - docked figure flag
%   colormap:           [1×l4 char]                     - colormap name
%   aspect:             [1×l5 char]                     - axis aspect ratio
%   location:           [1×l6 char]                     - legend location name
%   title:              [1×l7 char]                     - figure title
%   filename:           [1×l8 char]                     - filename of storing figure
%   extension:          [1×l9 char]                     - file extention of storing figure
%   showrotframe:       [char array]                    - supporing figure to show rotated frames
%% The function returns following results:
%   getdata:            [function_handle]               - function returning the last line distribution processing
%% Examples:
%% 1. Show distribution along horizontal projection of drawn line, 2D field is presented in spatial coordinates:
% guilinedist(data.vmn(:,:,1), x = data.x, z = data.z);
%% 2. Show distribution along vertical projection of drawn line, 2D field is presented in node coordinates:
% guilinedist(data.vmn(:,:,1), proj = 'vert');
%% 3. Show several distributions along drawn line, 2D field is presented in node coordinates:
% guilinedist(data.vmn(:,:,1:5), proj = 'line');
%% 4. show distribution along several drawn lines, 2D field is presented in node coordinates:
% guilinedist(gca, data.vmn(:,:,1:5), proj = 'line', number = 3);

    arguments
        data (:,:,:) double
        kwargs.x double = []
        kwargs.z double = []
        kwargs.proj (1,:) char {mustBeMember(kwargs.proj, {'horz', 'vert', 'line'})} = 'horz'
        kwargs.angle (1,1) double = -22
        %% roi and axis parameters
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'line', 'rect'})} = 'line'
        kwargs.mask double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.number int8 = 1
        kwargs.xlim double = []
        kwargs.ylim double = []
        kwargs.clim double = []
        kwargs.ylabel (1,:) char = 'intermittency'
        kwargs.displayname string = []
        kwargs.legend logical = false
        kwargs.docked logical = false
        kwargs.colormap (1,:) char = 'turbo'
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal'
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = []
        kwargs.filename (1, :) char = []
        kwargs.extension (1, :) char = '.png'
        kwargs.showrotframe logical = true
    end

    warning off

    xi = []; zi = []; prof = []; position = [];

    % define variables
    data_fit = cell(1, size(data, 3));

    % define display type   
    if isempty(kwargs.x) && isempty(kwargs.z)
        disptype = 'node'; 
        [x, z] = meshgrid(1:size(data, 2), 1:size(data, 1));
    else
        disptype = 'spatial';
        x = kwargs.x; z = kwargs.z;
    end

    % define funtion handle to probe data
    switch kwargs.shape
        case 'line'
            switch disptype
                case 'node'  
                    for j = 1:size(data, 3)
                        [xi, zi] = ndgrid(1:size(data, 1), 1:size(data, 2));
                        [xo, zo, io] = prepareSurfaceData(xi, zi, data(:,:,j));
                        data_fit{j} = fit([zo, xo], io, 'linearinterp');
                    end
                case 'spatial'
                    if ismatrix(kwargs.x) && ismatrix(kwargs.z)
                        for j = 1:size(data, 3)
                            [xo, zo, io] = prepareSurfaceData(kwargs.x, kwargs.z, data(:,:,j)); 
                            data_fit{j} = fit([xo, zo], io, 'linearinterp');
                        end
                    else
                        for j = 1:size(data, 3)
                            [xo, zo, io] = prepareSurfaceData(kwargs.x(:,:,j), kwargs.z(:,:,j), data(:,:,j)); 
                            data_fit{j} = fit([xo, zo], io, 'linearinterp');
                        end
                    end
            end
        case 'rect'
            switch disptype
                case 'node'
                    select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', permute = [2, 1]);
                    selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', permute = [2, 1]);
                    selectz = @(roiobj) guigetdata(roiobj, z, shape = 'cut',permute = [2, 1]);
                case 'spatial'
                    select = @(roiobj) guigetdata(roiobj, data, shape = 'cut', x = x, z = z);
                    selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', x = x, z = z);
                    selectz = @(roiobj) guigetdata(roiobj, z, shape = 'cut', x = x, z = z);
            end
    end

    if isempty(kwargs.displayname); kwargs.legend = false; else; kwargs.legend = true; end

    function customize_appearance()
        %% change figure appearance
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
        if ~isempty(kwargs.ylabel); ylabel(ax, kwargs.ylabel); end
        if ~isempty(kwargs.xlim); xlim(ax, kwargs.xlim); end
        if ~isempty(kwargs.ylim); ylim(ax, kwargs.ylim); end
        if kwargs.legend; legend(ax, 'Location', kwargs.location); end
        axis(ax, 'square')
    end

    function eventline(~, ~)
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
        for i = 1:length(rois)
            position(:,:,i) = rois{i}.Position;
            xi = linspace(rois{i}.Position(1,1), rois{i}.Position(2,1));
            zi = linspace(rois{i}.Position(1,2), rois{i}.Position(2,2));
            X = []; prof = [];
            for j = 1:size(data, 3)
                prof(:, j) = data_fit{j}(xi, zi);
            end
            switch kwargs.proj
                case 'horz'
                    X = xi;
                case 'vert'
                    X = zi;
                case 'line'
                    X = hypot(xi - xi(1), zi - zi(1));
            end

            if length(rois) == 1
                if isempty(kwargs.displayname)
                    for j = 1:size(data, 3)
                        plot(ax, X, prof(:, j))
                    end
                else
                    for j = 1:size(data, 3)
                        plot(ax, X, prof(:, j), 'DisplayName', kwargs.displayname(j))
                    end
                end
            else
                for j = 1:size(data, 3)
                    plot(ax, X, prof(:, j), 'Color', rois{i}.UserData.color)
                end
            end
        end
        customize_appearance();
    end

    function eventrect(~, ~)
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
        for i = 1:length(rois)
            position(:,:,i) = rois{i}.Position;
            frame = select(rois{i});
            xi = selectx(rois{i});
            zi = selectz(rois{i});
            switch kwargs.proj
                case 'horz'
                    X = mean(xi, 1);
                    prof = squeeze(mean(frame, 1));
                case 'vert'
                    X = mean(zi, 2);
                    prof = squeeze(mean(frame, 2));
                case 'line'
                    framer = imfilter(frame, fspecial('motion', size(frame, 2), kwargs.angle));
                    X = mean(zi, 2);
                    prof = squeeze(mean(framer, 2));
                    if kwargs.showrotframe
                        cla(axmon); montage(mat2gray(cat(3, frame, framer)), Parent = axmon); colormap(axmon, kwargs.colormap);
                    end
            end
            if length(rois) == 1
                if isempty(kwargs.displayname)
                    for j = 1:size(data, 3)
                        plot(ax, X, prof(:, j))
                    end
                else
                    for j = 1:size(data, 3)
                        plot(ax, X, prof(:, j), 'DisplayName', kwargs.displayname(j))
                    end
                end
            else
                for j = 1:size(data, 3)
                    plot(ax, X, prof(:, j), 'Color', rois{i}.UserData.color)
                end
            end
        end
        customize_appearance();
    end

    function result = getdatafunc()
        result = struct(x = xi, z = zi, prof = prof, mask = position);
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow');
    switch disptype
        case 'node'
            for i = 1:size(data, 3)
                nexttile; imagesc(data(:,:,i)); xlabel('x_{n}'); ylabel('z_{n}'); colormap(kwargs.colormap); axis(kwargs.aspect);
                if ~isempty(kwargs.clim); clim(kwargs.clim); end
                if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
            end
        case 'spatial'
            if ismatrix(kwargs.x) && ismatrix(kwargs.z)
                for i = 1:size(data, 3)
                    nexttile; contourf(kwargs.x, kwargs.z, data(:,:,i), 100, 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(kwargs.colormap);
                    if ~isempty(kwargs.clim); clim(kwargs.clim); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                end
            else
                for i = 1:size(data, 3)
                    nexttile; contourf(kwargs.x(:,:,i), kwargs.z(:,:,i), data(:,:,i), 100, 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(kwargs.colormap);
                    if ~isempty(kwargs.clim); clim(kwargs.clim); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                end
            end
    end
    xlim([min(x(:)), max(x(:))]); ylim([min(z(:)), max(z(:))]);

    axroi = gca; nexttile; ax = gca;

    switch kwargs.shape
        case 'line'
            rois = guiselectregion(axroi, moved = @eventline, shape = 'line', ...
                mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);
            eventline();
        case 'rect'
            if kwargs.showrotframe && kwargs.proj == "line"
                nexttile; axmon = gca;
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