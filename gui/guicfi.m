function getdata = guicfi(kwargs)
    %% Interactive cross-flow instability amplitude analysis.
    %% The function takes following arguments:
    %   data:               [struct]            - stucture of PIV data reterned by import_vc7 function
    %   number:             [1×1 double]        - count of selection regions

    %   fillmissmeth:       [char array]        - method of filling missing data
    %   prefilter:          [char array]        - prefiltering velocity field
    %   prefiltker:         [1×2 double]        - kernel of prefilter

    %   normspec:           [char array]        - spectra norm
    %   shift:              [1×1 logical]       - shift a zero frequency to middle domain
    %   center:             [char array]        - sustract trend of data
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
    %   normvel:            [1×1 logical]       - to norm velocity profiles
    %% Examples
    %% process amplitude profiles of steady and travel modes by custom integration limits in two frames
    % guicfi(data = data, mask = [200, 100, 100, 200], number = 2, intlim = [30, 30, 50, 50]);

    %% 2. test
    % [x, z] = meshgrid(linspace(0,1,3e2),linspace(0,1,3e2));
    % amp = betapdf(linspace(0,1,20), 2, 5); amp = amp/max(amp);
    % vm = sin(x*40+z*50).*shiftdim(amp, -1).*ones([size(x), numel(amp), 10]);
    % vm = permute(vm, [1, 2, 4, 3]);
    % clf; hold on; view([-30, 30]) ;
    % for i = 1:size(vm, 4)
    %     surf(x, z, vm(:,:,1,i) + i, 'LineStyle', 'None', 'FaceAlpha', 0.8)
    % end
    % colormap turbo;
    % guicfi(vm = vm, yi = 10, lowfilt = 'none', winfun = 'hann', normspec = 'psd')
    %% 3. Test 
    % [x, z] = meshgrid(linspace(0,1,3e2),linspace(0,1,3e2));
    % amp = ones(1, 20);
    % vm = sin(x*40+z*50).*shiftdim(amp, -1).*ones([size(x), numel(amp), 100])+shiftdim(linspace(0, 20, numel(amp)), -1).*(0.8*x+0.1*z);
    % vm = permute(vm, [1, 2, 4, 3]);
    % guicfi(vm = vm, yi = 5, lowfilt = 'average', winfun = 'hann', normspec = 'psd', center = 'poly11', number = 2, mask = [50, 50, 100, 50])
    %% 4. Test separeting steady and travel modes:
    % [x, z] = meshgrid(linspace(0,1,3e2),linspace(0,1,3e2));
    % n = 200;
    % amp = [1, 2, 3];
    % std = sin(x*40+z*50).*shiftdim(amp, -1).*ones([size(x), numel(amp), n]);
    % trv = sin(x*30+z*40).*shiftdim(1, -1).*ones([size(x), numel(amp), n]).*shiftdim(randi([0, 1], 1, n), -2);
    % 
    % vel = std+trv;
    % vel = vel+shiftdim(linspace(0, 20, numel(amp)), -1).*(0.8*x+0.1*z);
    % vel = permute(vel, [1, 2, 4, 3]);
    % 
    % guicfi(vm = vel, yi = 1, lowfilt = 'average', winfun = 'hann', normspec = 'psd', center = 'poly11', number = 1, mask = [50, 50, 100, 200], ...
    %     intlim = [51, 100, 10, 20])

    arguments
        %% data parameters
        kwargs.data struct = struct([])
        kwargs.number double = 1
        kwargs.vm (:,:,:,:) double = []
        kwargs.x (:,:) double = []
        kwargs.z (:,:) double = []
        %% preprocessing parameters
        kwargs.fillmissing (1,:) char {mustBeMember(kwargs.fillmissing, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        kwargs.prefilter (1,:) char {mustBeMember(kwargs.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltker double = [3, 3]
        kwargs.mode (1,:) char {mustBeMember(kwargs.mode, {'spec', 'var'})} = 'spec'
        %% spectra processing parameters
        kwargs.normspec (1,:) char {mustBeMember(kwargs.normspec, {'none', 'psd'})} = 'psd'
        kwargs.shift logical = true
        kwargs.center (1,:) char {mustBeMember( kwargs.center, {'poly11', 'mean', 'none'})} = 'poly11'
        kwargs.winfun char {mustBeMember(kwargs.winfun, {'none', 'hann', 'hamming', 'tukey'})} = 'hann'
        kwargs.intlim double = []
        %% amplitude processing parameters
        kwargs.ampfilt (1,:) char {mustBeMember(kwargs.ampfilt, {'movmean', 'movmedian', 'gaussian', 'lowess', 'loess', 'rlowess', 'rloess', 'sgolay'})} = 'movmean'
        kwargs.ampfiltker (1,1) double = 3
        kwargs.normamp (1,:) char {mustBeMember(kwargs.normamp, {'none', 'u0', 'ue'})} = 'ue'
        kwargs.u0 (1,1) double = 25
        kwargs.y0 double = []
        kwargs.yt double = []
        kwargs.MinProminence (1,1) double = 1e-3
        kwargs.findmax (1,:) char {mustBeMember(kwargs.findmax, {'max', 'islocalmax'})} = 'max'
        %% average velocity processing parameters
        kwargs.velfilt (1,:) char {mustBeMember(kwargs.velfilt, {'movmean', 'movmedian', 'gaussian', 'lowess', 'loess', 'rlowess', 'rloess', 'sgolay'})} = 'movmean'
        kwargs.velfiltker double = 3
        kwargs.normvel logical = true
        %% roi and axis parameters
        kwargs.disptype (1,:) char {mustBeMember(kwargs.disptype, {'node', 'spatial'})} = 'spatial'
        kwargs.yi double = 1
        kwargs.xi double = 1
        kwargs.mask {mustBeA(kwargs.mask, {'double', 'cell'})} = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto', 'square'})} = 'equal'
        kwargs.climvel double = [];
        kwargs.climspec double = [];
        kwargs.cscalespec (1,:) char {mustBeMember(kwargs.cscalespec, {'linear', 'log'})} = 'log'
        kwargs.scaleampinc (1,:) char {mustBeMember(kwargs.scaleampinc, {'linear', 'log'})} = 'log'
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'steady', 'travel', 'steady-travel'})} = 'steady-travel'
        kwargs.docked logical = true
        kwargs.colormap (1,:) char = 'turbo'
        kwargs.showvelavg logical = false
        kwargs.showvelprof logical = true
        kwargs.legend logical = true
        kwargs.guitype (1,:) char {mustBeMember(kwargs.guitype, {'figure', 'uifigure'})} = 'figure'
    end

    warning off;

    x = []; z = []; yn = []; vm = []; sz = []; ds = []; vmm = []; xns = []; 

    switch kwargs.disptype
        case 'node'
            xlabspec = '\alpha_{n}';
            ylabspec = '\beta_{n}';
        case 'spatial'
            xlabspec = '\alpha, mm^{-1}';
            ylabspec = '\beta, mm^{-1}';
    end


    alpha = [];
    beta = [];
    ue = [];
    positions = [];
    xn = 1:kwargs.number;

    colors = colororder('gem');

    selectraw = []; selectx = [];
    raw = [];
    specstead = []; spectrav = [];
    velavg = []; velavgs = []; velavg1d = [];
    amps = []; ampss = []; ampt = []; ampts = [];
    ampsinc = []; amptinc = [];
    ampss_ft = []; ampts_ft = [];

    roispec = {};

    %% prepare data
    function prepdata()
        % matrices parsing of spatial coordinates and velocity fields
        if isempty(kwargs.data)
            vm = kwargs.vm;
            x = kwargs.x;
            z = kwargs.z;
            yn = 1:size(vm, 4);
        else
            vm = hypot(kwargs.data.u, kwargs.data.w);   
            sz = size(vm);
            switch kwargs.disptype
                case 'node'
                    [x, z] = meshgrid(1:sz(1), 1:sz(2));
                case 'spatial'
                    x = kwargs.data.x;
                    z = kwargs.data.z;
                    ds = abs([x(1,1)-x(1,2), z(1,1)-z(2,1)]);
            end
            % define y-vector
            if isfield(kwargs.data, 'y'); yn = kwargs.data.y; else; yn = 1:size(vm, 4); end
        end

        % define offset for y-vector
        if isempty(kwargs.y0); kwargs.y0 = zeros(1, kwargs.number); end
        
        vmm = squeeze(mean(vm, 3)); 
        sz = size(vm);
    
        if isempty(x) && isempty(z)
            kwargs.disptype = 'node'; 
            [x, z] = ngrid(1:sz(2), 1:sz(1));
        end
    
        % fillmissing
        vm = imfilt(vm, filt = 'fillmissing', method = kwargs.fillmissing);
    
        % prefiltering
        vm = imfilt(vm, filt = kwargs.prefilter, filtker = kwargs.prefiltker);
    
        % choose select ROI method
        switch kwargs.disptype
            case 'node'
                selectraw = @(roiobj) guigetdata(roiobj, vm, shape = 'cut', permute = [2, 1]);
                selectx = @(roiobj) guigetdata(roiobj, x, shape = 'cut', permute = [2, 1]);
            case 'spatial'
                selectraw = @(roiobj, s) guigetdata(roiobj, vm, shape = 'cut', size = s, x = x, z = z, permute = [1, 2]);
                selectx = @(roiobj, s) guigetdata(roiobj, x, shape = 'cut', size = s, x = x, z = z, permute = [1, 2]);
        end
    end

    function getvel()
        %% extract data from ROI regions
        raw = []; % accumulate data
        xn = [];
        switch kwargs.disptype
            case 'node'
                for i = 1:length(rois)
                    raw = cat(5, raw, selectraw(rois{i})); 
                    xn = cat(1, xn, mean(selectx(rois{i}), [1, 2]));
                end
            case 'spatial'
                s = round(rois{1}.Position(1,3:end)./ds);
                for i = 1:length(rois)
                    raw = cat(5, raw, selectraw(rois{i}, s)); 
                    xn = cat(1, xn, mean(selectx(rois{i}, s), [1, 2]));
                end
        end
    end

    function [vel, velavg, velavg1d, ue] = prepvel(vel)
        %% prepare velocity data
        vel = permute(vel, [1, 2, 4, 5, 3]);
        szr = size(vel); % [transversal, longitudinal, vertical, selections, frames]
        velavg = squeeze(mean(vel, 5, 'omitmissing')); % averaged velocity fields
        velavg1d = squeeze(mean(velavg, [1, 2], 'omitmissing'));
        ue = max(velavg1d, [], 1);
        if kwargs.normvel; velavg1d = velavg1d ./ max(velavg1d, [], 1); end
        % data centering
        switch kwargs.center
            case 'poly11'
                rawt = nan(szr); rawmt = nan(szr(1:end-1));
                % instantaneous fields
                [x1, z1] = meshgrid(1:szr(2), 1:szr(1));
                parfor i = 1:prod(szr(3:end))
                    try
                        [x2, z2, vm2] = prepareSurfaceData(x1, z1, vel(:,:,i));
                        rawft = fit([x2, z2], vm2, 'poly11');
                        rawt(:,:,i) = vel(:,:,i) - rawft(x1, z1); 
                    catch
                    end
                end
                % average fields
                parfor i = 1:prod(szr(3:end-1))
                    try
                        [x2, z2, vm2] = prepareSurfaceData(x1, z1, velavg(:,:,i));
                        rawft = fit([x2, z2], vm2, 'poly11');
                        rawmt(:,:,i) = velavg(:,:,i) - rawft(x1, z1);
                    catch
                    end
                end
                vel = reshape(rawt, szr);
                velavg = reshape(rawmt, szr(1:end-1));
            case 'mean'
                vel = vel-mean(vel, [1, 2], 'omitmissing');
                velavg = velavg-mean(velavg, [1, 2], 'omitmissing');
        end
    end

    function [specstead, spectrav, alpha, beta] = specproc(vel, velavg)
        %% process spectra of steady and travel modes
        szr = size(vel);
        % data multiplying by window function
        switch kwargs.winfun
            case 'hann'
                win = hann(szr(1)).*hann(szr(2))';
            case 'tukey'
                win = tukeywin(szr(1), 1).*tukeywin(szr(2), 1)';
            otherwise
                win = ones(szr);
        end
        ecf = 1/rms(win(:));
        vel = vel.*win;
        velavg = velavg.*win;

        % calculate spectra
        specstead = abs(fft2(velavg)).^2;
        spectrav = abs(fft2(vel)).^2;
        if kwargs.shift
            specstead = fftshift(fftshift(specstead, 1), 2);
            spectrav = fftshift(fftshift(spectrav, 1), 2);
        end
        % norm specta
        switch kwargs.normspec
            case 'psd'
                specstead = specstead/prod(szr(1:2))^2*ecf^2*2;
                spectrav = spectrav/prod(szr(1:2))^2*ecf^2*2;
        end
        spectrav = squeeze(mean(spectrav, 5)) - specstead;
        % build frequency mesh
        switch kwargs.disptype
            case 'node'
                alpha = [];
                beta = [];
            case 'spatial'
                xu = unique(x); zu = unique(z);
                dx = xu(2)-xu(1); dz = zu(2)-zu(1);
                fdx = 1/dx; fdz = 1/dz;
                
                dfdx = fdx/szr(2);
                dfdy = fdz/szr(1);
                
                alpha = -fdx/2+dfdx/2:dfdx:fdx/2-dfdx/2;
                beta = -fdz/2+dfdy/2:dfdy:fdz/2-dfdy/2;
                
                [alpha, beta] = meshgrid(alpha, beta);
        end
    end

    %% plot spectra, general function
    function plot_spec(ax, spec, label, alpha, beta)
        cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
        if isempty(alpha) && isempty(beta)
            imagesc(ax, spec(:,:,kwargs.yi,kwargs.xi));
            axis(ax, 'equal')
        else
            contourf(ax, alpha, beta, spec(:,:,kwargs.yi,kwargs.xi), 100, 'LineStyle', 'None');
            axis(ax, 'image');
        end
        clb = colorbar(ax); colormap(ax, kwargs.colormap); 
        title(clb, kwargs.normspec);
        if ~isempty(kwargs.climspec); clim(ax, kwargs.climspec); end
        set(ax, ColorScale = kwargs.cscalespec); title(ax, label, FontWeight = 'Normal');
        xlabel(ax, xlabspec); ylabel(ax, ylabspec);
    end

    function eventroisel(~, ~)
        %% event function called when the velocity field selection rectangle is moved
        getvel();

        if kwargs.showvelavg; plot_velavg(axvelavg, raw); end

        [vel, velavg, velavg1d, ue] = prepvel(raw);

        switch kwargs.mode
            case 'spec'
                [specstead, spectrav, alpha, beta] = specproc(vel, velavg);
                switch kwargs.display
                    case 'steady'
                        plotspec(axspecs, specstead, 'steady')
                    case 'travel'
                        plotspec(axspect, spectrav, 'travel')
                    case 'steady-travel'
                        plotspec(axspecs, specstead, 'steady')
                        plotspec(axspect, spectrav, 'travel')
                end
                initspecsel();
            case 'var'
                amps = squeeze(sqrt(mean(var(velavg, [], 1), 2, 'omitmissing')));
                ampt = squeeze(sqrt(var(mean(var(vel, [], 1), 2, 'omitmissing'), [], 5)));
                prepamp();
        end
    end

    function prepamp()

        velavgs = smoothdata(velavg1d, 1, kwargs.velfilt, kwargs.velfiltker);
    
        switch kwargs.normamp
            case 'u0'
                amps = amps/kwargs.u0;
                ampt = ampt/kwargs.u0;
            case 'ue'
                amps = amps./ue;
                ampt = ampt./ue;
        end

        ampss = smoothdata(amps, 1, kwargs.ampfilt, kwargs.ampfiltker);

        switch kwargs.findmax
            case 'max'
                ampsinc = max(ampss, [], 1);
                xns = xn;
            case 'islocalmax'
                index = islocalmax(amps, 1, MinProminence = kwargs.MinProminence);
                ampsinc = amps(index);
                xns = xn(logical(sum(index,1)));
        end

        ampts = smoothdata(ampt, 1, kwargs.ampfilt, kwargs.ampfiltker);

        for i = 1:kwargs.number
            try
                [yf, af] = prepareCurveData(yn+kwargs.y0(i), ampss(:,i));
                ampss_ft{i} = fit(yf, af, 'linearinterp');
            catch
                ampss_ft{i} = @(x)0;
            end
            try
                [yf, af] = prepareCurveData(yn+kwargs.y0(i), ampts(:,i));
                ampts_ft{i} = fit(yf, af, 'linearinterp');
            catch
                ampts_ft{i} =@(x)0;
            end
        end

        if isempty(kwargs.yt)
            amptinc = max(ampts, [], 1);
        else
            for i = 1:kwargs.number
                amptinc(i) = ampts_ft{i}(kwargs.yt);
            end
        end

        switch kwargs.display
            case 'steady'
                plot_amp(axamps, amps, ampss, velavg1d, velavgs, 'steady')
            case 'travel'
                plot_amp(axampt, ampt, ampts, velavg1d, velavgs, 'travel')
            case 'steady-travel'
                plot_amp(axamps, amps, ampss, velavg1d, velavgs, 'steady')
                plot_amp(axampt, ampt, ampts, velavg1d, velavgs, 'travel')
        end

        plot_ampgrowth();
    end

    
    function eventintspec(~, ~)
        %% event function called when the spectrum field selection rectangle is moved
        kwargs.intlim = roispec{1}.Position;

        switch kwargs.disptype
            case 'node'
                prm = [2, 1];
            case 'spatial'
                prm = [1, 2];
        end

        specsteadprobe = guigetdata(roispec{1}, specstead, shape = 'cut', x = alpha, z = beta, permute = prm);
        spectravprobe = guigetdata(roispec{1}, spectrav, shape = 'cut', x = alpha, z = beta, permute = prm);

        amps = squeeze(sqrt(sum(specsteadprobe, [1, 2], 'omitmissing')));
        ampt = squeeze(sqrt(sum(spectravprobe, [1, 2], 'omitmissing')));

        prepamp();
    end

    function initspecsel()
        roispec = guiselectregion(axspecs, moved = @eventintspec, shape = 'rect', ...
            mask = kwargs.intlim, interaction = 'all', number = 1);
        eventintspec();
        if isempty(kwargs.intlim)
            disp("guicfi: select a limit integration")
        end
    end

    function plot_amp(ax, amp_raw, amp_smooth, velavg_raw, velavg_smooth, label)
        cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
        yyaxis(ax, 'left'); set(ax, 'YColor', 'Black'); cla(ax); plt = [];
        for i = 1:size(amp_raw, 2)
            if size(colors, 1) > 1; color = circshift(colors, 1-i); color = color(1,:); else; color = colors(1,:); end
            plot(ax, yn+kwargs.y0(i), amp_raw(:,i), '.-', 'Color', [color, 0.4]); 
            plt(i) = plot(ax, yn+kwargs.y0(i), amp_smooth(:,i), '.-', 'Color', color, 'DisplayName', num2str(round(xn(i))));
        end
        if isfield(kwargs.data, 'y')
            xlabel(ax, 'y, mm'); 
        else
            xlabel(ax, 'y_n'); 
        end
        switch kwargs.normamp
            case 'u0'
                ylabel(ax, 'A_{rms}/u_{0}');
            case 'ue'
                ylabel(ax, 'A_{rms}/u_{e}');
            otherwise
                ylabel(ax, 'A_{rms}');
        end
        if kwargs.showvelprof
            yyaxis(ax, 'right')
            for i = 1:size(velavg_raw, 2)
                if size(colors, 1) > 1; color = circshift(colors, 1-i); color = color(1,:); else; color = colors(1,:); end
                plot(ax, yn+kwargs.y0(i), velavg_raw(:,i), '.-', 'Color', [color, 0.4]); 
                plot(ax, yn+kwargs.y0(i), velavg_smooth(:,i), '.-', 'Color', color);
            end
        end
        if kwargs.normvel
            ylabel(ax, 'u/u_{e}');
        else
            ylabel(ax, 'u, m/s');
        end
        set(ax, 'YColor', 'Black')
        title(ax, label, 'FontWeight', 'Normal');
        if kwargs.legend
            lgd = legend(ax, plt);
            switch kwargs.disptype
                case 'node'
                    title(lgd, 'x_{n}', 'FontWeight', 'Normal')
                case 'spatial'
                    title(lgd, 'x, mm', 'FontWeight', 'Normal')
            end
        end
    end

    function plot_velavg(ax, vel)
        velavg = squeeze(mean(vel, 3));
        cla(ax);
        imagesc(ax, velavg(:, :, kwargs.yi, kwargs.xi)); axis(ax, 'equal');
        box(ax, 'on'); grid(ax, 'on'); 
        xlabel(ax, 'x_n'); ylabel(ax, 'z_n');
    end

    function plot_ampgrowth()
        cla(axampinc); hold(axampinc, 'on'); grid(axampinc, 'on'); box(axampinc, 'on');
        set(axampinc, 'YScale', kwargs.scaleampinc);
        plot(axampinc, xns, ampsinc, '.-', 'DisplayName', 'steady');
        plot(axampinc, xn, amptinc, '.-', 'DisplayName', 'travel');
        switch kwargs.disptype
            case 'node'
                xlabel(axampinc, 'x_n'); 
            case 'spatial'
                xlabel(axampinc, 'x, mm'); 
        end
        ylabel(axampinc, 'max(amp)');
        title(axampinc, 'increment', 'FontWeight', 'Normal');
        legend(axampinc);
    end

    function eventroiselmoving(~, evt)
        %% event to align rectangle selection box along line
        positions = [];
        for i = 1:numel(rois)
            positions = cat(1, positions, rois{i}.Position);
        end
        positions(:,1) = linspace(positions(1,1), positions(end,1), kwargs.number);
        positions(:,2) = linspace(positions(1,2), positions(end,2), kwargs.number);
        try
            positions(:,3:4) = repmat(evt.CurrentPosition(:,3:4), kwargs.number, 1);
        catch
        end
        for i = 1:numel(rois)
            rois{i}.Position = positions(i, :);
        end
    end

    function data = getdatafunc()
        if isempty(positions)
            mask = kwargs.mask;
        else
            mask = num2cell(positions, 2);
        end
        data = struct('alpha', alpha, 'beta', beta, 'specstead', specstead, 'spectrav', spectrav, ...
            'velavg', velavg, 'amps', amps, 'ampt', ampt, 'ampss', ampss, 'ampts', ampts, 'yn', yn, ...
            'xn', xn, 'intlim', kwargs.intlim, 'ampsinc', ampsinc, 'amptinc', amptinc, 'y0', kwargs.y0, 'yt', kwargs.yt, xns = xns);
        data.mask = mask;
    end

    prepdata()

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tile = tiledlayout('flow'); 

    axroi = nexttile(tile);
    switch kwargs.disptype
        case 'node'
            imagesc(axroi, vmm(:,:,kwargs.yi));
        case 'spatial'
            contourf(axroi, x, z, vmm(:,:,kwargs.yi), 100, 'LineStyle', 'None');
            box(axroi, 'on'); grid(axroi, 'on'); 
    end
    axis(axroi, kwargs.aspect);
    colormap(axroi, kwargs.colormap);
    if ~isempty(kwargs.climvel); clim(axroi, kwargs.climvel); end
    switch kwargs.disptype
        case 'node'
            xlabel(axroi, 'x_n'); ylabel(axroi, 'z_n');
        case 'spatial'
            xlabel(axroi, 'x, mm'); ylabel(axroi, 'z, mm');
    end

    switch kwargs.display
        case 'steady'
            if kwargs.mode ~= "var"
                axspecs = nexttile(tile);
            end
            axamps = nexttile(tile);
        case 'travel'
            if kwargs.mode ~= "var"
                axspect = nexttile(tile);
            end
            axampt = nexttile(tile);
        case 'steady-travel'
            if kwargs.mode ~= "var"
            axspecs = nexttile(tile);
            axspecs = nexttile(tile);
            axamps = nexttile(tile);
                axspecs = nexttile(tile);
            axamps = nexttile(tile);
                axspect = nexttile(tile);
            end
            axamps = nexttile(tile);
            axampt = nexttile(tile);
    end

    if kwargs.showvelavg
        axvelavg = nexttile(tile);
    end

    axampinc = nexttile(tile);

    rois = guiselectregion(axroi, moved = @eventroisel, moving = @eventroiselmoving, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);
    eventroisel()

    getdata = @getdatafunc;

end