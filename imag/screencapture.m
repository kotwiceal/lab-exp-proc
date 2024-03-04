function img = screencapture(kwargs)
    arguments
        kwargs.mask (1,:) double = [0, 0, 2560, 1600]
    end
    % take screen capture
    robot = java.awt.Robot();
    rect = java.awt.Rectangle(kwargs.mask(1), kwargs.mask(2), kwargs.mask(3), kwargs.mask(4));
    cap = robot.createScreenCapture(rect);
    
    % convert to an RGB image
    rgb = typecast(cap.getRGB(0,0,cap.getWidth,cap.getHeight,[],0,cap.getWidth),'uint8');
    img = zeros(cap.getHeight, cap.getWidth, 3, 'uint8');
    img(:,:,1) = reshape(rgb(3:4:end), cap.getWidth, [])';
    img(:,:,2) = reshape(rgb(2:4:end), cap.getWidth, [])';
    img(:,:,3) = reshape(rgb(1:4:end), cap.getWidth, [])';
end