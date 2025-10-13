test(2,xlabel={'x1','x2'},legend={'title', 'test','show',false})

function test(axnum, axargs)
    arguments
        axnum
        axargs.fontsize = {10, 'pixel'};
        axargs.set = {'colorscale', 'linear', 'LineStyleCyclingMethod', 'aftercolor', ...
            'LineStyleOrder', '-', 'LineStyleOrderIndex', 1};
        axargs.axis = 'auto';
        axargs.colorscale = 'linear';
        axargs.xscale = 'linear';
        axargs.yscale = 'linear';
        axargs.zscale = 'linear';
        axargs.xlabel = '';
        axargs.ylabel = '';
        axargs.zlabel = '';
        axargs.xlim = 'auto';
        axargs.ylim = 'auto';
        axargs.zlim = 'auto';
        axargs.clim = 'auto';
        axargs.grid = 'on';
        axargs.box = 'on';
        axargs.pbaspect = [1,1,1];
        axargs.hold = 'on';
        axargs.colormap = 'turbo';
        axargs.xticks = 'auto';
        axargs.yticks = 'auto';
        axargs.zticks = 'auto';
        axargs.xticklabels = 'auto';
        axargs.yticklabels = 'auto';
        axargs.zticklabels = 'auto';
        axargs.xtickangle = 0;
        axargs.ytickangle = 0;
        axargs.ztickangle = 0;
        axargs.fontname = 'default';
        axargs.legend = {'show', false}
        axargs.colorbar = {'show', false}
        axargs.colororder = 'gem'
        % set.?matlab.graphics.axis.Axes
    end

    % if ~isa(axargs.set{1},'cell'); axargs.set = {axargs.set}; end
    % if ~isa(axargs.legend{1},'cell'); axargs.legend = {axargs.legend}; end
    % if ~isa(axargs.colorbar{1},'cell'); axargs.colorbar = {axargs.colorbar}; end
    % if ~isa(axargs.fontsize{1},'cell'); axargs.fontsize = {axargs.fontsize}; end

    nestparamlist = ["fontsize", "set", "legend", "colorbar"];

    axargs = structfun(@(e) terop(strcmp(nestparamlist), e, {e}), axargs, UniformOutput = false);

    % cellfun(@(s) assignin('caller', 'axargs', 'setfield(axargs, s)'))

    % prepare function handlers
    funcs = cellfun(@(s) str2func(s), fieldnames(axargs), UniformOutput = false);
    funcs = cell2struct(funcs,fieldnames(axargs));
    funcs.colorscale = @(ax,val) set(ax, colorscale = val);
    funcs.legend = @(varargin) handle_legend(varargin{1}, varargin{2:end});
    funcs.colorbar = @(varargin) handle_colorbar(varargin{1}, varargin{2:end});
    funcnames = string(fieldnames(funcs));

    % parse arguments
    [axfuncx, axparams] = parseargs(axnum,axargs);

    % replace custom function handlers
    axfuncx = cellfun(@(axfunc) cellfun(@(f) ...
        terop(strcmp(f,funcnames),str2func(f),funcs.(f)), axfunc, ...
        UniformOutput = false), axfuncx, UniformOutput = false);
    
    % plot
    clf; axs = gca;
    axs = repmat({axs}, 1, axnum);
    cellfun(@(~)contourf(rand(100)),num2cell(1:numel(axs)))

    axsu = unique(axs);

    % customize axes appearance
    cellfun(@(ax,axfunc,axparam) cellfun(@(f,p) f(ax,p{:}), ...
        axfunc, axparam), axsu, axfuncx, axparams)

end

function handle_legend(ax, param)
    arguments
        ax matlab.graphics.axis.Axes
        param.show (1,1) logical = true
        param.title {mustBeA(param.title, {'char', 'string'})} = ''
        param.orientation {mustBeMember(param.orientation, {'vertical', 'horizontal'})} = 'vertical'
        param.location (1,:) char {mustBeMember(param.location, {'north','south','east','west', ...
            'northeast','northwest','southeast','southwest','northoutside','southoutside', ...
            'eastoutside','westoutside','northeastoutside','northwestoutside', ...
            'southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        param.displayname (1,:) {mustBeA(param.displayname, {'char', 'string', 'cell'})} = {}
        param.interpreter {mustBeMember(param.interpreter, {'latex', 'tex', 'none'})} = 'tex'
    end
    if param.show
        l = legend(ax, param.displayname, Location = param.location, ...
            Orientation = param.orientation, Interpreter = param.interpreter); 
        title(l, param.title, FontWeight = 'normal', Interpreter = param.interpreter)
    end
end

function handle_colorbar(ax, param)
    arguments
        ax matlab.graphics.axis.Axes
        param.show (1,1) logical = true
        param.clabel {mustBeA(param.clabel, {'char', 'string'})} = ''
        param.orientation {mustBeMember(param.orientation, {'vertical', 'horizontal'})} = 'vertical'
        param.location (1,:) char {mustBeMember(param.location, {'north','south','east','west', ...
            'northeast','northwest','southeast','southwest','northoutside','southoutside', ...
            'eastoutside','westoutside','northeastoutside','northwestoutside', ...
            'southeastoutside','southwestoutside','best','bestoutside','layout','none'})} = 'best'
        param.Exponent (1,:) double = []
        param.cTickLabelFormat (1,:) char = '%0.1f'
        param.fontsize (1,:) double = []
        param.interpreter {mustBeMember(param.interpreter, {'latex', 'tex', 'none'})} = 'tex'
    end
    if param.show
        c = colorbar(ax, location = param.location, orientation = param.orientation);
        if ~isempty(param.Exponent)
            c.Ruler.Exponent = param.Exponent;
            c.Ruler.TickLabelFormat = param.cTickLabelFormat;  
        end
        set(c.Label, String = param.clabel, Interpreter = param.interpreter, ...
            FontSize = param.fontsize)
    end
end