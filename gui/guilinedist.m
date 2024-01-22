function rois = guilinedist(data, named)
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
%% show distribution along horizontal projection of drawn line, 2D field is presented in spatial coordinates
% guilinedist(data.vmn(:,:,1), x = data.x, z = data.z);
%% show distribution along vertical projection of drawn line, 2D field is presented in node coordinates
% guilinedist(data.vmn(:,:,1), proj = 'vert');
%% show several distributions along drawn line, 2D field is presented in node coordinates
% guilinedist(data.vmn(:,:,1:5), proj = 'line');
%% show distribution along several drawn lines, 2D field is presented in node coordinates
% guilinedist(gca, data.vmn(:,:,1:5), proj = 'line', number = 3);

    arguments
        data double
        named.x double = []
        named.z double = []
        named.proj (1,:) char {mustBeMember(named.proj, {'horz', 'vert', 'line'})} = 'horz'
        %% roi and axis parameters
        named.mask double = []
        named.interaction (1,:) char {mustBeMember(named.interaction, {'all', 'none', 'translate'})} = 'all'
        named.number int8 = 1
        named.xlim double = []
        named.ylim double = []
        named.clim double = [0, 1]
        named.displayname string = []
        named.legend logical = false
        named.docked logical = false
        named.colormap (1,:) char = 'turbo'
        named.aspect (1,:) char {mustBeMember(named.aspect, {'equal', 'auto'})} = 'equal'
    end

    warning off

    % define variables
    data_fit = cell(1, size(data, 3));

    % define dispalying type
    if isempty(named.x) && isempty(named.z)
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
            if ismatrix(named.x) && ismatrix(named.z)
                for j = 1:size(data, 3)
                    [xo, zo, io] = prepareSurfaceData(named.x, named.z, data(:,:,j)); 
                    data_fit{j} = fit([xo, zo], io, 'linearinterp');
                end
            else
                for j = 1:size(data, 3)
                    [xo, zo, io] = prepareSurfaceData(named.x(:,:,j), named.z(:,:,j), data(:,:,j)); 
                    data_fit{j} = fit([xo, zo], io, 'linearinterp');
                end
            end
    end

    if isempty(named.displayname)
        named.legend = false;
    else
        named.legend = true;
    end

    function customize_appearance()
        %% change figure appearance
        switch disp_type
            case 'node'  
                switch named.proj
                    case 'horz'
                        xlabel(ax, 'x_{n}'); ylabel(ax, 'value');
                    case 'vert'
                        xlabel(ax, 'z_{n}'); ylabel(ax, 'value');
                    case 'line'
                        xlabel(ax, 'l_{n}'); ylabel(ax, 'value');
                end
            case 'spatial'
                switch named.proj
                    case 'horz'
                        xlabel(ax, 'x, mm'); ylabel(ax, 'value');
                    case 'vert'
                        xlabel(ax, 'z, mm'); ylabel(ax, 'value');
                    case 'line'
                        xlabel(ax, 'l, mm'); ylabel(ax, 'value');
                end
        end

        if ~isempty(named.xlim); xlim(ax, named.xlim); end
        if ~isempty(named.ylim); ylim(ax, named.ylim); end
        if named.legend; legend(ax, 'Location', 'Best'); end
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
            switch named.proj
                case 'horz'
                    X = xi;
                case 'vert'
                    X = zi;
                case 'line'
                    X = hypot(xi - xi(1), zi - zi(1));
            end

            if length(rois) == 1
                if isempty(named.displayname)
                    for j = 1:size(data, 3)
                        plot(ax, X, Y{j})
                    end
                else
                    for j = 1:size(data, 3)
                        plot(ax, X, Y{j}, 'DisplayName', named.displayname(j))
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

    if named.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    switch ndims(data)
        case 2
            tiledlayout(1, 2);
        case 3
            tiledlayout(ceil(size(data, 3)/2)+1, 2);
    end
    switch disp_type
        case 'node'
            for i = 1:size(data, 3)
                nexttile; imagesc(data(:,:,i)); xlabel('x_{n}'); ylabel('z_{n}'); colormap(named.colormap);
                if ~isempty(named.clim); clim(named.clim); end
                if ~isempty(named.displayname); title(named.displayname(i), 'FontWeight', 'Normal'); end
            end
        case 'spatial'
            if ismatrix(named.x) && ismatrix(named.z)
                for i = 1:size(data, 3)
                    nexttile; contourf(named.x, named.z, data(:,:,i), 100, 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(named.colormap);
                    if ~isempty(named.clim); clim(named.clim); end
                    axis(named.aspect);
                    if ~isempty(named.displayname); title(named.displayname(i), 'FontWeight', 'Normal'); end
                end
            else
                for i = 1:size(data, 3)
                    nexttile; contourf(named.x(:,:,i), named.z(:,:,i), data(:,:,1), 100, 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(named.colormap);
                    if ~isempty(named.clim); clim(named.clim); end
                    axis(named.aspect);
                    if ~isempty(named.displayname); title(named.displayname(i), 'FontWeight', 'Normal'); end
                end
            end
    end

    axroi = gca;

    nexttile; ax = gca;
    rois = guiselectregion(axroi, @event, shape = 'line', ...
        mask = named.mask, interaction = named.interaction, number = named.number);

    event();

end