function roi = drawyline(varargin, options)
    arguments (Input, Repeating)
        varargin 
    end

    arguments (Input)
        options.?images.roi.Line
    end

    arg = namedargs2cell(options);
    if isempty(varargin)
        roi = drawline(arg{:});
    else
        roi = drawline(varargin{1}, arg{:});
    end

    addlistener(roi, 'MovingROI', @event)
    
    event([], roi)

end

function event(~, evt)
    switch class(evt)
        case 'images.roi.Line'
            roi = evt;
        case 'images.roi.ROIMovingEventData'
            roi = evt.Source;
    end
    roi.Position(:,1) = mean(roi.Position(:,1));
    roi.Position(:,2) = roi.Parent.YLim;
end