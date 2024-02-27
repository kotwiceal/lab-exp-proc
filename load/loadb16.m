function images = loadb16(input, kwargs)
%% Load PCO *.b16 image files
%% The function takes following arguments:
%   input:              [string array]      - folder path or filenames array
%   subfolders:         [1×1 logical]       - search files in subfolders
%% The function returns following results:
%   images:             [n×m×.. double]     - loaded image set
%% Examples:
%% 1. Load single image:
% image = loadb16("\test.b16")
%% 2. Load set images located in folder:
% image = loadb16("\test")
%% 2. Load set images located in folder with subfolders:
% image = loadb16("\test", subfolders = true)

%% NOTE:
% Reference code by Carl Hall (2016)
%% b16 header byte structure:
% Bytes    Type      Description
% 4        chars     "PCO-" 
% 4        int32     File size in byte       
% 4        int32     file size in byte 
% 4        int32     header size + comment filed in byte
% 4        int32     image width in pixel 
% 4        int32     image height in pixel 
% 4        int32     -1 (true), extended header follow
% 4        int32     0 = black/with camera, 1 = color camer
% 4        int32     black/white LUT-setting, minimum value 
% 4        int32     black/white LUT-setting, maximum value 
% 4        int32     black/white LUT-setting, 0 = linear, 1 = logarithmic 
% 4        int32     red LUT-setting, minimum value 
% 4        int32     red LUT-setting, maximum value 
% 4        int32     green LUT-setting, minimum value 
% 4        int32     green LUT-setting, maximum value 
% 4        int32     blue LUT-setting, minimum value 
% 4        int32     blue LUT-setting, maximum value 
% 4        int32     color LUT-setting, 0 = linear, 1 = logarithmic 
% ?        int32     internal use
% ?        chars     Comment file in ASCII characters with variable length of 0...XX. 
%                              The length of the comment filed must be documented in the �header length� field. 
%          uint16    16 bit pixel data, starting at offset given by the 'header size' int32

    arguments
        input (:,:) string
        kwargs.subfolders logical = false
        kwargs.extension char = '.b16'
    end

    if numel(input) == 1
        if isfolder(input)
            kwargs.filenames = getfilenames(input, extension = kwargs.extension, subfolders = kwargs.subfolders);
        else
            kwargs.filenames = input;
        end
    else
        kwargs.filenames = input;
    end

    images = [];

    for i = 1:numel(kwargs.filenames)
        % Open the file
        fd = fopen(kwargs.filenames(i), 'r');
        if(fd < 0)
            error('Could not open file: %s', kwargs.filenames(i))
        end
        % Check that it is a PCO file
        filetype = fread(fd, 4, 'char');
        if(char(filetype') ~= "PCO-")
            error('Wrong filetype: %s',char(filetype'))
        end
        % Get the image dimensions:
        fileSize   = fread(fd, 1, 'int32');  % not used
        headLength = fread(fd, 1, 'int32');  % offset for image data
        imgWidth   = fread(fd, 1, 'int32');  %
        imgHeight  = fread(fd, 1, 'int32');  %
        % look into the extended header, and thow error if color image
        extHeader  = fread(fd, 1, 'int32');
        if(extHeader == -1)
        colorMode  = fread(fd, 1, 'int32');
        if(colorMode ~= 0)
            error('Color image detected. Only b/w images have been tested with this function')
        end
        end
        % Get the image
        fseek(fd, headLength, 'bof');
        image = fread(fd, [imgWidth, imgHeight], 'uint16');
        % rotate and flip image to suit user
        image = flipud(image');  
        images(:,:,i) = image;
    end

    images = reshape(images, [size(images, 1:2), size(kwargs.filenames)]);

end
