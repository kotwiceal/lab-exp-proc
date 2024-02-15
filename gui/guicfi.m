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
%   normvelprof:        [1×1 logical]       - to norm velocity profiles
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
        kwargs.fillmissmeth (1,:) char {mustBeMember(kwargs.fillmissmeth, {'none', 'linear', 'nearest', 'natural', 'cubic', 'v4'})} = 'none'
        kwargs.prefilter (1,:) char {mustBeMember(kwargs.prefilter, {'none', 'average', 'gaussian', 'median', 'wiener'})} = 'gaussian'
        kwargs.prefiltkernel double = [3, 3]
        %% spectra processing parameters
        kwargs.normspec (1,:) char {mustBeMember(kwargs.normspec, {'none', 'psd'})} = 'psd'
        kwargs.shift logical = true
        kwargs.center (1,:) char {mustBeMember( kwargs.center, {'poly11', 'mean'})} = 'poly11'
        kwargs.winfun char {mustBeMember(kwargs.winfun, {'none', 'hann', 'hamming', 'tukey'})} = 'hann'
        kwargs.intlim double = []
        kwargs.normamp (1,:) char {mustBeMember(kwargs.normamp, {'none', 'u0', 'ue'})} = 'ue'
        kwargs.u0 (1,1) double = 25
        %% postprocessing parameters
        kwargs.postfilt (1,:) char {mustBeMember(kwargs.postfilt, {'movmean', 'movmedian', 'gaussian', 'lowess', 'loess', 'rlowess', 'rloess', 'sgolay'})} = 'movmean'
        kwargs.postfiltker double = 3
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
        kwargs.normvelprof logical = true
        kwargs.showvelavg logical = false
        kwargs.showvelprof logical = true
        kwargs.guitype (1,:) char {mustBeMember(kwargs.guitype, {'figure', 'uifigure'})} = 'figure'
    end

    warning off;

    % matrices parsing of spatial coordinates and velocity fields
    if isempty(kwargs.data)
        vm = kwargs.vm;
        x = kwargs.x;
        z = kwargs.z;
        y = 1:size(vm, 4);
    else
        vm = hypot(kwargs.data.u, kwargs.data.w);   
        x = kwargs.data.x;
        z = kwargs.data.z;
        if isfield(kwargs.data, 'y')
            y = kwargs.data.y;
        else
            y = 1:size(vm, 4);
        end
    end
    
    vmm = squeeze(mean(vm, 3)); 
    sz = size(vm);
    if isempty(x) && isempty(z); kwargs.disptype = 'node'; end

    alpha = [];
    beta = [];
    ue = [];
    positions = [];

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

    % choose select ROI method
    switch kwargs.disptype
        case 'node'
            selectraw = @(roiobj) guigetdata(roiobj, vm, shape = 'cut');
        case 'spatial'
            selectraw = @(roiobj) guigetdata(roiobj, vm, shape = 'cut', x = x, z = z);
    end

    %% process spectra of steady and travel modes
    function [specstead, spectrav, velavg, velavg1d, alpha, beta, ue] = specproc(vel)
        vel = permute(vel, [1, 2, 4, 5, 3]);
        szr = size(vel); % [transversal, longitudinal, vertical, selections, frames]
        velavg = squeeze(mean(vel, 5)); % averaged velocity fields
        velavg1d = squeeze(mean(velavg, [1, 2]));
        ue = velavg1d(end,:);
        ts = tic;
        % data centering
        switch kwargs.center
            case 'poly11'
                rawt = zeros(szr); rawmt = zeros(szr(1:end-1));
                % instantaneous fields
                [x1, z1] = meshgrid(1:szr(2), 1:szr(1));
                x2 = []; z2 = []; vm2 = [];
                parfor i = 1:prod(szr(3:end))
                    [x2, z2, vm2] = prepareSurfaceData(x1, z1, vel(:,:,i));
                    rawft = fit([x2, z2], vm2, 'poly11');
                    rawt(:,:,i) = vel(:,:,i)- rawft(x1, z1); 
                end
                % average fields
                parfor i = 1:prod(szr(3:end-1))
                    [x2, z2, vm2] = prepareSurfaceData(x1, z1, velavg(:,:,i));
                    rawft = fit([x2, z2], vm2, 'poly11');
                    rawmt(:,:,i) = velavg(:,:,i)- rawft(x1, z1);
                end
                vel = reshape(rawt, szr);
                velavg = reshape(rawmt, szr(1:end-1));
            case 'mean'
                vel = vel-mean(vel, [1, 2]);
                velavg = velavg-mean(velavg, [1, 2]);
        end
        disp(strcat("guicfi: elapsed time is ", num2str(toc(ts)), " seconds."))
        % data multiplying by window function
        switch kwargs.winfun
            case 'hann'
                win = hann(szr(1)).*hann(szr(2))';
                vel = vel.*win;
                velavg = velavg.*win;
                ecf = 1/rms(win(:));
            case 'tukey'
                win = tukeywin(szr(1), 1).*tukeywin(szr(2), 1)';
                vel = vel.*win;
                velavg = velavg.*win;
                ecf = 1/rms(win(:));
            otherwise
                ecf = 1;
        end
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
            contourf(ax, alpha, beta, spec(:,:,kwargs.yi,kwargs.xi), 50, 'LineStyle', 'None');
            axis(ax, 'image');
        end
        clb = colorbar(ax); colormap(ax, kwargs.colormap); 
        title(clb, kwargs.normspec);
        if ~isempty(kwargs.climspec); clim(ax, kwargs.climspec); end
        set(ax, 'ColorScale', kwargs.cscalespec); title(ax, label, 'FontWeight', 'Normal');
        switch kwargs.disptype
            case 'node'
                xlabel(ax, '\alpha_{n}'); ylabel(ax, '\beta_{n}');
            case 'spatial'
                xlabel(ax, '\alpha, mm^{-1}'); ylabel(ax, '\beta, mm^{-1}');
        end
    end

    %% event function called when the velocity field selection rectangle is moved
    function eventroisel(~, ~)
        try
            disp("guicfi: event ROI selection is running")
            raw = []; % accumulate data
            for i = 1:length(rois); raw = cat(5, raw, selectraw(rois{i})); end
            [specstead, spectrav, ~, velavg, alpha, beta, ue] = specproc(raw);
            if kwargs.normvelprof; velavg = velavg ./ max(velavg, [], 1); end
            switch kwargs.display
                case 'steady'
                    plot_spec(axspecs, specstead, 'steady', alpha, beta)
                case 'travel'
                    plot_spec(axspect, spectrav, 'travel', alpha, beta)
                case 'steady-travel'
                    plot_spec(axspecs, specstead, 'steady', alpha, beta)
                    plot_spec(axspect, spectrav, 'travel', alpha, beta)
            end
            initspecsel();
        catch
            disp("guicfi: event ROI selection is failed")
        end
    end

    %% event function called when the spectrum field selection rectangle is moved
    function eventintspec(~, ~)
        kwargs.intlim = roispec{1}.Position;

        specsteadprobe = guigetdata(roispec{1}, specstead, shape = 'cut', x = alpha, z = beta);
        spectravprobe = guigetdata(roispec{1}, spectrav, shape = 'cut', x = alpha, z = beta);
        amps = squeeze(sqrt(sum(specsteadprobe, [1, 2])));
        ampt = squeeze(sqrt(sum(spectravprobe, [1, 2])));

        velavgs = smoothdata(velavg, 1, kwargs.postfilt, kwargs.postfiltker);

        switch kwargs.normamp
            case 'u0'
                amps = amps/kwargs.u0;
                ampt = ampt/kwargs.u0;
            case 'ue'
                amps = amps./ue;
                ampt = ampt./ue;
        end

        ampss = smoothdata(amps, 1, kwargs.postfilt, kwargs.postfiltker);
        ampsinc = max(ampss, [], 1);

        ampts = smoothdata(ampt, 1, kwargs.postfilt, kwargs.postfiltker);
        amptinc = max(ampts, [], 1);

        switch kwargs.display
            case 'steady'
                plot_amp(axamps, amps, ampss, velavg, velavgs, 'steady')
            case 'travel'
                plot_amp(axampt, ampt, ampts, velavg, velavgs, 'travel')
            case 'steady-travel'
                plot_amp(axamps, amps, ampss, velavg, velavgs, 'steady')
                plot_amp(axampt, ampt, ampts, velavg, velavgs, 'travel')
        end

        if kwargs.showvelavg
            plot_vel(axvelavg, velavgs)
        end

        plot_ampgrowth();
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
        yyaxis(ax, 'left'); set(ax, 'YColor', 'Black'); cla(ax);
        for i = 1:size(amp_raw, 2)
            j = rem(i, numel(colors));
            if j == 0; j = 1; end
            plot(ax, y, amp_raw(:,j), '.-', 'Color', [colors{j}, 0.4]); 
            plot(ax, y, amp_smooth(:,j), '.-', 'Color', colors{j});
        end
        xlabel(ax, 'y_n'); 
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
                j = rem(i, numel(colors));
                if j == 0; j = 1; end
                plot(ax, y, velavg_raw(:,j), '.-', 'Color', [colors{j}, 0.4]); 
                plot(ax, y, velavg_smooth(:,j), '.-', 'Color', colors{j});
            end
        end
        ylabel(ax, 'u, m/s'); set(ax, 'YColor', 'Black')
        title(ax, label, 'FontWeight', 'Normal');
    end

    function plot_vel(ax, velavgs)
        cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
        for i = 1:size(velavgs, 2)
            j = rem(i, numel(colors));
            if j == 0; j = 1; end
            plot(ax, velavgs(:,j), '.-', 'Color', colors{j});
        end
        xlabel(ax, 'y_n'); ylabel(ax, 'u, m/s');
    end

    function plot_ampgrowth()
        cla(axampinc); hold(axampinc, 'on'); grid(axampinc, 'on'); box(axampinc, 'on');
        set(axampinc, 'YScale', kwargs.scaleampinc);
        plot(axampinc, ampsinc, '.-', 'DisplayName', 'steady');
        plot(axampinc, amptinc, '.-', 'DisplayName', 'travel');
        xlabel(axampinc, 'x_n'); ylabel(axampinc, 'max(amp)');
        title(axampinc, 'increment', 'FontWeight', 'Normal');
        legend(axampinc);
    end

    function eventroiselmoving(~, evt)
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

    function savefigure(~, ~)
        [file, path, ~] = uiputfile('*.png*', 'File Selection', 'figure.png');
        exportgraphics(t, fullfile(path, file), Resolution = 600)
    end

    switch kwargs.guitype
        case 'figure'
            if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
            tiledlayout('flow'); nexttile; axroi = gca;
            box(axroi, 'on'); grid(axroi, 'on'); 
            switch kwargs.disptype
                case 'node'
                    imagesc(axroi, vmm(:,:,kwargs.yi));
                case 'spatial'
                    contourf(axroi, x, z, vmm(:,:,kwargs.yi), 50, 'LineStyle', 'None');
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
        
            if kwargs.showvelavg
                nexttile; axvelavg = gca;
            end
        
            nexttile; axampinc = gca;

            rois = guiselectregion(axroi, moved = @eventroisel, moving = @eventroiselmoving, shape = 'rect', ...
                mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);

            eventroisel();
        case 'uifigure'
            fig = uifigure;
            gridApp = uigridlayout(fig);
            gridApp.RowHeight = {'1x', 'fit', 'fit'}; gridApp.ColumnWidth = {'1x', 'fit'};
            
            buttonProcess = uibutton(gridApp, Text = 'Process', ButtonPushedFcn = @eventroisel);
            buttonProcess.Layout.Row = 2;
            buttonProcess.Layout.Column = 2;
        
            buttonSaveFigure = uibutton(gridApp, Text = 'Save Figure', ButtonPushedFcn = @savefigure);
            buttonSaveFigure.Layout.Row = 3;
            buttonSaveFigure.Layout.Column = 2;
            
            p = uipanel(gridApp);
            p.Layout.Row = [1, 3];
            p.Layout.Column = 1;
            
            
            t = tiledlayout(p, 'flow');
            
            axroi = nexttile(t);
            box(axroi, 'on'); grid(axroi, 'on'); 
            switch kwargs.disptype
                case 'node'
                    imagesc(axroi, vmm(:,:,kwargs.yi));
                case 'spatial'
                    contourf(axroi, x, z, vmm(:,:,kwargs.yi), 50, 'LineStyle', 'None');
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
                    axspecs = nexttile(t);
                    axamps = nexttile(t);
                case 'travel'
                    axspect = nexttile(t);
                    axampt = nexttile(t);
                case 'steady-travel'
                    axspecs = nexttile(t);
                    axamps = nexttile(t);
                    axspect = nexttile(t);
                    axampt = nexttile(t);
            end
        
            if kwargs.showvelavg
                axvelavg = nexttile(t);
            end
        
            axampinc = nexttile(t);

            rois = guiselectregion(axroi, moving = @eventroiselmoving, shape = 'rect', ...
                mask = kwargs.mask, interaction = kwargs.interaction, number = kwargs.number);
    end

    getdata = @() struct('alpha', alpha, 'beta', beta, 'specstead', specstead, 'spectrav', spectrav, ...
        'velavg', velavg, 'amps', amps, 'ampt', ampt, 'ampss', ampss, 'ampts', ampts, 'mask', {num2cell(positions, 2)});

end