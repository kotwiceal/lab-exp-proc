function guicta(kwargs)
%% Visualize CTA scanning results.
%% The function takes following arguments:
%   struct:         [struct]            - structude reterned by loadcta()
%   freq:           [k×1 double]        - frequency vector
%   spec:           [k×m double]        - auto-spectra
%   scan:           [n×10×m double]     - scanning table
%   vel:            [m×1 double]        - velocity
%   limit:          [1×2 double]        - integration limit
%   display:        [char array]        - displaying type
%   dispstack:      [1×1 logical]       -
%   u0:             [1×1 double]        - reference velocity
%   growth:         [1×1 logical]       - to show growth curves
%   interaction:    [char array]        - region selection behaviour
%   xscale:         [char array]        - scale of x-axis of spectra plot
%   yscale:         [char array]        - scale of y-axis of spectra plot
%   docked:         [1×1 logical]       - docked figure
%   title:          [char array]
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
        kwargs.struct {mustBeA(kwargs.struct, {'struct'})} = struct([])
        kwargs.freq double = []
        kwargs.spec double = []
        kwargs.scan double = []
        kwargs.vel double = []
        kwargs.limit double = []
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'x-y', 'y-z', 'y', 'z'})} = 'x-y'
        kwargs.dispstack logical = false
        kwargs.u0 double = 27.3
        kwargs.growth logical = false
        kwargs.x double = []
        kwargs.y double = []
        kwargs.z double = []
        %% roi and axis parameters
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.docked logical = true
        kwargs.title = []
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

    function procamp()
        df = [rois{1}.Position(1), rois{1}.Position(1)+rois{1}.Position(3)];
        temp = get(axroi, 'YLim'); 
        rois{1}.Position = [rois{1}.Position(1), temp(1), rois{1}.Position(3), temp(2)-temp(1)];
        index = kwargs.freq>df(1)&kwargs.freq<=df(2);
        % amp = squeeze(sqrt(sum(kwargs.spec(index, :), 1)))/size(kwargs.spec, 1);
        amp = squeeze(sqrt(sum(kwargs.spec(index, :), 1)));
        if ~ismatrix(kwargs.spec)
            amp = reshape(amp, sz(2:end));
        end
        if ~isempty(kwargs.u0)
            amp = amp./kwargs.u0;
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
                if isempty(kwargs.y)
                    kwargs.y = 1:numel(amp);
                end
                plot(ax, kwargs.y, amp, '.-');
            case 'z'
                if isempty(kwargs.z)
                    kwargs.z = 1:numel(amp);
                end
                plot(ax, kwargs.z, amp, '.-');
        end
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
            for i = 1:sz(2)
                for j = 1:sz(3)
                    plot3(axroi, kwargs.freq, kwargs.z(i,j)*ones(1, sz(1)), kwargs.spec(:,i,j));  
                end
            end
            set(axroi, 'ZScale', kwargs.yscale, 'XScale', kwargs.xscale);
            view(axroi, [-30, 30]);
            xlabel(axroi, xlab); ylabel('z'); zlabel('PSD');
            pbaspect([1 5 1]) 
        else
            set(axroi, 'YScale', kwargs.yscale, 'XScale', kwargs.xscale);
            plot(axroi, kwargs.freq, kwargs.spec(:,:));   
            xlabel(axroi, xlab); ylabel('PSD');
        end
    
        if ~isempty(kwargs.limit)
            mask = [kwargs.limit(1), 0, kwargs.limit(2)-kwargs.limit(1), 1];
        else
            mask = [];
        end

        nexttile; ax = gca; hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');

        if kwargs.growth
            nexttile; axgrw = gca; hold(axgrw, 'on'); box(axgrw, 'on'); grid(axgrw, 'on');
        end

        rois = guiselectregion(axroi, @event, shape = 'rect', ...
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
        sgtitle(kwargs.title)
    end

end