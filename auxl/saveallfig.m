function saveallfig(kwargs)
    arguments
        kwargs.folder (1,:) char = []
        kwargs.resolution (1,1) = 600
        kwargs.extension (1,:) = '.png'
    end
    
    if ~isempty(kwargs.folder)
        try
            mkdir(kwargs.folder)
        catch
        end
    end

    figlist = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:numel(figlist)
      fighandle = figlist(iFig);
      figname = strrep(string(datetime), ':', '-');
      set(0, 'CurrentFigure', fighandle);
      savefig(fullfile(kwargs.folder, strcat(figname, '.fig')));
      exportgraphics(fighandle, fullfile(kwargs.folder, strcat(figname, kwargs.extension)), Resolution = kwargs.resolution)
    end
end