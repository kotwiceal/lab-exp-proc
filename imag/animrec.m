function animrec(data, kwargs)
%% Animation recorder of 2D multi-frame data
%% The function takes following arguments:
%   data:               [n×m×k double]      - three dimensional data
%   x:                  [n×m double]        - longitudinal spatial coordinate
%   z:                  [n×m double]        - transversal spatial coordinate
%   filename:           [1×l1 char]         - filename of storing animation
%   xlabel:             [1×l2 char]         - x-axis label
%   ylabel:             [1×l3 char]         - y-axis label
%   axis:               [1×l4 char]         - axis aspect raio
%   axis:               [1×2 double]        - color axis limit
%   colormap:           [1×l5 char]         - colomap name
%% Examples:
%% 1. Record animation of set 2D multi-frame
% animrec(rand(120, 140, 10), filename = 'test.gif', clim = [-1, 1], axis = 'equal')

    arguments
        data (:,:,:) double
        kwargs.x double = []
        kwargs.z double = []
        kwargs.filename = ''
        kwargs.xlabel (1,:) char = []
        kwargs.ylabel (1,:) char = []
        kwargs.axis (1,:) char = 'equal'
        kwargs.clim (1,2) double = [1e-4, 5e-3]
        kwargs.colormap (1,:) char = 'turbo'
    end

    display = isempty(kwargs.x) & isempty(kwargs.z); 
    display_label = isempty(kwargs.xlabel) & isempty(kwargs.ylabel); 

    clf; tiledlayout('flow'); nexttile; ax = gca;
    hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on'); axis(ax, kwargs.axis);
    if display
        imagesc(ax, data(:,:,1));
        if display_label
            xlabel(ax, 'x_{n}'); ylabel(ax, 'z_[n}');
        else
            xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
        end
    else
        surf(ax, kwargs.x, kwargs.z, data(:,:,1), 'LineStyle', 'None');
        xlim(ax, [min(kwargs.x(:)), max(kwargs.x(:))]);
        ylim(ax, [min(kwargs.z(:)), max(kwargs.z(:))]);
        if display_label
            xlabel(ax, 'x, mm'); ylabel(ax, 'z, mm');
        else
            xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
        end
    end
    clim(ax, kwargs.clim);
    colormap(ax, kwargs.colormap);
    exportgraphics(ax, kwargs.filename);

    for i = 1:size(data, 3)
        cla(ax);
        hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on'); axis(ax, kwargs.axis);
        if display
            imagesc(ax, data(:,:,i));
            if display_label
                xlabel(ax, 'x_{n}'); ylabel(ax, 'z_[n}');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
        else
            surf(ax, kwargs.x, kwargs.z, data(:,:,i), 'LineStyle', 'None');
            xlim(ax, [min(kwargs.x(:)), max(kwargs.x(:))]);
            ylim(ax, [min(kwargs.z(:)), max(kwargs.z(:))]);
            if display_label
                xlabel(ax, 'x, mm'); ylabel(ax, 'z, mm');
            else
                xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); 
            end
        end
        xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); clim(ax, kwargs.clim);
        colormap(ax, kwargs.colormap);
        exportgraphics(ax, kwargs.filename, Append = true);
    end
end