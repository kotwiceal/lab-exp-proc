function varargout = guicfi(kwargs)
%% Interactive cross-flow instability amplitude analysis.
%% The function takes following arguments:
%   data:               [struct]            - stucture of PIV data reterned by import_vc7 function
%   number:             [1×1 double]        - count of selection regions

%   fillmissmeth:       [char array]        - method of filling missing data
%   prefilter:          [char array]        - prefiltering velocity field
%   prefiltker:         [1×2 double]        - kernel of prefilter

%   normspec:           [char array]        - spectra norm
%   shift:              [1×1 logical]       - shift a low frequency to middle domain
%   lowfilt:            [char array]        - high-pass filter to substract mean field
%   lowfiltker:         [1×2 double]        - kernel size of high-pass filter
%   winfun:             [char array]        - window funtion at Fourier transform
%   intlim:             [1×4 double]        - range of spectra integration
%   postfitler:         [char array]        - portfiltering of processed amplitude profiles
%   postfiltkernel:     [1×2 double]        - kernel of postfilter
%
%   yi:                 [1×1 double]        - vectical node index
%   xi:                 [1×1 double]        - longitudinal node index
%   mask:               [1×4 double]        - edge size to rectangle selection
%   interaction:        [char array]        - region selection behaviour
%   aspect:             [char array]        - axis ratio
%   climvel:            [1×2 double]        - color limit of velocity field
%   climspec:           [1×2 double]        - color limit of spectra field
%   cscalespec:         [char array]        - color axis scale of spectra field
%   scaleampinc:        [char array]        - y-axis scale of increment curves plot
%   display:            [char array]        - display stady and/or travel modes plots
%   docked:             [1×1 logical]       - docked figure
%   colormap:           [char array]        - colormap of 2D field
%   normvelprof:        [1×1 logical]       - to norm velocity profiles
%% Examples
%% process amplitude profiles of steady and travel modes by custom integration limits in two frames
% guicfi(data = data, mask = [200, 100, 100, 200], number = 2, intlim = [30, 30, 50, 50]);

    arguments
        %% data parameters
        kwargs.data struct
        kwargs.number double = 1
        %% preprocessing parameters
        kwargs.fillmissmeth (1,:) char {mustBeMember(kwargs.fillmissmeth, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        kwargs.prefilter (1,:) char {mustBeMember(kwargs.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltkernel double = [3, 3]
        %% spectra processing parameters
        kwargs.normspec (1,:) char {mustBeMember(kwargs.normspec, {'none', 'psd'})} = 'psd'
        kwargs.shift logical = true
        kwargs.lowfilt (1,:) char {mustBeMember(kwargs.lowfilt, {'none', 'average', 'gaussian'})} = 'average'
        kwargs.lowfiltker double = [5, 5]
        kwargs.winfun char {mustBeMember(kwargs.winfun, {'none', 'hann', 'gaussian'})} = 'hann'
        kwargs.intlim double = [10, 25, 10, 40]
        %% postprocessing parameters
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'movmean', 'movmedian', 'gaussian', 'lowess', 'loess', 'rlowess', 'rloess', 'sgolay'})} = 'movmean'
        kwargs.postfiltker double = 3
        %% roi and axis parameters
        kwargs.yi double = 1
        kwargs.xi double = 1
        kwargs.mask (:,:) double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal'
        kwargs.climvel double = [];
        kwargs.climspec double = [];
        kwargs.cscalespec (1,:) char {mustBeMember(kwargs.cscalespec, {'linear', 'log'})} = 'log'
        kwargs.scaleampinc (1,:) char {mustBeMember(kwargs.scaleampinc, {'linear', 'log'})} = 'log'
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'steady', 'travel', 'steady-travel'})} = 'steady-travel'
        kwargs.docked logical = false
        kwargs.colormap (1,:) char = 'turbo'
        kwargs.normvelprof logical = true
    end

    vm = hypot(kwargs.data.u, kwargs.data.w);
    vmm = squeeze(mean(vm, 3));
    sz = size(vm);

    % fillmissing
    if kwargs.fillmissmeth ~= "none"
        for i = 1:prod(sz(3:end)); vm(:,:,i) = fillmissing2(vm(:,:,i), kwargs.fillmissmeth); end
        vm = reshape(vm, sz);
    end

    % prefiltering
    switch kwargs.prefilter
        case 'average'
            kernel = fspecial(kwargs.prefilter, kwargs.prefiltkernel);
            vm = imfilter(vm, kernel);
        case 'gaussian'
            kernel = fspecial(kwargs.prefilter, kwargs.prefiltkernel);
            vm = imfilter(vm, kernel);
        case 'median'
            kernel = kwargs.prefiltkernel;
            for i = 1:prod(sz(3:end)); vm(:, :, i) = medfilt2(vm(:, :, i), kernel); end
        case 'wiener'
            kernel = kwargs.prefiltkernel;
            for i = 1:prod(sz(3:end)); vm(:, :, i) = wiener2(vm(:, :, i), kernel); end
    end

    colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], ...
        [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

    raw = [];
    specstead = []; spectrav = [];
    velavg = []; velavgs = [];
    amps = []; ampss = []; ampt = []; ampts = [];
    ampsinc = []; amptinc = [];

    roispec = {};

    selectraw = @(roiobj) guigetdata(roiobj, vm, shape = 'cut');

    function [specstead, spectrav, raws, velavg] = specproc(raw)
        raw = permute(raw, [1, 2, 4, 5, 3]); 
        sz = size(raw); 
        raws = squeeze(mean(raw, 5));
        velavg = squeeze(mean(raw, [1, 2, 5]));
        switch kwargs.lowfilt
            case 'average'
                rawlf = imfilter(raw, fspecial(kwargs.lowfilt, kwargs.lowfiltker));
                raw = raw - squeeze(mean(rawlf, 5));
            case 'gaussian'
                rawlf = imfilter(raw, fspecial(kwargs.lowfilt, kwargs.lowfiltker));
                raw = raw - squeeze(mean(rawlf, 5));
        end
        switch kwargs.winfun
            case 'hann'
                win = hann(sz(1)).*hann(sz(2))';
                raw = raw.*win;
            case 'tukeywin'
                win = tukeywin(sz(1), 1).*tukeywin(sz(2), 1)';
                raw = raw.*win;
        end
        specstead = abs(fft2(mean(raw, 5))).^2;
        spectrav = abs(fft2(raw)).^2;
        if kwargs.shift
            specstead = fftshift(fftshift(specstead, 1), 2);
            spectrav = fftshift(fftshift(spectrav, 1), 2);
        end
        switch kwargs.normspec
            case 'psd'
                specstead = specstead ./ prod(sz(1:2));
                spectrav = spectrav ./ prod(sz(1:2));
        end
        spectrav = squeeze(mean(spectrav, 5)) - specstead;
    end

    function plot_spec(ax, spec, label)
        cla(ax); imagesc(ax, spec(:,:,kwargs.yi,kwargs.xi));
        axis(ax, kwargs.aspect); clb = colorbar(ax); colormap(ax, kwargs.colormap); 
        title(clb, kwargs.normspec);
        if ~isempty(kwargs.climspec); clim(ax, kwargs.climspec); end
        set(ax, 'ColorScale', kwargs.cscalespec); title(ax, label, 'FontWeight', 'Normal');
        xlabel(ax, '\alpha_{n}'); ylabel(ax, '\beta_{n}');
    end

    function eventroisel(~, ~)
        raw = []; % accumulate data
        for i = 1:length(rois); raw = cat(5, raw, selectraw(rois{i})); end
        [specstead, spectrav, ~, velavg] = specproc(raw);
        if kwargs.normvelprof; velavg = velavg ./ max(velavg, 1); end
        switch kwargs.display
            case 'steady'
                plot_spec(axspecs, specstead, 'steady')
            case 'travel'
                plot_spec(axspect, spectrav, 'travel')
            case 'steady-travel'
                plot_spec(axspecs, specstead, 'steady')
                plot_spec(axspect, spectrav, 'travel')
        end
        initspecsel();
    end

    function eventintspec(~, ~)
        kwargs.intlim = roispec{1}.Position;

        specsteadprobe = guigetdata(roispec{1}, specstead, shape = 'cut');
        amps = squeeze(sqrt(sum(specsteadprobe, [1, 2])));
        ampss = smoothdata(amps, 1, kwargs.postfilt, kwargs.postfiltker);
        ampsinc = max(ampss, [], 1);

        spectravprobe = guigetdata(roispec{1}, spectrav, shape = 'cut');
        ampt = squeeze(sqrt(sum(spectravprobe, [1, 2])));
        ampts = smoothdata(ampt, 1, kwargs.postfilt, kwargs.postfiltker);
        amptinc = max(ampts, [], 1);

        velavgs = smoothdata(velavg, 1, kwargs.postfilt, kwargs.postfiltker);

        switch kwargs.display
            case 'steady'
                plot_amp(axamps, amps, ampss, 'steady')
            case 'travel'
                plot_amp(axampt, ampt, ampts, 'travel')
            case 'steady-travel'
                plot_amp(axamps, amps, ampss, 'steady')
                plot_amp(axampt, ampt, ampts, 'travel')
        end

        plot_amp_inc();
    end

    function initspecsel()
        roispec = guiselectregion(axspecs, @eventintspec, shape = 'rect', ...
            mask = kwargs.intlim, interaction = kwargs.interaction, number = 1);
        eventintspec();
    end

    function plot_amp(ax, amp_raw, amp_smooth, label)
        cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
        for i = 1:size(amp_raw, 2)
            j = rem(i, numel(colors));
            if j == 0; j = 1; end
            plot(ax, amp_raw(:,j), 'Color', [colors{j}, 0.4]); 
            plot(ax, amp_smooth(:,j), 'Color', colors{j});
        end
        xlabel(ax, 'y_n'); ylabel(ax, 'amp');
        title(ax, label, 'FontWeight', 'Normal');
    end

    function plot_amp_inc()
        cla(axampinc); hold(axampinc, 'on'); grid(axampinc, 'on'); box(axampinc, 'on');
        set(axampinc, 'YScale', kwargs.scaleampinc);
        plot(axampinc, ampsinc, 'DisplayName', 'steady');
        plot(axampinc, amptinc, 'DisplayName', 'travel');
        xlabel(axampinc, 'x_n'); ylabel(axampinc, 'max(amp)');
        title(axampinc, 'increment', 'FontWeight', 'Normal');
        legend(axampinc);
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); nexttile; axroi = gca; 
    imagesc(axroi, vmm(:,:,kwargs.yi));
    colormap(axroi, kwargs.colormap);
    if ~isempty(kwargs.climvel); clim(ax, kwargs.climvel); end
    xlabel(axroi, 'x_n'); ylabel(axroi, 'z_n');

    switch kwargs.display
        case 'steady'
            nexttile; axspecs = gca;
            nexttile; axamps = gca;
        case 'travel'
            nexttile; axspect = gca;
            nexttile; axampt = gca;
        case 'steady-travel'
            nexttile; axspecs = gca;
            nexttile; axspect = gca;
            nexttile; axamps = gca;
            nexttile; axampt = gca;
    end

    nexttile; axampinc = gca;

    rois = guiselectregion(axroi, @eventroisel, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);

    eventroisel();

end