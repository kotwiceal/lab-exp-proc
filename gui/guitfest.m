function resfun = guitfest(tf, kwargs)
    %% Interactive LTI system identification by specified transfer function.

    arguments
        tf double
        kwargs.f (1,:) double = []
        kwargs.fs (1,:) double = []
        kwargs.frange (1,:) double = []
        kwargs.docked logical = false
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.xlabel (1,:) char = 'f, Hz'
        kwargs.ylim (1,:) double = []
    end

    sys = {}; model = {}; ind = []; pltmagmod = []; pltmagphase = [];

    colors = colororder;
    if isempty(kwargs.f); kwargs.f = 1:size(tf, 1); end 
    freq2ind = @(ind) kwargs.f>=ind(1)&kwargs.f<=ind(2);
    if isempty(kwargs.fs); kwargs.fs = 2*kwargs.f(end); end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
    
    axmag = nexttile; hold(axmag, 'on'); grid(axmag, 'on'); box(axmag, 'on'); set(axmag, XScale = kwargs.xscale, YScale = kwargs.yscale);
    pltmagraw = plot(axmag, kwargs.f, abs(tf), DisplayName = 'raw', Color = colors(1,:)); legend(Location = 'Best')
    if ~isempty(kwargs.xlabel); xlabel(axmag, kwargs.xlabel); end; ylabel(axmag, '|H|');

    kwargs.ylim = get(axmag, 'YLim');

    axphase = nexttile; hold(axphase, 'on'); grid(axphase, 'on'); box(axphase, 'on');  set(axphase, XScale = kwargs.xscale);
    phaseraw = unwrap(angle(tf));
    pltphaseraw = plot(axphase, kwargs.f, phaseraw, DisplayName = 'raw', Color = colors(1,:)); legend(Location = 'Best')
    if ~isempty(kwargs.xlabel); xlabel(axphase, kwargs.xlabel); end; ylabel(axphase, 'arg(H)');

    if isempty(kwargs.frange)
        kwargs.mask = [];
    else
        yl = get(axmag,'Ylim');
        kwargs.mask = [kwargs.frange(1), yl(1), kwargs.frange(2)-kwargs.frange(1), yl(2)-yl(1)];
    end

    rois = guiselectregion(axmag, shape = 'rect', mask = kwargs.mask, number = 1, ...
        moved = @moved, moving = @moving);
    moved();
    moving();

    function moving(~,~)
        temp = get(axmag, 'YLim');
        rois{1}.Position(2) = temp(1);
        rois{1}.Position(4) = temp(1)+temp(2);
    end

    function moved(~,~)
        pos = rois{1}.Position; freq = [pos(1), pos(1)+pos(3)]; ind = freq2ind(freq);
    end

    function result = procest(np, nz, phaseshift)
        sys = idfrd(tf(ind), kwargs.f(ind), 1/kwargs.fs);
        model = tfest(sys, np, nz);
        result.mod = model;
        result.sys = sys;
        plotbode(phaseshift);
    end

    function plotbode(phaseshift)
        delete(pltmagmod); delete(pltmagphase);
        [mag, phase, f] = bode(model); phase = unwrap(deg2rad(squeeze(phase(1,1,:))));
        pltmagmod = plot(axmag, f, squeeze(mag(1,1,:)), DisplayName = 'model', Color = colors(2,:)); 
        ylim(axmag, kwargs.ylim);
        pltmagphase = plot(axphase, f, phase+phaseshift, DisplayName = 'model', Color = colors(2,:));
    end

    resfun = @procest;

end