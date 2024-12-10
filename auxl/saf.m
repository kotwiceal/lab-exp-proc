function saf(folder, kwargs)
    arguments
        folder (1,:) char {mustBeFolder} = []
        kwargs.resolution (1,1) = 300
        kwargs.extension (1,:) = '.png'
    end
    
    if ~isempty(folder)
        try
            mkdir(folder)
        catch
        end
    end

    figlist = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:numel(figlist)
      fighandle = figlist(iFig);
      figname = strrep(string(datetime), ':', '-');
      set(0, 'CurrentFigure', fighandle);
      savefig(fullfile(folder, strcat(figname, '.fig')));
      exportgraphics(fighandle, fullfile(folder, strcat(figname, kwargs.extension)), Resolution = kwargs.resolution)
    end
end