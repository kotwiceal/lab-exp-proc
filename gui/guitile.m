function guitile(data, kwargs)
%% Visualize multiframe data.

    arguments
        data double % matrix/pase-wise array
        kwargs.x double = [] % longitudinal coordinate matrix/pase-wise array
        kwargs.z double = [] % tranversal coordinate matrix/pase-wise array
        %% axis parameters
        kwargs.xlim (1,2) double = [] % x-axis limit
        kwargs.ylim (1,2) double = [] % y-axis limit
        kwargs.clim (1,2) double = [] % color-axis limit
        kwargs.displayname string = [] % list of labels
        kwargs.legend logical = false % show legend
        kwargs.docked logical = false % docker figure
        kwargs.colormap (1,:) char = 'turbo' % colormap
        kwargs.colorbar logical = true % show colorbar
        kwargs.clabel (1,:) char = [] % color-axis label
        kwargs.fontsize (1,1) double = 14 % axis font size
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal' % axis ratio
        % legend location
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = [] % figure global title
        kwargs.filename (1, :) char = [] % filename of storing figure
        kwargs.extension (1, :) char = '.png' % extention of storing figure
    end

    warning off

    sz = size(data); if numel(sz) == 2; sz(3) = 1; end 

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.z); disptype = 'node'; else; disptype = 'spatial'; end
    if isempty(kwargs.displayname); kwargs.legend = false; else; kwargs.legend = true; end
    if ndims(kwargs.clim) == 3;  cl = kwargs.clim; else; cl = repmat(kwargs.clim, 1, 1, sz(3)); end
    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
    switch disptype
        case 'node'
            for i = 1:size(data, 3)
                nexttile; imagesc(data(:,:,i)); xlabel('x_{n}'); ylabel('z_{n}'); colormap(kwargs.colormap);
                if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
                if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                if kwargs.colorbar
                    clb = colorbar();
                    if ~isempty(kwargs.clabel)
                        ylabel(clb, kwargs.clabel);
                    end
                end
                axis('image'); set(gca, FontSize = kwargs.fontsize);
            end
        case 'spatial'
            if ismatrix(kwargs.x) && ismatrix(kwargs.z)
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; surf(kwargs.x, kwargs.z, data(:,:,i), 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(kwargs.colormap);
                    if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    if kwargs.colorbar
                        clb = colorbar();
                        if ~isempty(kwargs.clabel)
                            ylabel(clb, kwargs.clabel);
                        end
                    end
                    xlim([min(kwargs.x(:)), max(kwargs.x(:))]); ylim([min(kwargs.z(:)), max(kwargs.z(:))]);
                    set(gca, FontSize = kwargs.fontsize);
                end
            else
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; surf(kwargs.x(:,:,i), kwargs.z(:,:,i), data(:,:,i), 'LineStyle', 'None'); 
                    xlabel('x, mm'); ylabel('z, mm'); colormap(kwargs.colormap);
                    if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    if kwargs.colorbar
                        clb = colorbar();
                        if ~isempty(kwargs.clabel)
                            ylabel(clb, kwargs.clabel);
                        end
                    end
                    set(gca, FontSize = kwargs.fontsize);
                end
            end
    end

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end