function varargout = roigetdata(roi, varargin, kwargs)

    arguments (Input)
        roi {mustBeA(roi, {'images.roi.Point', 'images.roi.Line', 'images.roi.Polyline', ...
            'images.roi.Rectangle', 'images.roi.Polygon'})} % ROI object to select data
    end

    arguments (Input, Repeating)
        varargin
    end

    arguments (Input)
        kwargs.dims (1,:) {mustBeInteger, mustBeGreaterThan(kwargs.dims, 0)} = 1
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'raw', 'cut', 'flatten'})} = 'raw' % shape of output data
        kwargs.position double = []
        kwargs.size double = []
        kwargs.permute (1,2) double = [1, 2]
    end

    arguments(Output, Repeating)
        varargout
    end

    data = cell(numel(kwargs.dims) + 1, 1);
    [data{:}] = splitdatcell(varargin{:}, dims = kwargs.dims);

    for i = 1:numel(data)
        tf = inpolygon(data{1}{i}(:),data{2}{i}(:),roi.Position(:,1),roi.Position(:,2));
        data{3}{i}(~tf) = nan;
    end


    try
        temp = cell2arr(data{3});
    catch
        temp = data{3};
    end

    varargout{1} = temp;

    % for i = 1:numel(data)
    % 
    %     switch class(roi)
    %         case 'images.roi.Point'
    % 
    %         case 'images.roi.Line'
    % 
    %         case 'images.roi.Polyline'
    % 
    %         case 'images.roi.Rectangle'
    %             for j = 1:numel(roi.UserData.subind)
    %                 [xmin, xmax] = bounds(roi.UserData.subind{j});
    %                 roi.UserData.subind{j} = xmin:xmax;
    %             end
    %         case 'images.roi.Polygon'
    % 
    %     end
    % 
    % end

end