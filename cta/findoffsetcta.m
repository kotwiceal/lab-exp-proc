function [y0, z0] = findoffsetcta(filename, kwargs)
    %% Find offset vertical coordinates by specified velocity isoline level.

    arguments (Input)
        filename (1,:) {mustBeA(filename , {'char', 'string'})}
        kwargs.isovel (1,1) double = 10
        kwargs.tonan (1,1) logical = true
        kwargs.numch (1,1) double = 3
        kwargs.show (1,1) logical = true
        kwargs.reshape (1,:) double = []
        kwargs.scandelimiter (1,:) char = '\t'
        kwargs.scanseparator (1,:) char = ','
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

    z = data.scan(:,2);
    y = data.scan(:,3);
    v = data.scan(:,4);

    if isempty(kwargs.reshape)
        kwargs.reshape = [numel(unique(y)), numel(unique(z))];
    end

    z = reshape(z,kwargs.reshape);
    y = reshape(y,kwargs.reshape);
    v = reshape(v,kwargs.reshape);

    % exclude near wall points
    index = cumsum(v >= kwargs.isovel, 1) == repmat((1:size(v,1))',1,size(v,2));
    v(~index) = nan;

    % piecewise linear interpolation
    vf = {}; yf = {};
    for i = 1:size(v, 2)
        [y0,v0] = prepareCurveData(y(:,i),v(:,i));
        vf{i} = fit(y0,v0,'linearinterp');
        yf{i} = fit(v0,y0,'linearinterp');
    end

    % find offset
    y0 = zeros(1,numel(vf));
    for i = 1:numel(vf)
        y0(i) = fsolve(@(x)vf{i}(x)-kwargs.isovel,0);
    end
    y0 = round(y0);
    z0 = z(1,:);

    % show results
    if kwargs.show
        figure(WindowStyle='docked'); hold on; grid on; box on; axis square;
        plt = plot(y,v,'.-');
        l = legend(plt,num2str(z0')); title(l,'z, count',FontWeight='normal');
        scatter(y0,ones(1,numel(y0))*kwargs.isovel,'filled')
        xlabel('y, conut'); ylabel('u, m/s');
    end 

end