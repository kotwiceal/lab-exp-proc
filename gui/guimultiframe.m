function guimultiframe(varargin, named)
%% Interactive visualization of page-wise 2D data.
%% The function takes following arguments:
%   data:       [n×m×k... double]   - 3D array
%   clim:       [double]            - colormap limit
%   label:      [char array]        - figure title; 

    arguments (Repeating)
        varargin
    end

    arguments
        named.clim double = [0, 1]
        named.label char = ''
        named.cdiv logical = false
    end

    if iscell(varargin)
        data = varargin{1};
    else
        data = varargin;
    end

    function show(i)
        cla(ax); box(ax, 'on'); imagesc(ax, data(:,:,i)); colormap(ax, 'turbo'); 
        if named.cdiv
            clim(ax, [-named.clim(2), named.clim(2)]);
        else
            clim(ax, named.clim);
        end
        axis(ax, 'equal'); title(ax, named.label, 'FontWeight', 'Normal')
    end

    function updateRange(~, event)
        try
            show(round(event.Value));
        catch
            warning('guimultiframe: updateRange error');
        end
    end

    function updateClim(~, event)
        named.clim(2) = event.Value; 
        try
            if named.cdiv
                clim(ax, [-named.clim(2), named.clim(2)]);
            else
                clim(ax, named.clim);
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

    sld_clim = uislider(g, 'Limits', named.clim, 'Value', named.clim(2), 'Orientation', 'vertical', ...
      'ValueChangingFcn', @updateClim);
    sld_clim.Layout.Row = [1, 2];
    sld_clim.Layout.Column = 2;

end