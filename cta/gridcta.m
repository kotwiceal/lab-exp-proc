function varargout = gridcta(varargin, kwargs)
    %% Generate scanning grid to measure by single hot-wire sensor moved by 3-axis traverse.

    arguments (Input, Repeating)
        varargin double {mustBeVector} % specify position vectors for each axis
    end

    arguments (Input)
        %% generation
        kwargs.order (1,:) double = [] % axis order at scanning
        kwargs.orderflip (1,1) logical = true % flip axis order
        %% offset
        kwargs.offset (:,:) cell = [] % axis offsetting points presented in the point/gridwise notation
        kwargs.offsetdim (1,:) double {mustBeInRange(kwargs.offsetdim, 1, 3)} = 3 % axis order to apply offset
        kwargs.pointwise (1,:) {mustBeA(kwargs.pointwise, {'double', 'cell'})} = [] % axis order of offsetting vectors to transform from grid to pointwise notation
        kwargs.fit (1,:) {mustBeA(kwargs.fit, {'char', 'cell'})} = 'linearinterp' % fit type at applying offset
        %% basis
        kwargs.unit (1,:) char {mustBeMember(kwargs.unit, {'mm', 'count'})} = 'count'
        kwargs.refmarker (1,:) char {mustBeMember(kwargs.refmarker, {'none', 'n2', 'n8', 'n9'})} = 'none' % point considered as origin
        kwargs.steps (1,:) double = [50, 400, 800] % single step displacement of step motor in um
        kwargs.xfit = [] % fitobj transfrom to leading edge coordinate system
        kwargs.yfit = [] % fitobj to reverse a correction of vectical scanning component
        kwargs.zfit = [] % fitobj transfrom to leading edge coordinate system
        %% appearance
        kwargs.show (1,1) logical = true % display a grid scan
        kwargs.docked (1,1) logical = false % dock figure
        kwargs.markersize (1,1) double = 10
        %% export
        kwargs.filename (1,:) char = []
        kwargs.extention (1,:) char = '.txt'
        kwargs.delimiter (1,:) char {mustBeMember(kwargs.delimiter, {',', 'comma', ' ', 'space', '\t', 'tab', ';', 'semi', '|', 'bar'})} = '\t'
        %%
        kwargs.ort (:,2) double = [] %% LE coordinate system reference points
        kwargs.skew (:,2) double = [] %% skew coordinate system reference points
    end

    arguments (Output, Repeating)
        varargout
    end

    % create a scan grid
    scan = cell(1, nargin);
    [scan{:}] = ndgrid(varargin{:});
    if isempty(kwargs.order)
        kwargs.order = 1:nargin; 
        if kwargs.orderflip; kwargs.order = flip(kwargs.order); end
    end
    for i = 1:nargin; scan{i} = permute(scan{i}, kwargs.order); end
    for i = 1:nargin; scan{i} = scan{i}(:); end
    scan = cell2mat(scan);

    % fit offset
    scanoffset = [];
    if ~isempty(kwargs.offset)
        scanoffset = scan;

        if size(kwargs.offset, 1) == 1; kwargs.offset = {kwargs.offset}; end
        szoff = size(kwargs.offset);
        if isa(kwargs.pointwise, 'double')
            if isempty(kwargs.pointwise)
                kwargs.pointwise = repmat({kwargs.pointwise}, 1, szoff(1));
            else
                kwargs.pointwise = {kwargs.pointwise};
            end
        end
        if isa(kwargs.fit, 'char'); kwargs.fit = {kwargs.fit}; end
        if (szoff(1) ~= numel(kwargs.offsetdim)); error('`offset` and offsetdim must have compatible dimensions'); end
        if (szoff(1) ~= numel(kwargs.pointwise)); error('`offset` and `pointwise` must have compatible dimensions'); end

        fitobj = cell(1, size(kwargs.offset, 1));

        for i = 1:szoff(1)
            offset = kwargs.offset{i};
            if numel(offset) ~= 3; error('`offset` must have 3 vectors'); end
            pointwise = kwargs.pointwise{i};
            mustBeInRange(pointwise, 1, 3);
            offsetdim = kwargs.offsetdim(i);
            fitname = kwargs.fit{i};

            for j = 1:numel(offset); offset{j} = offset{j}(:); end
            
            empty = false(1, numel(offset));
            try
                offset = cell2mat(offset);
            catch
                % append empty axis by zeros
                for j = 1:numel(offset); empty(j) = isempty(offset{j}); end
                if sum(empty) ~= 0
                    temp = cell(1, sum(~empty));
                    [temp{:}] = offset{~empty};
                    offset{empty} = zeros(numel(temp{1}), 1);
                end
                try
                    offset = cell2mat(offset);
                catch
                    % transform from grid to pointwise notation
                    if isempty(pointwise); pointwise = 1:numel(offset)-1; end
                    [offset{pointwise}] = ndgrid(offset{pointwise});
                    for j = 1:numel(offset); offset{j} = offset{j}(:); end
                    offset = cell2mat(offset);
                end
            end

            kwargs.offset{i,:} = num2cell(offset, 1);
    
            offset(:, empty) = [];
    
            index = 1:3;
            offset = offset(:, circshift(1:size(offset, 2), offsetdim));
            offset = num2cell(offset, 1);
            index(index == offsetdim | empty) = [];

            switch numel(offset)
                case 2
                    [offset{:}] = prepareCurveData(offset{:});
                    args = {offset{1}, offset{2}, fitname};
                case 3
                    [offset{:}] = prepareSurfaceData(offset{:});
                    args = cat(2, {[offset{1}, offset{2}]}, offset{3}, fitname);
            end

            % fit offset
            fitobj{i} = fit(args{:});

            % substract offset
            args = num2cell(scanoffset(:, index), 1);
            scanoffset(:, offsetdim) = scan(:, offsetdim) + fitobj{i}(args{:});

        end

        if isscalar(fitobj); fitobj = fitobj{1}; end

    end

    % transform units
    switch kwargs.unit
        case 'mm'
           if kwargs.refmarker ~= "none"
                switch kwargs.refmarker
                    case 'n2'
                        kwargs.ort = [113.9, 63.7; 113.9, 112.4; 126.8, 118.9; 126.7, 70.2]; % mm
                        kwargs.skew = [0, 0; 0, 2e4; 300, 2e4; 300, 0]; % count
                    case 'n8'
                        kwargs.ort = [384.6, 189.4; 294, 148.4; 294.4, 198.5; 384.6, 139.4]; % mm
                        kwargs.skew = [0, 0; -2086, 1060; -2086, 21124; 0, -20060]; % count
                    case 'n9'
                        kwargs.ort = [429.76, 209.95; 429.43, 260.50; 474.0, 283.03; 474.0, 233.36]; % mm
                        kwargs.skew = [0, 0; 0, 2e4; 1e3, 2e4; 1e3, 0]; % count
                end
            end

            if ~isempty(kwargs.skew) && ~isempty(kwargs.ort)
                % fit 
                [xf,yf,zf] = prepareSurfaceData(kwargs.skew(:,1),kwargs.skew(:,2),kwargs.ort(:,1));
                kwargs.xfit = fit([xf,yf],zf,'poly11');
                [xf,yf,zf] = prepareSurfaceData(kwargs.skew(:,1),kwargs.skew(:,2),kwargs.ort(:,2));
                kwargs.zfit = fit([xf,yf],zf,'poly11');
            end

            if isempty(kwargs.xfit); kwargs.xfit = @(x,z) x/kwargs.steps(1); end
            if isempty(kwargs.yfit); kwargs.yfit = @(y) y/kwargs.steps(3); end
            if isempty(kwargs.zfit); kwargs.zfit = @(x,z) z/kwargs.steps(2); end

            % transform to LE coordinate system
            args = {scan, scanoffset, kwargs.offset}; flg = false;

            for i = 1:numel(args)
                if isa(args{i}, 'double')
                    args{i} = {num2cell(args{i}, 1)};
                    flg = true;
                end
                for j = 1:numel(args{i})
                    if ~isempty(args{i}{j})
                        temp = args{i}{j};
                        
                        args{i}{j}{1} = kwargs.xfit(temp{1:2});
                        args{i}{j}{3} = kwargs.yfit(temp{3});
                        args{i}{j}{2} = kwargs.zfit(temp{1:2}); 
                    end
                end
                if flg; args{i} = cell2mat(args{i}{1}); flg = false; end
            end

            [scan, scanoffset, kwargs.offset] = deal(args{:});

    end

    % show a scan grid
    if kwargs.show 
        if kwargs.docked; figure(WindowStyle = 'Docked'); else; clf; end
        tile = tiledlayout('flow');
        ax = nexttile(tile); hold(ax, 'on'); box(ax, 'on'); grid(ax, 'on'); axis(ax, 'square')
        colors = colororder;
        colorsw = repmat(colors,1,1,size(scan,1)).*shiftdim(linspace(0.5,1,size(scan,1)),-1);
        colorsw = permute(colorsw, [3, 2, 1]);

        scatter3(ax, scan(:,1), scan(:,2), scan(:,3), kwargs.markersize, colorsw(:,:,1), 'filled', DisplayName = 'scan')
        if ~isempty(kwargs.offset)
            for i = 1:size(kwargs.offset, 1)
                scatter3(ax, kwargs.offset{i,:}{:}, kwargs.markersize, colors(2,:), 'filled', DisplayName = 'base')
            end
        end
        if ~isempty(scanoffset)
            scatter3(ax, scanoffset(:,1), scanoffset(:,2), scanoffset(:,3), kwargs.markersize, colorsw(:,:,3), 'filled', DisplayName = 'offsetted')
        end

        xl = get(ax, 'XLim'); yl = get(ax, 'YLim'); zl = get(ax, 'ZLim');
        fill3([0, xl(2), xl(2), 0], [yl(1), yl(1), yl(2), yl(2)], [0, 0, 0, 0], ...
            colors(1,:), FaceAlpha = 0.1, DisplayName = 'plate');
        fill3([0, 0, 0, 0], [yl(1), yl(2), yl(2), yl(1)], [0, 0, zl(2), zl(2)], ...
            colors(2,:), FaceAlpha = 0.1, DisplayName = 'inlet');

        if kwargs.unit == "count"; kwargs.unit = ""; else; kwargs.unit = ", " + kwargs.unit; end
        xlabel(ax, strcat("axis 1", kwargs.unit)); ylabel(ax, strcat("axis 2", kwargs.unit)); zlabel(ax, strcat("axis 3", kwargs.unit));
        legend(ax); view(ax, [-125, 45]);
    end

    % parse outputs
    varargout{1} = scan;
    varargout{2} = scanoffset;

    % export
    if ~isempty(kwargs.filename)
        if isempty(scanoffset); tab = scan; else; tab = scanoffset; end
        writematrix(tab, strcat(kwargs.filename, kwargs.extention), Delimiter = kwargs.delimiter);
        if exist('fitobj', 'var')
            save(strcat(kwargs.filename, '.mat'), 'fitobj')
        end
    end

    if exist('fitobj', 'var')
        varargout{3} = fitobj;
    end

end