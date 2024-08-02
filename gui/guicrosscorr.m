function getdata = guicrosscorr(varargin, kwargs)
    %% Visualize cross-correlation function of selected by rectangle ROI data.

    arguments (Repeating)
        varargin double % data
    end

    arguments
        kwargs.x (:,:) double = []

        kwargs.y (:,:) double = []
        kwargs.index (1,2) = [1, 2]
        %% data preparing parameters
        kwargs.norm (1,1) logical = true % norm auto/scross-correlation
        kwargs.center (1,:) char {mustBeMember( kwargs.center, {'none', 'poly11', 'mean'})} = 'mean' % center data
        %% roi and axis parameters
        kwargs.mask (1,:) double = [] % location and size of rectangle selection
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.xlabel (1,:) char = [] % x-axis label of field subplot
        kwargs.ylabel (1,:) char = [] % y-axis label of field subplot
        kwargs.cxlabel (1,:) char = [] % x-axis label of field subplot
        kwargs.cylabel (1,:) char = [] % y-axis label of field subplot
        kwargs.clim (1,:) double = [0, 255] % color axis limit
        kwargs.climcor (1,:) double = []
        kwargs.cscale (1,:) char {mustBeMember(kwargs.cscale, {'linear', 'log'})} = 'linear' % colormap scale
        kwargs.display (1,:) char {mustBeMember(kwargs.display, {'2d', '3d'})} = '2d' % display type
        kwargs.aspect (1,:) {mustBeA(kwargs.aspect, {'char', 'cell'}), mustBeMember(kwargs.aspect, {'equal', 'auto', 'manual', 'image', 'square'})} = 'image' % axis ratio
        kwargs.docked (1,1) logical = false % docked figure
        kwargs.colormap (1,:) char = 'turbo' % colormap of color axis
        kwargs.title (:,:) char = [] % figure title
        kwargs.filename (1,:) char = [] % filename to save figure
        kwargs.extension (1,:) char = '.png' % extension of saved figure
    end

    function result = getdatafunc()
        result = struct(corrmat = {corrmat});
    end

    corrmat = [];

    % define funtion handle to probe data
    select = cell(1, numel(varargin));
    for i = 1:numel(varargin)
        select{i} = @(roiobj) guigetdata(roiobj, varargin{i}, shape = 'cut', permute = [2, 1]);
    end

    function moved(~, ~)
        data = cell(1, numel(varargin));
        for i = 1:numel(varargin)
            % extract data
            temp = select{i}(rois{1});
            % centering data
            switch kwargs.center
                case 'poly11'
                    sz = size(temp);
                    [xc, yc] = meshgrid(1:sz(2), 1:sz(1));
                    [xcp, ycp, framep] = prepareSurfaceData(xc, yc, temp);
                    frameft = fit([xcp, ycp], framep, 'poly11');
                    temp = temp - frameft(xc, yc); 
                case 'mean'
                    temp = temp - mean(temp, [1, 2]);
            end
            data{i} = temp;
        end
        % process auto/cross-correlation
        if kwargs.norm; method = @normxcorr2; else; method = @xcorr2; end
        method = @(x, y) rescale(real(fftshift(fftshift(ifft2(fft2(x).*conj(fft2(y))),1),2)));
        corrmat = [];
        for i = 1:numel(varargin)
            for j = 1:numel(varargin)
                corrmat(:,:,i,j) = method(data{i}, data{j});
            end
        end
        % display
        cla(ax); 
        switch kwargs.display
            case '2d'
                if isempty(kwargs.index)
                    imagesc(ax, imtile(corrmat(:,:,:))); axis(ax, 'image');
                else
                    imagesc(ax, corrmat(:,:,kwargs.index(1),kwargs.index(2)));
                end
                axis(ax, 'image');
            case '3d'
                surf(ax, corrmat(:,:,kwargs.index(1),kwargs.index(2)), LineStyle = 'None');
                axis(ax, 'square'); box(ax, 'on'); grid(ax, 'on');
        end
        colorbar(ax); colormap(ax, kwargs.colormap);
        set(ax, 'ColorScale', kwargs.cscale); 
        if ~isempty(kwargs.climcor); clim(ax, kwargs.climcor); end
        if ~isempty(kwargs.cxlabel); xlabel(kwargs.cxlabel); end
        if ~isempty(kwargs.cylabel); ylabel(kwargs.cylabel); end
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); axroi = nexttile;
    imagesc(imfuse(mat2gray(varargin{1}, kwargs.clim), mat2gray(varargin{2}, kwargs.clim))); axis(axroi, kwargs.aspect);
    if ~isempty(kwargs.xlabel); xlabel(kwargs.xlabel); end
    if ~isempty(kwargs.ylabel); ylabel(kwargs.ylabel); end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, moving = @moving, moved = @moved, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 1);

    moved();

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

    getdata = @getdatafunc;

    function moving(~,~)
        % title(axroi, jsonencode(floor(rois{1}.Position([3, 4]))), FontWeight = 'Normal');
    end

end