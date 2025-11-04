function roi = drawxrange(varargin, options)
    arguments (Input, Repeating)
        varargin 
    end

    arguments (Input)
        options.?images.roi.Rectangle
    end

    arg = namedargs2cell(options);
    if isempty(varargin)
        roi = drawrectangle(arg{:});
    else
        roi = drawrectangle(varargin{1}, arg{:});
    end

    addlistener(roi, 'MovingROI', @event)
    
end

function event(~, evt)
    limits = evt.Source.Parent.YLim;
    evt.Source.Position([2,4]) = [limits(1), limits(2)-limits(1)];
end