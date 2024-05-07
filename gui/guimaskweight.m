function getdata = guimaskweight(data, kwargs)
    %% Interactive weighting of multifram two-dimensional data.
    %% The function returns following results:
    %   getdata:        [function_handle]       - function returning results at the last polygon displacements
    
    %% Examles:
    %% 1. Extract weighted multi frame two-dimensional data by specified polygonal window:
    % % window is unique for each data along 3 dimensional axis
    % prepresfunc = guimaskweight(data.vmnavgsub, clim = [-0.1, 0.1], mask = [0, 230; 0, 200; 321, 60; 321, 100]);
    % prepres = prepresfunc();

    arguments
        data double % two-dimensional multiframe data
        kwargs.tukey double = 1 % tukey window function parmeter
        %% roi and axis parameters
        kwargs.mask double = [] % four-vertex polygon
        kwargs.docked logical = true % docked figure flag
        kwargs.aspect (1,:) char {mustBeMember(kwargs.aspect, {'equal', 'auto'})} = 'equal' % axis aspect ratio
        kwargs.clim double = [] % colorbar limit
    end

    sz = size(data); 
    if numel(sz) == 2; sz(3) = 1; end 
    rois = cell(1, sz(3));
    mask = []; rawc = zeros(sz); bin = []; win = []; select = cell(1, sz(3)); selectwin = cell(1, sz(3));

    % define selection function handles 
    for i = 1:sz(3)
        select{i} = @(roiobj) guigetdata(roiobj, squeeze(data(:,:,i,:)), shape = 'raw');
        selectwin{i} = @(roiobj) guigetdata(roiobj, ones(sz(1:2)), shape = 'raw');
    end

    function eventroiselmoving(~, event)
        temp = event.Source.Position;
        event.Source.Position = [0, temp(1, 2); 0, temp(2, 2); sz(2)+1, temp(3, 2); sz(2)+1, temp(4, 2)];
    end

    function result = getdatafunc()
        mask= [];
        for i = 1:length(rois)
            mask(:,:,i) = rois{i}.Position;
            temp = select{i}(rois{i}); temp(isnan(temp)) = 0;
            rawc(:,:,i,:) = temp;
            bin(:,:,i) = selectwin{i}(rois{i}); bin(isnan(bin)) = 0;
            win(:,:,i) = genwin(bin(:,:,i), tukey(i));
        end
        rawcw = rawc.*win;
        result = struct(rawc = rawc, mask = mask, bin = bin, win = win, rawcw = rawcw);
    end

    function win = genwin(binl, h)
        win = zeros(size(binl));
        for j = 1:size(win, 2)
            index = binl(:, j) == 1; w = sum(index);
            win(index, j) = tukeywin(w, h);
        end
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end; tiledlayout('flow');

    if ndims(kwargs.mask) == 3;  mask = kwargs.mask; else; mask = repmat(kwargs.mask, 1, 1, sz(3)); end
    if ndims(kwargs.clim) == 3;  cl = kwargs.clim; else; cl = repmat(kwargs.clim, 1, 1, sz(3)); end
    if numel(kwargs.tukey) == 1; tukey = repmat(kwargs.tukey, 1, sz(3)); else; tukey = kwargs.tukey; end 

    for i = 1:sz(3)
        nexttile; axroi = gca; imagesc(axroi, data(:,:,i,end)); xlim([0, sz(2)+1]); axis image;
        if ~isempty(cl(:,:,i)); clim(cl(:,:,i)); end
        temp = guiselectregion(axroi, moving = @eventroiselmoving, shape = 'poly', ...
            mask = mask(:, :, i), interaction = 'all', number = 1);
        rois{i} = temp{1};
    end

    getdata = @getdatafunc;

end