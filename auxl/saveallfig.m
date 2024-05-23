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
      figname = num2str(get(fighandle, 'Number'));
      set(0, 'CurrentFigure', fighandle);
      savefig(fullfile(kwargs.folder, [figname, '.fig']));
      exportgraphics(fighandle, fullfile(kwargs.folder, [figname, kwargs.extension]), Resolution = kwargs.resolution)
    end
end