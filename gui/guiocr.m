function varargout = guiocr(data, kwargs)
    arguments
        data % image gray or RGB
        kwargs.mask (1,:) double = []
        kwargs.interaction (1,:) char {mustBeMember(kwargs.interaction, {'all', 'none', 'translate'})} = 'all'
        kwargs.docked logical = false
    end

    ocrres = [];

    function event(~, ~)

        ocrres = ocr(data, rois{1}.Position);

        dataocr = insertObjectAnnotation(data, 'rectangle', ...
            ocrres.WordBoundingBoxes, ocrres.Words, LineWidth = 1, FontSize = 10);

        cla(ax); imshow(dataocr, Parent = ax); axis(ax, 'image');
        xlim(ax, [rois{1}.Position(1), rois{1}.Position(1)+rois{1}.Position(3)])
        ylim(ax, [rois{1}.Position(2), rois{1}.Position(2)+rois{1}.Position(4)])
    end

    function result = getdatafunc()
        result = struct(orc = ocrres, img = imcrop(data, rois{1}.Position));
    end

    if kwargs.docked; figure('WindowStyle', 'Docked'); else; clf; end
    tiledlayout('flow'); axroi = nexttile;
    imagesc(axroi, data); axis(axroi, 'image');

    nexttile; ax = gca;
    rois = guiselectregion(axroi, moved = @event, shape = 'rect', ...
        mask = kwargs.mask, interaction = kwargs.interaction, number = 1);
    event();

    varargout{1} = @getdatafunc;

end