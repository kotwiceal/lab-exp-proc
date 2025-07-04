function saf(path, kwargs, options)
    %%  Save all figures as `*.fig` and `*.{extension}`.
    arguments
        path {mustBeTextScalar} = [] % folder to 
        kwargs.resolution (1,1) = 300
        kwargs.extension (1,:) char = '.png'
        kwargs.md {mustBeTextScalar}  = "" % markdown file to paste plots link
        kwargs.units {mustBeMember(kwargs.units, {'pixels', 'normalized', 'inches', 'centimeters', 'points', 'characters'})} = 'centimeters'
        kwargs.fontsize (1,:) double = []
        kwargs.fontunits {mustBeMember(kwargs.fontunits, {'points', 'inches', 'centimeters', 'normalized', 'pixels'})} = 'centimeters'
        kwargs.size (1,:) double = [] % set figure size
        kwargs.pause (1,1) = 2 % delay for successful figure appearances changing and saving
        kwargs.mdsize = 400 % set image size in the markdown file
        kwargs.mdfig (1,1) logical = true % paste .fig file link to markdown file
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
            pause(kwargs.pause)
            % set(fighandle, options{:}); % advance options
            set(fighandle, Units = kwargs.units, Position = [0, 0, kwargs.size]);
        end

        exportgraphics(fighandle, strcat(filename, kwargs.extension), Resolution = kwargs.resolution)
        savefig(fighandle, strcat(filename, '.fig'));

        try
            obscontpast(kwargs.md, strcat(figname, kwargs.extension), size = kwargs.mdsize, fig = kwargs.mdfig);
        catch
        end

        set(fighandle, WindowStyle = 'docked')
    end
end