function saf(path, kwargs, options)
    %%  Save all figures as `*.fig` and `*.{extension}`.

    arguments
        path {mustBeTextScalar} = [] % image/figure storing folder
        kwargs.resolution (1,1) = 300 % image DPI resolution
        kwargs.extension (1,:) char = '.png'
        kwargs.md {mustBeTextScalar}  = '' % markdown file to insert plot links
        kwargs.units {mustBeMember(kwargs.units, {'pixels', 'normalized', 'inches', 'centimeters', 'points', 'characters'})} = 'centimeters'
        kwargs.fontsize (1,:) double = []
        kwargs.fontunits {mustBeMember(kwargs.fontunits, {'points', 'inches', 'centimeters', 'normalized', 'pixels'})} = 'centimeters'
        kwargs.size (1,:) double = [] % set figure size
        kwargs.pause (1,1) = 2 % delay for successful figure appearances changing and saving
        kwargs.mdsize = 400 % markdown image attachment size
        kwargs.mdfig (1,1) logical = true % insert `.fig` attachment link
        kwargs.mdtable (1,1) logical = true % wrap attachment links by table
        kwargs.mdtabheader (1,1) logical = false % insert empty row for table header
        kwargs.mdtabalign {mustBeMember(kwargs.mdtabalign, {'left', 'center', 'right'})} = 'center' % align table cells
        kwargs.mdtablayout {mustBeMember(kwargs.mdtablayout, {'flow', 'horizontal', 'vertical'})} = 'flow' % arrange attachment link cells
        kwargs.mdtabsz (1,:) double = [] % markdown table size
        kwargs.save (1,1) logical = true
        kwargs.theme {mustBeMember(kwargs.theme, {'light', 'dark', 'auto'})} = "light"
        kwargs.docked (1,1) logical = true
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

    [~, index] = sort([figlist.Number], 'ascend');
    figlist = figlist(index);

    % wrap attachment links by table
    if kwargs.mdtable & ~isempty(kwargs.md) & kwargs.save
        nfig = numel(figlist);
        if isempty(kwargs.mdtabsz)
            switch kwargs.mdtablayout
                case 'flow'
                    sztab = ceil(sqrt(nfig))*[1,1];
                    if (prod(sztab)-nfig) > sztab(2) - 1
                        sztab(2) = sztab(2) - 1;
                    end
                case 'horizontal'
                    sztab = [1, nfig];
                case 'vertical'
                    sztab = [nfig, 1];
            end
        else
            sztab = kwargs.mdtabsz;
        end
        switch kwargs.mdtabalign
            case 'left'
                breakline = "|:--|";
            case 'center'
                breakline = "|:--:|";
            case 'right'
                breakline = "|--:|";
        end
        tempoarary = repmat("| |", flip(sztab));
        tempoarary(1:nfig) = "| %% |";
        tempoarary = tempoarary';
        if kwargs.mdtabheader
            tempoarary = [repmat("| |", 1, sztab(2)); repmat(breakline,1,  sztab(2)); tempoarary];
        else
            tempoarary = [tempoarary(1,:); repmat(breakline, 1, sztab(2)); tempoarary(2:end,:)];
        end
        tempoarary(:,end) = tempoarary(:,end) + repmat(newline, size(tempoarary, 1), 1);
        tempoarary = strjoin(tempoarary','');
        tempoarary = strrep(tempoarary,"||","|");

        text = string(fileread(kwargs.md));
        text = strjoin(text+newline+tempoarary);
        writelines(text,kwargs.md);
    end

    for iFig = 1:numel(figlist)
        fighandle = figlist(iFig);
        try; theme(fighandle, kwargs.theme); catch; end
        figname = strrep(string(datetime), ':', '-');
        filename = fullfile(folder, figname);
        pause(1)
        
        if ~isempty(kwargs.fontsize)
            fontsize(fighandle, kwargs.fontsize, kwargs.fontunits)
        end

        if ~isempty(kwargs.size)
            set(fighandle, WindowStyle = 'normal')
            set(fighandle, Units = kwargs.units, Position = [0, 0, kwargs.size]);
            pause(kwargs.pause)
        end

        if kwargs.save
            exportgraphics(fighandle, strcat(filename, kwargs.extension), Resolution = kwargs.resolution)
            savefig(fighandle, strcat(filename, '.fig'));
        end

        if ~isempty(kwargs.md) & kwargs.save
            obscontpast(kwargs.md, strcat(figname, kwargs.extension), size = kwargs.mdsize, fig = kwargs.mdfig);
        end

        if kwargs.docked; set(fighandle, WindowStyle = 'docked'); end
    end
end