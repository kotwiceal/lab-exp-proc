function saf(path, kwargs, options)
    %%  Save all figures as `*.fig` and `*.{extension}`.
    arguments
        path {mustBeTextScalar} = []
        kwargs.resolution (1,1) = 300
        kwargs.extension (1,:) char = '.png'
        kwargs.md {mustBeTextScalar}  = ""
        kwargs.units {mustBeMember(kwargs.units, {'pixels', 'normalized', 'inches', 'centimeters', 'points', 'characters'})} = 'centimeters'
        kwargs.fontsize (1,:) double = []
        kwargs.fontunits {mustBeMember(kwargs.fontunits, {'points', 'inches', 'centimeters', 'normalized', 'pixels'})} = 'centimeters'
        kwargs.size (1,:) double = [] 
        options.?matlab.ui.Figure
    end
    
    if ~isempty(path); try mkdir(path); catch; end; end

    if isfile(path)
        folder = fileparts(path);
    else
        folder = path;
    end

    options = namedargs2cell(options);

    figlist = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:numel(figlist)
        fighandle = figlist(iFig);
        figname = strrep(string(datetime), ':', '-');
        filename = fullfile(folder, figname);
        pause(1)
        
        if ~isempty(kwargs.fontsize)
            set(fighandle.Children, fontsize = kwargs.fontsize, fontunits = kwargs.fontunits);
        end

        if ~isempty(kwargs.size)
            set(fighandle, WindowStyle = 'normal')
            pause(2)
            % set(fighandle, options{:}); % advance options
            set(fighandle, Units = kwargs.units, Position = [0, 0, kwargs.size]);
        end

        exportgraphics(fighandle, strcat(filename, kwargs.extension), Resolution = kwargs.resolution)
        savefig(fighandle, strcat(filename, '.fig'));

        try
            obscontpast(kwargs.md, strcat(figname, kwargs.extension));
        catch
        end

      set(fighandle, WindowStyle = 'docked')
    end
end