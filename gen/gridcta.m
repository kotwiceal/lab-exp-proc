function varargout = gridcta(ax1, ax2, ax3, kwargs)
%% Build scanning grid for single hot-wire measurement
%% The function takes following arguments:
%   ax1:            [1×k double]            - longitudinal direction
%   ax2:            [1×n double]            - transverse direction
%   ax3:            [1×m double]            - vertical direction
%   filename:       [char array]            - to save scan table
%   scanorder:      [1×3 double]            - scanning axis order
%   axorder:        [1×3 double]            - axis coloumn order
%   ax10:           [1×k double]            - base points of longitudinal direction
%   ax20:           [1×n double]            - base points of transverse direction
%   ax30:           [1×m double]            - base points of vertical direction
%   show:           [1×1 logical]           - show scanning points
%% The function returns following results:
%   scan:           [knm×3 double]          - scan table
%   scancor:        [knm×3 double]          - corrected scan table
%% Examples:
% gridcta(0:200:1000, -3000:500:3000, 200:100:1000, 'scan_1')

    arguments
        ax1 double
        ax2 double
        ax3 double
        kwargs.filename (1,:) char = ''
        kwargs.scanorder double = [3, 2, 1]
        kwargs.axorder double = [3, 2, 1]
        kwargs.ax10 double = []
        kwargs.ax20 double = []
        kwargs.ax30 double = []
        kwargs.show logical = true
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

    if iscorbase
        if numel(kwargs.ax10) == 1
            type = 'poly02';
        end
        if numel(kwargs.ax20) == 1
            type = 'poly20';
        end
        if (numel(kwargs.ax10) ~= 1) && (numel(kwargs.ax20) ~= 1)
            type = 'poly22';
        end
        [kwargs.ax10, kwargs.ax20] = meshgrid(kwargs.ax10, kwargs.ax20);
        [ax10, ax20, ax30] = prepareSurfaceData(kwargs.ax10, kwargs.ax20, kwargs.ax30);
        ft = fit([ax10, ax20], ax30, type);
        scancor = scan;
        ax3s = ft(scancor(:,1), scancor(:,2));
        scancor(:, 3) = scancor(:, 3) - ax3s;
    end

    if ~isempty(kwargs.filename)
        dlmwrite(strcat(kwargs.filename, '.txt'), ceil(scan)', '\t');
    end

    if (kwargs.show)
        figure('WindowStyle', 'docked');
        hold on; box on; grid on;  
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

    scan = scan(:, kwargs.axorder);
    varargout{1} = scan;

    if exist('scancor', 'var')
        scancor = scancor(:, kwargs.axorder);
        varargout{2} = scancor;
    end

end