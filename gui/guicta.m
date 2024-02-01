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
%   u0:             [1×1 double]        - reference velocity
%   growth:         [1×1 logical]       - to show growth curves
%   interaction:    [char array]        - region selection behaviour
%   xscale:         [char array]        - scale of x-axis of spectra plot
%   yscale:         [char array]        - scale of y-axis of spectra plot
%   docked:         [1×1 logical]       - docked figure

    arguments
        kwargs.struct {mustBeA(kwargs.struct, {'struct'})} = struct([])
        kwargs.freq double = []
        kwargs.spec double = []
        kwargs.scan double = []
        kwargs.vel double = []
        kwargs.limit double = []
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'x-y', 'y-z', 'y'})} = 'x-y'
        kwargs.u0 double = 27.3
        kwargs.growth logical = false
        %% roi and axis parameters
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.docked logical = false
    end

    if ~isempty(kwargs.struct)
        kwargs.freq = kwargs.struct.f;
        kwargs.spec = kwargs.struct.spec;
        kwargs.vel = kwargs.struct.vel;
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
        amp = squeeze(sqrt(sum(kwargs.spec(index, :), 1)))/size(kwargs.spec, 1);
        if ~ismatrix(kwargs.spec)
            amp = reshape(amp, sz(2:end));
        end
        if ~isempty(kwargs.u0)
            amp = amp./kwargs.u0;
        end
    end

    function event(~, ~)
        procamp()
        cla(ax); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on');

        switch kwargs.display
            case 'x-y'
                plot(ax, amp, '.-')
                if isempty(kwargs.u0)
                    ylabel(ax, 'u`');
                else
                    ylabel(ax, 'u`/u_0');
                end
            case 'y-z'
                imagesc(ax, amp)
                colorbar(ax)
            case 'y'
                plot(ax, amp, '.-');
        end

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

    if kwargs.docked
        figure('WindowStyle', 'Docked')
    else
        clf;
    end
    tiledlayout('flow');

    if ~isempty(kwargs.spec)
        nexttile; hold on; grid on; box on;
        axroi = gca; set(axroi, 'YScale', kwargs.yscale, 'XScale', kwargs.xscale);
        plot(axroi, kwargs.freq, kwargs.spec(:,:));     
        xlabel(axroi, xlab); ylabel('PSD');
    
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

    if ~isempty(kwargs.vel)
        nexttile; hold on; grid on; box on; pbaspect([1, 1, 1]); 
        switch kwargs.display
            case 'x-y'
                plot(kwargs.vel, '.-');
                ylabel('u');
            case 'y-z'
                imagesc(kwargs.vel)
            case 'y'
                plot(kwargs.vel, '.-');
                ylabel('u');
        end
    end

end