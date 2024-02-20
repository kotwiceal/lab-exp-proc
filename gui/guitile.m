function guitile(data, kwargs)
%% Visualize multiframe data.
%% The function takes following arguments:
%   data:               [n×m×k double]                  - multidimensional data
%   x:                  [n×m double]                    - spatial coordinate
%   z:                  [n×m double]                    - spatial coordinate
%   xlim:               [1×2 double]                    - x axis limit
%   ylim:               [1×2 double]                    - y axis limit
%   clim:               [1×2 double]                    - colorbar limit
%   displayname:        [string array]                  - list of labeled curves
%   legend:             [1×1 logical]                   - show legend
%   docked:             [1×1 logical]                   - docker figure
%   colormap:           [char array]                    - colormap
%   aspect:             [char array]                    - axis ratio
%   location:           [1×l6 char]                     - legend location name
%   title:              [1×l7 char]                     - figure title
%   filename:           [1×l8 char]                     - filename of storing figure
%   extension:          [1×l9 char]                     - file extention of storing figure

    arguments
        data double
        kwargs.x double = []
        kwargs.z double = []
        %% axis parameters
        kwargs.xlim double = []
        kwargs.ylim double = []
        kwargs.clim cell = cell(1, size(data, 3))
        kwargs.displayname string = []
        kwargs.legend logical = false
        kwargs.docked logical = false
        kwargs.colormap (1,:) char = 'turbo'
        kwargs.colorbar logical = true
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal'
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = []
        kwargs.filename (1, :) char = []
        kwargs.extension (1, :) char = '.png'
    end

    warning off

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.z); disp_type = 'node'; else; disp_type = 'spatial'; end

    if isempty(kwargs.displayname); kwargs.legend = false; else; kwargs.legend = true; end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow');
    switch disp_type
        case 'node'
            for i = 1:size(data, 3)
                nexttile; imagesc(data(:,:,i)); xlabel('x_{n}'); ylabel('z_{n}'); colormap(kwargs.colormap);
                if ~isempty(kwargs.clim{i}); clim(kwargs.clim{i}); end
                if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                if kwargs.colorbar; colorbar(); end
            end
        case 'spatial'
            if ismatrix(kwargs.x) && ismatrix(kwargs.z)
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; surf(kwargs.x, kwargs.z, data(:,:,i), 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(kwargs.colormap);
                    if ~isempty(kwargs.clim{i}); clim(kwargs.clim{i}); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    if kwargs.colorbar; colorbar(); end
                    xlim([min(kwargs.x(:)), max(kwargs.x(:))]); ylim([min(kwargs.z(:)), max(kwargs.z(:))]);
                end
            else
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; surf(kwargs.x(:,:,i), kwargs.z(:,:,i), data(:,:,i), 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(kwargs.colormap);
                    if ~isempty(kwargs.clim{i}); clim(kwargs.clim{i}); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    if kwargs.colorbar; colorbar(); end
                end
            end
    end

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end