function guitile(data, kwargs)
%% Visualize multiframe data.

    arguments
        data double % matrix/pase-wise array
        kwargs.x double = [] % longitudinal coordinate matrix/pase-wise array
        kwargs.y double = [] % tranversal coordinate matrix/pase-wise array
        %% axis parameters
        kwargs.xlim (1,:) double = [] % x-axis limit
        kwargs.ylim (1,:) double = [] % y-axis limit
        kwargs.xlabel (1,:) char = [] % x-axis label of data subplot
        kwargs.ylabel (1,:) char = [] % y-axis label of data subplot
        kwargs.clim (:,:) double = [] % color-axis limit
        kwargs.show (1,:) {mustBeMember(kwargs.show, {'surf', 'contourf'})} = 'contourf'
        kwargs.displayname string = [] % list of labels
        kwargs.legend logical = false % show legend
        kwargs.docked logical = false % docker figure
        kwargs.colormap (1,:) char = 'turbo' % colormap
        kwargs.colorbar logical = true % show colorbar
        kwargs.clabel (1,:) char = [] % color-axis label
        kwargs.fontsize (1,1) double = 14 % axis font size
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'equal' % axis ratio
        % legend location
        kwargs.location (1,:) char {mustBeMember(kwargs.location, {'north','south','east','west','northeast','northwest','southeast','southwest','northoutside','southoutside','eastoutside','westoutside','northeastoutside','northwestoutside','southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        kwargs.title = [] % figure global title
        kwargs.filename (1,:) char = [] % filename of storing figure
        kwargs.extension (1,:) char = '.png' % extention of storing figure
    end

    warning off

    sz = size(data); if numel(sz) == 2; sz(3) = 1; end 

    % define dispalying type
    if isempty(kwargs.x) && isempty(kwargs.y); disptype = 'node'; else; disptype = 'spatial'; end
    if isempty(kwargs.displayname); kwargs.legend = false; else; kwargs.legend = true; end
    if ~isvector(kwargs.clim);  cl = kwargs.clim; else; cl = repmat(kwargs.clim, sz(3), 1); end
    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
    switch disptype
        case 'node'
            for i = 1:size(data, 3)
                nexttile; imagesc(data(:,:,i)); colormap(kwargs.colormap);
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
        case 'spatial'
            if ismatrix(kwargs.x) && ismatrix(kwargs.y)
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; 
                    switch kwargs.show
                        case 'surf'
                            surf(kwargs.x, kwargs.y, data(:,:,i), 'LineStyle', 'None'); 
                        case 'contourf'
                            contourf(kwargs.x, kwargs.y, data(:,:,i), 100, 'LineStyle', 'None'); 
                    end
                    colormap(kwargs.colormap);
                    if ~isempty(cl); clim(cl(i,:)); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    if kwargs.colorbar
                        clb = colorbar();
                        if ~isempty(kwargs.clabel)
                            ylabel(clb, kwargs.clabel);
                        end
                    end
                    xlim([min(kwargs.x(:)), max(kwargs.x(:))]); ylim([min(kwargs.y(:)), max(kwargs.y(:))]);
                    set(gca, FontSize = kwargs.fontsize);
                    if ~isempty(kwargs.xlabel); xlabel(kwargs.xlabel); end
                    if ~isempty(kwargs.ylabel); ylabel(kwargs.ylabel); end
                end
            else
                for i = 1:size(data, 3)
                    nexttile; hold on; box on; grid on; 
                    switch kwargs.show
                        case 'surf'
                            surf(kwargs.x(:,:,i), kwargs.y(:,:,i), data(:,:,i), 'LineStyle', 'None'); 
                        case 'contourf'
                            contourf(kwargs.x(:,:,i), kwargs.y(:,:,i), data(:,:,i), 100, 'LineStyle', 'None'); 
                    end
                    colormap(kwargs.colormap);
                    if ~isempty(cl); clim(cl(i,:)); end
                    axis(kwargs.aspect);
                    if ~isempty(kwargs.displayname); title(kwargs.displayname(i), 'FontWeight', 'Normal'); end
                    if kwargs.colorbar
                        clb = colorbar();
                        if ~isempty(kwargs.clabel)
                            ylabel(clb, kwargs.clabel);
                        end
                    end
                    set(gca, FontSize = kwargs.fontsize);
                    if ~isempty(kwargs.xlabel); xlabel(kwargs.xlabel); end
                    if ~isempty(kwargs.ylabel); ylabel(kwargs.ylabel); end
                end
            end
    end

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end