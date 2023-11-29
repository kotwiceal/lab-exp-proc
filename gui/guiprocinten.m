function guiprocinten(data, named)
%% Interactive intermittency processing.
%% The function takes following arguments:
%   data:           [n×m... double]                 - multidimensional data
%   shape:          [char]                          - type of region selection
%   mask:           [double]                        - two row vertex to line selection; edge size to rectangle selection; 
%                                                       n-row verxex to polygon selection 
%   fit:            [char]                          - type of statistics fit
%   range:          [1×2 double]                    - range to cut data
%   norm:           [char]                          - type of statistics normalization
%   interaction:    [char]                          - region selection behaviour
%   number:         [int]                           - count of selection regions
    
        arguments
            data double
            named.shape char = 'poly'
            named.mask double = []
            named.norm char = 'pdf'
            named.fit char = 'skew'
            named.interaction char = 'all'
            named.range double = []
            named.number double = 1
            named.legend char = 'off'
        end
        
        iten_fit = {}; roilines = {}; ax_iten2d = {}; roicrosshair = {}; threshold = [];
        edges = []; counts = [];
        rois = cell(1, size(data, 4)); selects = cell(1, size(data, 4)); axs = cell(1, size(data, 4));
    
        for i = 1:length(selects)
            selects{i} = @(roiobj) guigetdata(roiobj, data(:,:,:,i), shape = 'flatten');
        end
    
        function threshold = prochist()
            temp = [];
            for j = 1:length(rois)
                temp = vertcat(temp, selects{j}(rois{j}));
            end
            [counts, edges] = histcounts(temp, 'Normalization', named.norm);
            edges = edges(2:end);
    
            if ~isempty(named.range)
                [edges, counts] = histcutrange(edges, counts, named.range);
            end
    
            [f, modes] = fithist(counts, edges, type = named.fit);
    
            f1 = @(x) f.a*exp(-1*((x-f.b)/f.c).^2).*(1+erf(f.d*(x-f.b)/f.c));
            f2 = @(x) f.e*exp(-((x-f.f)/f.g).^2);
            threshold = fsolve(@(x) f1(x)-f2(x), f.b);
            disp(["solve: threshold=", threshold])
    
            cla(ax_hist); hold(ax_hist, 'on'); grid(ax_hist, 'on'); box(ax_hist, 'on'); 
            xlabel(ax_hist, 'edges'); ylabel(ax_hist, named.norm)
            plot(ax_hist, edges, counts, 'DisplayName', 'full')
            plot(ax_hist, edges, modes(:, 1), 'DisplayName', 'mode 1')
            plot(ax_hist, edges, modes(:, 2), 'DisplayName', 'mode 2')
            plot(ax_hist, edges, sum(modes, 2), 'DisplayName', 'sum modes')
            switch (named.legend)
                case 'on'
                   legend(ax_hist, 'Location', 'Best');     
            end
    
            roicrosshair = drawcrosshair(ax_hist);
            addlistener(roicrosshair, 'ROIMoved', @eventcrosshair);
        end
    
        function prociten()
            result = squeeze(mean(binarize(data, threshold), 3));
            for j = 1:length(ax_iten2d)
                temp = result(:,:,j);
                cla(ax_iten2d{j}); imagesc(ax_iten2d{j}, temp); clim(ax_iten2d{j}, [0, 1]);
            
                roitemp = guiselectregion(ax_iten2d{j}, @eventline, shape = 'line');
                roilines{j} = roitemp{1};
    
                [I, J] = ndgrid(1:size(temp, 1), 1:size(temp, 2));
                index = isnan(temp);
                temp = temp(~index);
                I = I(~index);
                J = J(~index);
                iten_fit{j} = fit([J, I], temp, 'linearinterp');
            end
        end
    
        function eventpoly(~, ~)
            try
                prochist();
            catch
                disp('eventpoly error')
            end
    
        end
    
        function eventline(~, ~)
            try
                cla(ax_iten1d); hold(ax_iten1d, 'on'); grid(ax_iten1d, 'on'); box(ax_iten1d, 'on'); 
                xlabel(ax_iten1d, 'horizon'); ylabel(ax_iten1d, 'value')
                for j = 1:length(roilines)
                    pos = roilines{j}.Position;
                    xi = linspace(pos(1,1), pos(2,1));
                    zi = linspace(pos(1,2), pos(2,2));
                    plot(ax_iten1d, xi, iten_fit{j}(xi, zi))
                end
            catch
    
            end
        end
    
        function eventcrosshair(~, ~)
            try
                threshold = roicrosshair.Position(1);
                disp(["interactive: threshold=", threshold])
                prociten();
            catch
                disp('eventcrosshair error')
            end
        end
    
        figure('WindowStyle', 'docked');
        tiledlayout(floor((size(data, 4)*2+2)/3) + 1, 3);
        for i = 1:length(rois)
            nexttile; imshow(data(:,:,1,i)); colormap turbo; axis on;
            if ~isempty(named.range)
                clim(named.range); 
            end
            axs{i} = gca;
            roitemp = guiselectregion(axs{i}, @eventpoly, shape = named.shape, ...
                mask = named.mask, interaction = named.interaction, number = 1);
            rois{i} = roitemp{1};
        end
        nexttile; ax_hist = gca;
        for i = 1:length(rois)
            nexttile; ax_iten2d{i} = gca;
        end
        nexttile; ax_iten1d = gca;
    
    end