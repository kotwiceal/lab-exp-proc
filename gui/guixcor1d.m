function getdata = guixcor1d(varargin, kwargs)
    arguments (Input, Repeating)
        varargin double {mustBeVector}
    end

    arguments (Input)
        kwargs.x (1,:) double = [];
        kwargs.fs (1,:) double = 25e3
        kwargs.xlim (1,:) double = []
        kwargs.mask (1,:) double = []
        kwargs.showrescaled (1,1) logical = true
    end
    
    figure(WindowStyle = 'docked'); tile = tiledlayout('flow');
    axroi = nexttile(tile); hold(axroi, 'on'); box(axroi, 'on'); grid(axroi, 'on');

    if isempty(kwargs.x); kwargs.x = (0:(numel(varargin{1})-1))/kwargs.fs; end
    val2ind = @(dx) kwargs.x>=dx(1) & kwargs.x<=dx(2);

    if kwargs.showrescaled
        for i = 1:nargin; plot(axroi,kwargs.x, rescale(varargin{i},0,1)+i-1); end
    else
        for i = 1:nargin; plot(axroi, kwargs.x, varargin{i}); end
    end
    if ~isempty(kwargs.xlim); xlim(axroi, kwargs.xlim); end

    rois = guiselectregion(axroi,moving=@moving,moved=@moved,shape='rect',number=1,mask=kwargs.mask);
    
    axtarg = nexttile(tile);
    
    moving();
    if ~isempty(kwargs.mask); moved(); end

    function moving(~,~)
        yl = get(axroi,'ylim');
        rois{1}.Position = [rois{1}.Position(1), yl(1), rois{1}.Position(3), yl(2)-yl(1)];
    end

    function moved(~,~)
        index = val2ind([rois{1}.Position(1),rois{1}.Position(1)+rois{1}.Position(3)]);

        t = [];
        data = [];
        for i = 1:nargin
            temp = varargin{i}(index);
            temp = normalize(temp,'center');
            data = cat(2, data, temp);
        end

        res = conv(data(:,1),data(:,2));
        t = ((0:numel(res)-1)-numel(res)/2)/kwargs.fs;

        cla(axtarg); hold(axtarg, 'on'); box(axtarg, 'on'); grid(axtarg, 'on');
        axis(axtarg, 'auto')
        plot(axtarg, t, res)
    end

end