function getdata = guigendata(kwargs)
    
    arguments
        kwargs.class (1,1) = 1
        kwargs.sample (1,:) = []
        kwargs.var (1,:) = []
        kwargs.shape (1,:) char = 'polyline'
        kwargs.xlim (1,:) double = [-2, 2]
        kwargs.ylim (1,:) double = [-2, 2]
        kwargs.zlim (1,:) double = [-2, 2]
        kwargs.mask (:,:) = []
    end

    function result = getdatahandl()
        mask = cell(1, kwargs.class);
        for i = 1:numel(rois)
            mask{i} = rois{i}.Position;
        end
        result = struct(mask = {mask}, data = {data});
    end

    function eventmoved(~, ~)
        for i = 1:numel(rois)
            t = linspace(0,1,size(rois{i}.Position,1));
            [t, x] = prepareCurveData(t, rois{i}.Position(:, 1));
            [~, y] = prepareCurveData(t, rois{i}.Position(:, 2));
            ftx = fit(t, x, 'linearinterp');
            fty = fit(t, y, 'linearinterp');
            ft = @(t) [ftx(t), fty(t)];
            t = linspace(0,1,kwargs.sample(i));
            data{i} = ft(t)+rand(kwargs.sample(i),2)*kwargs.var(i);
        end

        index = [];
        for i = 1:numel(ax.Children)
            if isa(ax.Children(i), 'matlab.graphics.chart.primitive.Line')
                index = cat(1, index, i);
            end
        end

        delete(ax.Children(index))

        for i = 1:numel(data)
            plot(ax, data{i}(:,1), data{i}(:,2), '.', Color =  rois{i}.UserData.color);
        end
    end

    data = cell(1, kwargs.class);
    ft = cell(1, kwargs.class);

    if isempty(kwargs.sample); kwargs.sample = repmat(1e4, kwargs.class); end
    if isempty(kwargs.var); kwargs.var = repmat(0.5, kwargs.class); end

    clf; tiledlayout('flow');
    ax = nexttile; hold on; box on; grid on; xlim(kwargs.xlim); ylim(kwargs.ylim);

    rois = guiselectregion(gca, shape = 'polyline', number = kwargs.class, moved = @eventmoved, mask = kwargs.mask);
    eventmoved();

    getdata = @getdatahandl;

end