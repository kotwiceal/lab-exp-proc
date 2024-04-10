function varargout = guicta(kwargs)
    %% Visualize CTA scanning results.
    
    %% Examples:
    %% 1. Load cta measurements, calculate auto-spectra and visualize (struct notation):
    % data = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931', output = 'struct');
    % dataprep = prepcta(p1, output = 'struct');
    % guicta(struct = dataprep);

    %% 2. Load cta measurements, calculate auto-spectra and visualize (array notation):
    % [scan, data, raw] = loadcta('C:\Users\morle\Desktop\swept_plate\01_02_24\240201_175931');
    % [spec, f, vel, x, y, z] = prepcta(raw, scan = scan);
    % guicta(spec = spec, f = f, vel = vel);

    arguments
        kwargs.struct {mustBeA(kwargs.struct, {'struct'})} = struct([]) % structude reterned by loadcta()
        kwargs.freq double = [] % frequency vector
        kwargs.spec double = [] % auto-spectra
        kwargs.scan double = [] % scanning table
        kwargs.vel double = [] % velocity
        kwargs.limit double = [] % integration limit
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'x-y', 'y-z', 'y', 'z'})} = 'x-y' % displaying type
        kwargs.dispstack logical = false
        kwargs.u0 double = 27.3 % reference velocity
        kwargs.growth logical = false % to show growth curves
        kwargs.x double = [] % longitudinal coordinate vector
        kwargs.y double = [] % vertical coordinate vector
        kwargs.z double = [] % transversal coordinate vector
        kwargs.reshape (1,:) double = [] % reshape specta, velocity and coordinates
        %% roi and axis parameters
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log' % scale of x-axis of spectra plot
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log' % scale of y-axis of spectra plot
        kwargs.displayname {mustBeA(kwargs.displayname, {'double', 'string', 'char', 'cell'})} = []
        kwargs.docked logical = true % docked figure
        kwargs.pbaspect logical = false % figure title
        kwargs.fontsize (1,1) double = 14 % axis font size
        kwargs.title = [] % figure title
        kwargs.filename (1, :) char = [] % filename of storing figure
        kwargs.extension (1, :) char = '.png' % extension of storing figure
    end

    if ~isempty(kwargs.struct)
        kwargs.freq = kwargs.struct.f;
        kwargs.spec = kwargs.struct.spec;
        kwargs.vel = kwargs.struct.vel;
        kwargs.x = kwargs.struct.x;
        kwargs.y = kwargs.struct.y;
        kwargs.z = kwargs.struct.z;
    end

    sz = size(kwargs.spec); amp = [];

    if isempty(kwargs.freq)
        kwargs.freq = 1:sz(1);
        xlab = 'f_{n}';
    else
        xlab = 'f, Hz';
    end

    function result = getdatafunc()
        result = struct(amp = amp);
    end

    function procamp()
        df = [rois{1}.Position(1), rois{1}.Position(1)+rois{1}.Position(3)];
        temp = get(axroi, 'YLim'); 
        rois{1}.Position = [rois{1}.Position(1), temp(1), rois{1}.Position(3), temp(2)-temp(1)];
        index = kwargs.freq>df(1)&kwargs.freq<=df(2);
        deltaf = kwargs.freq(2)-kwargs.freq(1);
        amp = squeeze(sqrt(deltaf*sum(kwargs.spec(index, :), 1)));
        if ~ismatrix(kwargs.spec)
            amp = reshape(amp, sz(2:end));
        end
        if ~isempty(kwargs.u0)
            amp = amp./kwargs.u0;
        end
        if ~isempty(kwargs.reshape)
            amp = reshape(amp, kwargs.reshape);
        end
    end

    function plotamp()
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');
        switch kwargs.display
            case 'x-y'
                plot(ax, kwargs.y, amp, '.-')
                if isempty(kwargs.u0)
                    ylabel(ax, 'u`');
                else
                    ylabel(ax, 'u`/u_0');
                end
            case 'y-z'
                if isempty(kwargs.y) && isempty(kwargs.z) && isvector(kwargs.y) && isvector(kwargs.z)
                    surf(ax, amp)
                else
                    surf(ax, kwargs.y, kwargs.z, amp)
                end
                colorbar(ax)
                if isempty(kwargs.u0)
                    zlabel(ax, 'u`');
                else
                    zlabel(ax, 'u`/u_0');
                end
                xlabel('y'); ylabel('z');
                view(ax, [-30, 30])
            case 'y'
                if isempty(kwargs.y); kwargs.y = 1:numel(amp); end
                plot(ax, kwargs.y, amp, '.-');
                if isempty(kwargs.u0); ylabel(ax, 'u`, m/s'); else; ylabel(ax, 'u`/u_0'); end
                xlabel('y, mm');
            case 'z'
                if isempty(kwargs.z); kwargs.z = 1:numel(amp); end
                plot(ax, kwargs.z, amp, '.-');
                if isempty(kwargs.u0); ylabel(ax, 'u`, m/s'); else; ylabel(ax, 'u`/u_0'); end
                xlabel('z, mm');
        end
        set(gca, 'FontSize', kwargs.fontsize);
        if ~isempty(kwargs.pbaspect); pbaspect([1, 1, 1]); end
    end

    function plotgrowth()
        if kwargs.growth
            cla(axgrw); hold(axgrw, 'on'); box(axgrw, 'on'); grid(axgrw, 'on');
        
            if isvector(amp)
                grw = max(amp(:));
            else
                grw = squeeze(max(amp, [], 1));
            end
    
            plot(axgrw, grw, '.-');
            ylabel(axgrw, 'max(u`)');
        end
    end

    function event(~, ~)
        procamp();
        plotamp();
        plotgrowth();
    end

    if kwargs.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout('flow');

    if ~isempty(kwargs.spec)
        nexttile; hold on; grid on; box on;
        axroi = gca;
        if kwargs.dispstack
            sz = size(kwargs.spec);
            if isempty(kwargs.z)
                kwargs.z = repmat(1:sz(3), [sz(2), 1]);
            end
            for i = 1:sz(2)
                for j = 1:sz(3)
                    plot3(axroi, kwargs.freq, kwargs.z(i,j)*ones(1, sz(1)), kwargs.spec(:,i,j));  
                end
            end
            set(axroi, 'ZScale', kwargs.yscale, 'XScale', kwargs.xscale, 'FontSize', kwargs.fontsize);
            view(axroi, [-30, 30]);
            xlabel(axroi, xlab); ylabel('z'); zlabel('PSD');
            pbaspect([1 5 1]) 
        else
            set(axroi, 'YScale', kwargs.yscale, 'XScale', kwargs.xscale, 'FontSize', kwargs.fontsize);
            plot(axroi, kwargs.freq, kwargs.spec(:,:));   
            xlabel(axroi, xlab); ylabel('PSD');
        end
    
        if ~isempty(kwargs.pbaspect); pbaspect([1, 1, 1]); end

        if ~isempty(kwargs.limit)
            mask = [kwargs.limit(1), 0, kwargs.limit(2)-kwargs.limit(1), 1];
        else
            mask = [];
        end

        nexttile; ax = gca; hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');

        if kwargs.growth
            nexttile; axgrw = gca; hold(axgrw, 'on'); box(axgrw, 'on'); grid(axgrw, 'on');
        end

        rois = guiselectregion(axroi, moved = @event, shape = 'rect', ...
            mask = mask, interaction = kwargs.interaction, number = 1);

        event();
    end

    % plot velocity
    if ~isempty(kwargs.vel)
        nexttile; hold on; grid on; box on; pbaspect([1, 1, 1]); 
        switch kwargs.display
            case 'x-y'
                if isempty(kwargs.x) && isempty(kwargs.y) && isvector(kwargs.x) && isvector(kwargs.y)
                    surf(kwargs.vel)
                else
                    surf(kwargs.x, kwargs.y, kwargs.vel)
                end
                xlabel('x'); ylabel('y'); zlabel('u, m/s');
                view([-30, 30])
            case 'y-z'
                if isempty(kwargs.y) && isempty(kwargs.z) && isvector(kwargs.y) && isvector(kwargs.z)
                    surf(kwargs.vel)
                else
                    surf(kwargs.y, kwargs.z, kwargs.vel)
                end
                xlabel('y'); ylabel('z'); zlabel('u, m/s');
                view([-30, 30])
            case 'y'
                if isempty(kwargs.y)
                    kwargs.y = 1:numel(kwargs.vel);
                end
                plot(kwargs.y, kwargs.vel, '.-');
                ylabel('u, m/s');
            case 'z'
                if isempty(kwargs.z)
                    kwargs.z = 1:numel(kwargs.vel);
                end
                plot(kwargs.z, kwargs.vel, '.-');
                ylabel('u, m/s');
        end
    end

    if ~isempty(kwargs.title)
        sgtitle(kwargs.title, 'FontSize', kwargs.fontsize);
    end

    varargout{1} = @getdatafunc;

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

end