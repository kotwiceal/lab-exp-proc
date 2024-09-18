function getdata = guicrosscorr(varargin, kwargs)
    %% Visualize cross-correlation function of selected by rectangle ROI data.

    arguments (Input, Repeating)
        varargin % data
    end

    arguments (Input)
        kwargs.x (:,:) double = []
        kwargs.y (:,:) double = []
        kwargs.index (1,:) = [1, 2]
        %% data preparing parameters
        kwargs.center (1,:) char {mustBeMember(kwargs.center, {'none', 'poly11', 'mean'})} = 'mean' % center data
        kwargs.method (1,:) char {mustBeMember(kwargs.method, {'xcorr2', 'normxcorr2', 'fft', 'normfft'})} = 'fft' % select method processing
        kwargs.contex (1,:) char {mustBeMember(kwargs.contex, {'none', 'piv'})} = 'none'
        kwargs.contexpiv (1,:) char {mustBeMember(kwargs.contexpiv, {'diff', 'montage', 'checkerboard', 'blend', 'falsecolor'})} = 'montage'
        kwargs.msz (1,:) double = [];
        %% roi and axis parameters
        kwargs.mask (1,:) double = [] % location and size of rectangle selection
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all' % region selection behaviour
        kwargs.oringcenter (1,1) logical = true
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

    data = cell(1, numel(varargin)); corrmat = []; x = []; y = [];

    for i = 1:nargin
        varargin{i} = double(varargin{i});
    end

    % define funtion handle to probe data
    select = cell(1, numel(varargin));
    for i = 1:numel(varargin)
        select{i} = @(roiobj) guigetdata(roiobj, varargin{i}, shape = 'cut', permute = [2, 1]);
    end

    switch kwargs.method
        case 'xcorr2'
            method = @(x,y) mean(xcorr2(x,y),3);
        case 'normxcorr2'
            method = @(x,y) mean(normxcorr2(x,y),3);
        case 'fft'
            method = @(x,y) mean(real(fftshift(fftshift(ifft2(fft2(x).*conj(fft2(y))),1),2)),3);
        case 'normfft'
            method = @(x,y) mean(real(fftshift(fftshift( ifft2( fft2(x).*conj(fft2(y))./sqrt(abs(fft2(x)).^2.*abs(fft2(y)).^2) ), 1),2)),3);
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); axroi = nexttile;
    switch nargin
        case 1
            imagesc(mat2gray(varargin{1}, kwargs.clim)); axis(axroi, kwargs.aspect);
        otherwise
        imagesc(imfuse(mat2gray(varargin{1}(:,:,1), kwargs.clim), mat2gray(varargin{2}(:,:,1), kwargs.clim))); axis(axroi, kwargs.aspect);
    end
    if ~isempty(kwargs.xlabel); xlabel(kwargs.xlabel); end
    if ~isempty(kwargs.ylabel); ylabel(kwargs.ylabel); end

    nexttile; ax = gca;
    rois = guiselectregion(axroi, moved = @moved, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 1);

    moved();

    if ~isempty(kwargs.title); sgtitle(kwargs.title); end

    if ~isempty(kwargs.filename)
        savefig(gcf, strcat(kwargs.filename, '.fig'))
        exportgraphics(gcf, strcat(kwargs.filename, kwargs.extension), Resolution = 600)
    end

    getdata = @getdatafunc;

    function moved(~, ~)
        prepdata()
        proccorrmat()
        plotcorrmat()
        switch kwargs.contex
            case 'piv'
                vec = pivker(data{1}, data{2}, method = kwargs.method, msz=kwargs.msz);
                [~, linind] = pivfindlocmax(corrmat(:,:,1,2),method='morph',msz=kwargs.msz);
                disp(strcat("vec=",num2str(vec)));
                switch kwargs.contexpiv
                    case 'mongage'
                        imagesc(ax, imfuse(corrmat(:,:,1,2), double(linind), kwargs.contexpiv));
                    otherwise
                        imagesc(ax, x, y, imfuse(corrmat(:,:,1,2), double(linind), kwargs.contexpiv));    
                end
                 axis(ax, 'image'); colormap(ax, kwargs.colormap);
        end
    end

    function prepdata()
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
    end

    function proccorrmat()
        %% process auto/cross-correlation
        corrmat = [];
        for i = 1:numel(varargin)
            for j = 1:numel(varargin)
                corrmat(:,:,i,j) = method(data{i}, data{j});
            end
        end
    end

    function plotcorrmat()
        switch kwargs.display
            case '2d'
                x = [1, size(corrmat, 1)];
                y = [1, size(corrmat, 2)];
                if kwargs.oringcenter 
                    x = x-size(corrmat,1)/2;
                    y = y-size(corrmat,2)/2;
                end
                if isempty(kwargs.index)
                    imagesc(ax, x, y, imtile(corrmat(:,:,:), GridSize = size(corrmat, 3:4))); axis(ax, 'image');
                else
                    imagesc(ax, x, y, corrmat(:,:,kwargs.index(1),kwargs.index(2)));
                end
                axis(ax, 'image');
            case '3d'
                if isempty(kwargs.index)
                    surf(ax, imtile(corrmat(:,:,:), GridSize = size(corrmat, 3:4)), LineStyle = 'None');
                else
                    surf(ax, corrmat(:,:,kwargs.index(1),kwargs.index(2)), LineStyle = 'None');
                end
                axis(ax, 'square'); box(ax, 'on'); grid(ax, 'on');
        end
        colorbar(ax); colormap(ax, kwargs.colormap);
        set(ax, 'ColorScale', kwargs.cscale); 
        if ~isempty(kwargs.climcor); clim(ax, kwargs.climcor); end
        if ~isempty(kwargs.cxlabel); xlabel(kwargs.cxlabel); end
        if ~isempty(kwargs.cylabel); ylabel(kwargs.cylabel); end
    end

    function result = getdatafunc()
        result = struct(corrmat = {corrmat});
    end

end