function [y0, z0, x0] = findoffsetcta(filename, kwargs)
    %% Find offset vertical coordinates by specified velocity isoline level.

    arguments (Input)
        %% imput
        filename (1,:) {mustBeA(filename , {'char', 'string'})} % path to scan.txt file or folder
        kwargs.scandelimiter (1,:) char = '\t'
        kwargs.scanseparator (1,:) char = ','
        kwargs.numch (1,1) double = 3
        %% processing
        kwargs.isovel (1,1) double = 10 % cutoff velocity
        kwargs.y (:,:) double = [] % vertical vector
        kwargs.yi (1,:) double = [] % initial approximation
        kwargs.ratio (1,:) double = [] % dimensionless velocity at which the vertical position is assumed to be zero 
        kwargs.reshape (1,:) double = [] % reshape scan to gridwise notation
        kwargs.smooth (1,:) char {mustBeMember(kwargs.smooth, {'none', 'moving', 'lowess', 'loess', 'sgolay', 'rlowess', 'rloess'})} = 'none' % smoothing method
        kwargs.span (1,1) double = 5 % number of data points for calculating the smoothed value 
        %% appearance
        kwargs.show (1,1) logical = true % display resutls
        kwargs.docked (1,1) logical = false % dock figure
    end

    if isfolder(filename)
        data = loadcta(filename,numch=kwargs.numch);
    else
        if isfile(filename)
            data.scan = table2array(readtable(filename, Delimiter = kwargs.scandelimiter, DecimalSeparator = kwargs.scanseparator));
        else
            error('scan file isn`t found')
        end
    end

    if isempty(kwargs.y)
        y = data.scan(:,3);
    else
        y = kwargs.y;
    end

    x = data.scan(:,1);
    z = data.scan(:,2);
    v = data.scan(:,4);

    if isempty(kwargs.reshape)
        kwargs.reshape = [numel(unique(y)), numel(unique(z)), numel(unique(x))];
    end

    x = reshape(x,kwargs.reshape);
    z = reshape(z,kwargs.reshape);
    y = reshape(y,kwargs.reshape);
    v = reshape(v,kwargs.reshape);

    % exclude near wall points
    v = v(:,:); y = y(:,:);
    index = cumsum(v >= kwargs.isovel, 1) == repmat((1:size(v,1))',1,size(v,2));
    v(~index) = nan;
    y(~index) = nan;

    % smooth profiles
    if kwargs.smooth ~= "none"
        for i = 1:size(v, 2)
            v(:, i) = smooth(y(:,i), v(:, i), kwargs.span, kwargs.smooth);
        end
    end

    % piecewise linear interpolation
    vf = cell(1, size(v, 2));
    for i = 1:size(v, 2)
        [y0,v0] = prepareCurveData(y(:,i),v(:,i));
        vf{i} = fit(y0,v0,'linearinterp');
    end

    % find offset
    if isempty(kwargs.yi)
        kwargs.yi = zeros(1,numel(vf));
    end
    
    y0 = zeros(1,numel(vf));
    if ~isempty(kwargs.ratio)
        kwargs.isovel = kwargs.ratio*max(v,[],1,'omitmissing');
    else
        kwargs.isovel = repmat(kwargs.isovel,1,numel(vf));
    end
    for i = 1:numel(vf)
        y0(i) = fsolve(@(x)vf{i}(x)-kwargs.isovel(i),kwargs.yi(i));
    end
    y0 = round(y0);
    z0 = z(1,:);
    x0 = x(1,:);

    % show results
    if kwargs.show
        if kwargs.docked; figure(WindowStyle = 'docked'); else; clf; end
        hold on; grid on; box on; axis square;
        plt = plot(y,v,'.-');
        l = legend(plt, "("+string(split(num2str(x0)))+";"+string(split(num2str(z0)))+")"); 
        title(l,'(x,z), count',FontWeight='normal');
        scatter(y0,kwargs.isovel,'filled',DisplayName='isovel')
        xlabel('y, conut'); ylabel('u, m/s');
    end 

end