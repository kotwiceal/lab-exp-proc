function guimultiframe(varargin, kwargs)
%% Interactive visualization of page-wise 2D data.
%% The function takes following arguments:
%   data:       [n×m×k... double]   - three dimensional data
%   clim:       [double]            - color axis limit
%   title:      [char array]        - figure title 
%% Examples:
%% 1. Show multi-frame data
% guimultiframe(radn(120, 130, 10), clim = [-1, 1])

    arguments (Repeating)
        varargin
    end

    arguments
        kwargs.clim double = [0, 1]
        kwargs.title char = ''
        kwargs.cdiv logical = false
    end

    if iscell(varargin)
        data = varargin{1};
    else
        data = varargin;
    end

    function show(i)
        cla(ax); box(ax, 'on'); imagesc(ax, data(:,:,i)); colormap(ax, 'turbo'); 
        if kwargs.cdiv
            clim(ax, [-kwargs.clim(2), kwargs.clim(2)]);
        else
            clim(ax, kwargs.clim);
        end
        axis(ax, 'equal'); title(ax, kwargs.title, 'FontWeight', 'Normal')
    end

    function updateRange(~, event)
        try
            show(round(event.Value));
        catch
            warning('guimultiframe: updateRange error');
        end
    end

    function updateClim(~, event)
        kwargs.clim(2) = event.Value; 
        try
            if kwargs.cdiv
                clim(ax, [-kwargs.clim(2), kwargs.clim(2)]);
            else
                clim(ax, kwargs.clim);
            end
        catch
            warning('guimultiframe: updateClim error');
        end
    end

    fig = uifigure;
    g = uigridlayout(fig);
    g.RowHeight = {'1x', 'fit'}; g.ColumnWidth = {'1x', 'fit'};
    
    ax = uiaxes(g); 
    show(1);

    sld_range = uislider(g, 'Limits', [1, size(data,3)], 'Value', 1, 'ValueChangingFcn', @updateRange);
    sld_range.Layout.Row = 2;
    sld_range.Layout.Column = 1;

    sld_clim = uislider(g, 'Limits', kwargs.clim, 'Value', kwargs.clim(2), 'Orientation', 'vertical', ...
      'ValueChangingFcn', @updateClim);
    sld_clim.Layout.Row = [1, 2];
    sld_clim.Layout.Column = 2;

end