function varargout = gridcta(ax1, ax2, ax3, kwargs)
    %% Build scanning grid for single hot-wire measurement
    %% The function takes following arguments:
    %   ax1:            [1×k double]            - longitudinal direction
    %   ax2:            [1×n double]            - transverse direction
    %   ax3:            [1×m double]            - vertical direction
    %   ax4:            [1×p double]            - optional axis
    %   filename:       [char array]            - to save scan table
    %   scanorder:      [1×3 double]            - scanning axis order
    %   axorder:        [1×3 double]            - axis coloumn order
    %   ax10:           [1×k double]            - base points of longitudinal direction
    %   ax20:           [1×n double]            - base points of transverse direction
    %   ax30:           [1×m double]            - base points of vertical direction
    %   show:           [1×1 logical]           - show scanning points
    %   fit:            [char array]            - fit type
    %   repelem:        [1×1 double]            - repeat element
    %% The function returns following results:
    %   scan:           [knm×3 double]          - scan table
    %   scancor:        [knm×3 double]          - corrected scan table
    %% Examples:
    
    %% 1. Build 1D scanning table (vertical profile) and save in scan_1d.txt
    % gridcta(0, 0, 0:50:1000, filename = 'scan_1d')
    
    %% 2. Build 2D scanning table (cross-section) and save in scan_2d.txt
    % gridcta(0, -3000:500:3000, 0:50:1000, filename = 'scan_2d')
    
    %% 3. Build 2D scanning table (volume) and save in scan_3d.txt
    % gridcta(0:200:1000, -3000:500:3000, 0:50:1000, filename = 'scan_3d')
    
    %% 4. Build 1D scanning table (vertical profile), correct base and save in scan_1dc.txt
    % gridcta(0, 0, 200:100:1000, ax10 = 0, ax20 = 0, ax30 = -35, filename = 'scan_1dc')
    
    %% 5. Build 2D scanning table (cross-section-transverse), correct base and save in scan_2dc.txt
    % gridcta(0, -1000:500:1000, 200:100:1000, ax10 = 0, ax20 = [-1200, -800, -400, 0, 400, 800, 1000], ...
    %   ax30 = [-10, 20, -30, 40, -50, 60, -70], filename = 'scan_2dc')
    
    %% 6. Build 2D scanning table (cross-section-longitudinal), correct base and save in scan_2dc.txt
    % gridcta(0:100:600, 800, 200:100:1000, ax10 = 0:200:1200, ...
    %    ax20 = 800, ax30 = [-10, 20, -30, 40, -50, 60, -70], filename = 'scan_2dc')
    
    %% 7. Build 3D scanning table (horizon-plane-section), correct base (grid-wise notation {ax10, ax20, ax30}) and save in scan_2dc.txt
    % gridcta(0:100:1000, -800:200:800, 200, ax10 = 0:400:2000, ax20 = -1000:500:1000, ...
    %   ax30 = 100*rand(6, 5), filename = 'scan_2dc')
    
    %% 8. Build 3D scanning table (horizon-plane-section), correct base (point-wise notation {ax10, ax20, ax30}) and save in scan_2dc.txt
    % ax10 = [0, 0, 0, 0, 500, 500, 500, 1000, 1000, 1000, 1000, 1000];
    % ax20 = [-1000, -800, 800, 1000, -1200, 600, 1200, -2000, -1000, -500, 0, 1000];
    % ax30 = 100*rand(1, numel(ax10));
    % gridcta(0:100:1000, -800:200:800, 500, ax10 = ax10, ax20 = ax20, ax30 = ax30, ...
    %   filename = 'scan_3dc', pointwise = true)
    
    %% 9. Build 3D scanning table (volume), correct base (grid-wise notation {ax10, ax20, ax30})  and save in scan_3dc.txt
    % gridcta(0:100:1000, -800:200:800, 200:100:1000, ax10 = 0:400:2000, ax20 = -1000:500:1000, ...
    %   ax30 = 100*rand(6, 5), filename = 'scan_3dc')
    
    %% 10. Build 3D scanning table (volume), correct base (point-wise notation {ax10, ax20, ax30}) and save in scan_3dc.txt
    % ax10 = [0, 0, 0, 0, 500, 500, 500, 1000, 1000, 1000, 1000, 1000];
    % ax20 = [-1000, -800, 800, 1000, -1200, 600, 1200, -2000, -1000, -500, 0, 1000];
    % ax30 = 100*rand(1, numel(ax10));
    % gridcta(0:100:1000, -800:200:800, 200:100:1000, ax10 = ax10, ax20 = ax20, ax30 = ax30, ...
    %   filename = 'scan_3dc', pointwise = true)
    
    %% 10. Build 2D scanning table (cross-section-transverse) with repeated elements
    % gridcta(3000, -1000:100:1000, 0:50:500, repelem = 2)
    
    %% 11. Build 2D scanning table (cross-section-transverse) with optinal axis
    % gridcta(3000, -1000:100:1000, 0:50:500, ax4 = [0, 1]);
    
    arguments
        ax1 double
        ax2 double
        ax3 double
        kwargs.ax4 double = []
        kwargs.filename (1,:) char = ''
        kwargs.scanorder double = [3, 2, 1]
        kwargs.axorder double = [1, 2, 3]
        kwargs.ax10 double = []
        kwargs.ax20 double = []
        kwargs.ax30 double = []
        kwargs.ax1s double = []
        kwargs.ax2s double = []
        kwargs.ax3s double = []
        kwargs.show logical = true
        kwargs.delimiter (1,:) char = 'tab'
        kwargs.pointwise logical = false, 
        kwargs.fit (1,:) char {mustBeMember(kwargs.fit, {'', 'poly01', 'poly10', 'poly11', 'poly02', 'poly20', 'poly22', 'poly21', 'poly12', 'linearinterp'})} = ''
        kwargs.repelem (1,1) double = 1
        kwargs.docked (1,1) logical = false
    end

    nax1 = size(ax1, 2);
    nax2 = size(ax2, 2);
    nax3 = size(ax3, 2);
    
    scan_mat_ax1 = repmat(reshape(ax1,[nax1,1,1]),[1, nax2, nax3]);
    scan_mat_ax2 = repmat(reshape(ax2,[1,nax2,1]),[nax1, 1, nax3]);
    scan_mat_ax3 = repmat(reshape(ax3,[1,1,nax3]),[nax1, nax2, 1]);
    
    scan = vertcat(reshape(permute(scan_mat_ax1,kwargs.scanorder),[1 nax3*nax2*nax1]),...
        reshape(permute(scan_mat_ax2,kwargs.scanorder),[1 nax3*nax2*nax1]),...
        reshape(permute(scan_mat_ax3,kwargs.scanorder),[1 nax3*nax2*nax1]))';
    
    iscorbase = ~(isempty(kwargs.ax10) && isempty(kwargs.ax20) && isempty(kwargs.ax30));

    % shift the scan in x-z plane by piesewise linear law
    if ~isempty(kwargs.ax1s) && ~isempty(kwargs.ax2s)
        [kwargs.ax1s, kwargs.ax2s] = prepareCurveData(kwargs.ax1s, kwargs.ax2s);
        ft = fit(kwargs.ax1s, kwargs.ax2s, 'linearinterp');
        scan(:, 2) = scan(:, 2) - round(ft(scan(:, 1)));
    end

    % shift the scan in y-z plane by piesewise linear law
    if ~isempty(kwargs.ax2s) && ~isempty(kwargs.ax3s)
        [kwargs.ax2s, kwargs.ax3s] = prepareCurveData(kwargs.ax2s, kwargs.ax3s);
        ft = fit(kwargs.ax2s, kwargs.ax3s, 'linearinterp');
        scan(:, 3) = scan(:, 3) - round(ft(scan(:, 2)));
    end

    % shift the scan in x-y-z plane by piesewise linear law
    if ~isempty(kwargs.ax1s) && ~isempty(kwargs.ax2s) && ~isempty(kwargs.ax3s)
        [kwargs.ax1s, kwargs.ax2s] = prepareCurveData(kwargs.ax1s, kwargs.ax2s);
        [kwargs.ax1s, kwargs.ax3s] = prepareCurveData(kwargs.ax1s, kwargs.ax3s);
        ft_12 = fit(kwargs.ax1s, kwargs.ax2s, 'linearinterp');
        ft_13 = fit(kwargs.ax1s, kwargs.ax3s, 'linearinterp');
        scan(:, 2) = scan(:, 2) - round(ft_12(scan(:, 1)));
        scan(:, 3) = scan(:, 3) - round(ft_13(scan(:, 1)));
    end

    if iscorbase
        if (numel(kwargs.ax10) == 1) && (numel(kwargs.ax20) == 1) && (numel(kwargs.ax30) == 1) 
            scancor = scan;
            scancor(:, 3) = scancor(:, 3) + kwargs.ax30;
            kwargs.ax10 = ax1;
            kwargs.ax20 = ax2;
            ft = @(x,z) kwargs.ax30;
        else
            if isempty(kwargs.fit)
                if numel(kwargs.ax10) == 1
                    type = 'poly02';
                end
                if numel(kwargs.ax20) == 1
                    type = 'poly20';
                end
                if (numel(kwargs.ax10) ~= 1) && (numel(kwargs.ax20) ~= 1)
                    type = 'poly22';
                end
            else
                type = kwargs.fit;
            end
            disp(strcat("fit type: ", type))
            if ~kwargs.pointwise
                [kwargs.ax10, kwargs.ax20] = meshgrid(kwargs.ax10, kwargs.ax20);
            end
            [ax10, ax20, ax30] = prepareSurfaceData(kwargs.ax10, kwargs.ax20, kwargs.ax30);
            ft = fit([ax10, ax20], ax30, type);
            scancor = scan;
            ax3s = ft(scancor(:,1), scancor(:,2));
            scancor(:, 3) = scancor(:, 3) + round(ax3s);
        end
    end

    if kwargs.show
        if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');
        nexttile; hold on; box on; grid on;  
        plot3(scan(:,1), scan(:,2), scan(:,3), '.', 'DisplayName', 'scan');
        plot3(kwargs.ax10(:), kwargs.ax20(:), kwargs.ax30(:), '.', 'DisplayName', 'base')
        if iscorbase
            plot3(scancor(:,1), scancor(:,2), scancor(:,3), '.', 'DisplayName', 'corrected scan')
        end
        xlabel('axis 1'); ylabel('axis 2'); zlabel('axis 3');
        XL = get(gca, 'XLim'); YL = get(gca, 'YLim'); ZL = get(gca, 'ZLim');
        fill3([0, XL(2), XL(2), 0], [YL(1), YL(1), YL(2), YL(2)], [0, 0, 0, 0], ...
            [0.4660 0.6740 0.1880], 'FaceAlpha', 0.2, 'DisplayName', 'plate');
        fill3([0, 0, 0, 0], [YL(1), YL(2), YL(2), YL(1)], [0, 0, ZL(2), ZL(2)], ...
            [0 0.4470 0.7410], 'FaceAlpha', 0.2, 'DisplayName', 'inlet');
        legend(); view([-150, 10])
    end

    if ~isempty(kwargs.ax4)
        kwargs.repelem = numel(kwargs.ax4);
    end

    scan = reshape(repelem(scan(:), kwargs.repelem), [size(scan, 1)*kwargs.repelem, size(scan, 2)]);
    scan = scan(:, kwargs.axorder);
    
    if ~isempty(kwargs.ax4)
        if size(scan, 1) == numel(kwargs.ax4)
            scan(:, 4) = kwargs.ax4;
        else
            scan(:, 4) = repmat(kwargs.ax4(:), floor(size(scan, 1)/numel(kwargs.ax4)), 1);
        end
    end
    
    varargout{1} = scan;
    
    if exist('scancor', 'var')
        scancor = reshape(repelem(scancor(:), kwargs.repelem), [size(scancor, 1)*kwargs.repelem, size(scancor, 2)]);
        scancor = scancor(:, kwargs.axorder);
        if ~isempty(kwargs.ax4)
            scancor(:, 4) = scan(:, 4);
        end
        varargout{2} = scancor;
        tab = scancor;
    else
        tab = scan;
    end

    if ~isempty(kwargs.filename)
        writematrix(tab, strcat(kwargs.filename, '.txt'), 'Delimiter', kwargs.delimiter);
        if exist('ft', 'var')
            save(strcat(kwargs.filename, '.mat'), 'ft')
        end
    end

    if exist('ft', 'var')
        varargout{3} = ft;
    end

end