function rois = guitile(data, named)
%% Visualize multiframe data.
%% The function takes following arguments:
%   data:               [n×m... double]                 - multidimensional data
%   x:                  [n×m double]                    - spatial coordinate
%   z:                  [n×m double]                    - spatial coordinate
%
%   xlim:               [1×2 double]                    - x axis limit
%   ylim:               [1×2 double]                    - y axis limit
%   clim:               [1×2 double]                    - colorbar limit
%   displayname:        [string array]                  - list of labeled curves
%   legend:             [1×1 logical]                   - show legend
%   docked:             [1×1 logical]                   - docker figure
%   colormap:           [char array]                    - colormap
%   aspect:             [char array]                    - axis ratio
%% Examples:

    arguments
        data double
        named.x double = []
        named.z double = []
        %% axis parameters
        named.xlim double = []
        named.ylim double = []
        named.clim cell = cell(1, size(data, 3))
        named.displayname string = []
        named.legend logical = false
        named.docked logical = false
        named.colormap (1,:) char = 'turbo'
        named.aspect (1,:) char {mustBeMember(named.aspect, {'equal', 'auto'})} = 'equal'
        named.location (1,:) char {mustBeMember(named.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
    end

    warning off

    % define dispalying type
    if isempty(named.x) && isempty(named.z)
        disp_type = 'node';
    else
        disp_type = 'spatial';
    end

    if isempty(named.displayname)
        named.legend = false;
    else
        named.legend = true;
    end

    if named.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout('flow', 'TileSpacing', 'compact');
    switch disp_type
        case 'node'
            for i = 1:size(data, 3)
                nexttile; imagesc(data(:,:,i)); xlabel('x_{n}'); ylabel('z_{n}'); colormap(named.colormap);
                if ~isempty(named.clim{i}); clim(named.clim{i}); end
                if ~isempty(named.displayname); title(named.displayname(i), 'FontWeight', 'Normal'); end
            end
        case 'spatial'
            if ismatrix(named.x) && ismatrix(named.z)
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; surf(named.x, named.z, data(:,:,i), 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(named.colormap);
                    if ~isempty(named.clim{i}); clim(named.clim{i}); end
                    axis(named.aspect);
                    if ~isempty(named.displayname); title(named.displayname(i), 'FontWeight', 'Normal'); end
                end
            else
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; surf(named.x(:,:,i), named.z(:,:,i), data(:,:,1), 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(named.colormap);
                    if ~isempty(named.clim{i}); clim(named.clim{i}); end
                    axis(named.aspect);
                    if ~isempty(named.displayname); title(named.displayname(i), 'FontWeight', 'Normal'); end
                end
            end
    end

end