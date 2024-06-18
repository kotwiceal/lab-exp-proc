function resfun = guitfest(tf, kwargs)
    %% Interactive LTI system identification by specified transfer function.

    arguments
        tf double
        kwargs.f (1,:) double = []
        kwargs.fs (1,:) double = []
        kwargs.docked logical = false
        kwargs.xscale (1,:) char {mustBeMember(kwargs.xscale, {'linear', 'log'})} = 'log'
        kwargs.yscale (1,:) char {mustBeMember(kwargs.yscale, {'linear', 'log'})} = 'log'
        kwargs.xlabel (1,:) char = 'f, Hz'
        kwargs.ylim (1,:) double = []
    end

    if isempty(kwargs.f); kwargs.f = 1:size(tf, 1); end 
    freq2ind = @(ind) kwargs.f>=ind(1)&kwargs.f<=ind(2);
    if isempty(kwargs.fs); kwargs.fs = 2*kwargs.f(end); end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
    
    axmag = nexttile; hold(axmag, 'on'); grid(axmag, 'on'); box(axmag, 'on'); set(axmag, XScale = kwargs.xscale, YScale = kwargs.yscale);
    pltmagraw = plot(axmag, kwargs.f, abs(tf), DisplayName = 'raw'); legend(Location = 'Best')
    if ~isempty(kwargs.xlabel); xlabel(axmag, kwargs.xlabel); end; ylabel(axmag, '|H|');

    kwargs.ylim = get(axmag, 'YLim');

    axphase = nexttile; hold(axphase, 'on'); grid(axphase, 'on'); box(axphase, 'on');  set(axphase, XScale = kwargs.xscale);
    phaseraw = unwrap(angle(tf));
    pltphaseraw = plot(axphase, kwargs.f, phaseraw, DisplayName = 'raw'); legend(Location = 'Best')
    if ~isempty(kwargs.xlabel); xlabel(axphase, kwargs.xlabel); end; ylabel(axphase, 'arg(H)');

    rois = guiselectregion(axmag, shape = 'rect', mask = [], number = 1, ...
        moved = @moved, moving = @moving);
    moved();
    moving();

    sys = {}; model = {}; ind = []; pltmagmod = []; pltmagphase = [];

    function moving(~,~)
        temp = get(axmag, 'YLim');
        rois{1}.Position(2) = temp(1);
        rois{1}.Position(4) = temp(1)+temp(2);
    end

    function moved(~,~)
        pos = rois{1}.Position; freq = [pos(1), pos(1)+pos(3)]; ind = freq2ind(freq);
    end

    function result = procest(np, nz)
        sys = idfrd(tf(ind), kwargs.f(ind), 1/kwargs.fs);
        model = tfest(sys, np, nz);
        result.mod = model;
        result.sys = sys;
        plotbode();
    end

    function plotbode()
        delete(pltmagmod); delete(pltmagphase);
        [mag, phase, f] = bode(model); phase = deg2rad(squeeze(phase(1,1,:)));
        [f, p] = prepareCurveData(f, phase);
        fobj = fit(f, p, 'linearinterp');
        a = linspace(-200, 200, 200);
        [~, i] = min(norm(phaseraw-fobj(kwargs.f)-a), [], 'all');
        pltmagmod = plot(axmag, f, squeeze(mag(1,1,:)), DisplayName = 'model'); ylim(axmag, kwargs.ylim);
        pltmagphase = plot(axphase, f, phase-a(i), DisplayName = 'model');
    end

    resfun = @procest;

end