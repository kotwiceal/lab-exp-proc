function rois = guilinedist(data, kwargs)
%% Visualize data distribution along specified lines.
%% The function takes following arguments:
%   data:               [n×m... double]                 - multidimensional data
%   x:                  [n×m double]                    - spatial coordinate
%   z:                  [n×m double]                    - spatial coordinate
%   proj:               [char array]                    - type projection of distribution
%
%   mask:               [double]                        - two row vertex to line selection; edge size to rectangle selection
%   interaction:        [char array]                    - region selection behaviour
%   number:             [int]                           - count of selection regions
%   xlim:               [1×2 double]                    - x axis limit
%   ylim:               [1×2 double]                    - y axis limit
%   clim:               [1×2 double]                    - colorbar limit
%   displayname:        [string array]                  - list of labeled curves
%   legend:             [1×1 logical]                   - show legend
%   docked:             [1×1 logical]                   - docker figure
%   colormap:           [char array]                    - colormap
%   aspect:             [char array]                    - axis ratio
%% The function returns following results:
%   rois:               [object]                        - ROI cell objects
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
        data double
        kwargs.x double = []
        kwargs.z double = []
        kwargs.proj (1,:) char {mustBeMember(kwargs.proj, {'horz', 'vert', 'line'})} = 'horz'
        %% roi and axis parameters
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
    end

    warning off

    % define variables
    data_fit = cell(1, size(data, 3));

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.z)
        disp_type = 'node';
    else
        disp_type = 'spatial';
    end

    % define funtion handle to probe data
    switch disp_type
        case 'node'  
            for j = 1:size(data, 3)
                [xi, zi] = ndgrid(1:size(data, 1), 1:size(data, 2));
                [xo, zo, io] = prepareSurfaceData(xi, zi, data(:,:,j));
                % data_fit{j} = fit([xo, zo], io, 'linearinterp');
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

    if isempty(kwargs.displayname)
        kwargs.legend = false;
    else
        kwargs.legend = true;
    end

    function customize_appearance()
        %% change figure appearance
        switch disp_type
            case 'node'  
                switch kwargs.proj
                    case 'horz'
                        xlabel(ax, 'x_{n}'); ylabel(ax, 'value');
                    case 'vert'
                        xlabel(ax, 'z_{n}'); ylabel(ax, 'value');
                    case 'line'
                        xlabel(ax, 'l_{n}'); ylabel(ax, 'value');
                end
            case 'spatial'
                switch kwargs.proj
                    case 'horz'
                        xlabel(ax, 'x, mm'); ylabel(ax, 'value');
                    case 'vert'
                        xlabel(ax, 'z, mm'); ylabel(ax, 'value');
                    case 'line'
                        xlabel(ax, 'l, mm'); ylabel(ax, 'value');
                end
        end
        if ~isempty(kwargs.ylabel); ylabel(ax, kwargs.ylabel); end
        if ~isempty(kwargs.xlim); xlim(ax, kwargs.xlim); end
        if ~isempty(kwargs.ylim); ylim(ax, kwargs.ylim); end
        if kwargs.legend; legend(ax, 'Location', kwargs.location); end
        axis(ax, 'square')
    end

    function event(~, ~)
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
        for i = 1:length(rois)
            xi = linspace(rois{i}.Position(1,1), rois{i}.Position(2,1));
            zi = linspace(rois{i}.Position(1,2), rois{i}.Position(2,2));
            X = []; Y = cell(1, size(data, 3));
            for j = 1:size(data, 3)
                Y{j} = data_fit{j}(xi, zi);
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
                        plot(ax, X, Y{j})
                    end
                else
                    for j = 1:size(data, 3)
                        plot(ax, X, Y{j}, 'DisplayName', kwargs.displayname(j))
                    end
                end
            else
                for j = 1:size(data, 3)
                    plot(ax, X, Y{j}, 'Color', rois{i}.UserData.color)
                end
            end
        end
        customize_appearance();
    end

    if kwargs.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout('flow');
    switch disp_type
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

    axroi = gca;

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'line', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);

    event();

    if ~isempty(kwargs.title)
        sgtitle(kwargs.title)
    end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end