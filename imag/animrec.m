function animrec(data, kwargs)
    arguments
        data (:,:,:) double
        kwargs.x double = x
        kwargs.z double = []
        kwargs.filename = ''
        kwargs.xlabel (1,:) char = 'x, mm'
        kwargs.ylabel (1,:) char = 'z, mm'
        kwargs.axis (1,:) char = 'equal'
        kwargs.clim (1,2) double = [1e-4, 5e-3]
        kwargs.colormap (1,:) char = 'turbo'
    end

    display = isempty(kwargs.x) & isempty(kwargs.z); 

    clf; tiledlayout('flow'); nexttile; ax = gca;
    hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on'); axis(ax, kwargs.axis);
    if display
        imagesc(ax, data(:,:,1));
    else
        surf(ax, kwargs.x, kwargs.z, data(:,:,1), 'LineStyle', 'None');
        xlim(ax, [min(kwargs.x(:)), max(kwargs.x(:))]);
        ylim(ax, [min(kwargs.z(:)), max(kwargs.z(:))]);
    end
    xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); clim(ax, kwargs.clim);
    colormap(ax, kwargs.colormap);
    exportgraphics(ax, kwargs.filename);

    for i = 1:size(data, 3)
        cla(ax);
        hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on'); axis(ax, kwargs.axis);
        if display
            imagesc(ax, data(:,:,i));
        else
            surf(ax, kwargs.x, kwargs.z, data(:,:,i), 'LineStyle', 'None');
            xlim(ax, [min(kwargs.x(:)), max(kwargs.x(:))]);
            ylim(ax, [min(kwargs.z(:)), max(kwargs.z(:))]);
        end
        xlabel(ax, kwargs.xlabel); ylabel(ax, kwargs.ylabel); clim(ax, kwargs.clim);
        colormap(ax, kwargs.colormap);
        exportgraphics(ax, kwargs.filename, Append = true);
    end
end