function [U, S, V] = guipod(varargin, kwargs)
    arguments (Repeating, Input)
        varargin
    end
    arguments (Input)
        kwargs.plot = 'contourf'
        kwargs.show (1,1) logical = true
        kwargs.indexes (1, 2) double = [1, 1]
    end
    % arr=[320 175; 350 190; 350 177; 320 165]-2
    %data input 2D field of scalars
    %x is x
    % z is z -- both coordinates of the same size as data
    %arr is 4x2 array of edges of 4-edge mask. Points are entered clockwise
    %plotflag is to turn on/off figure with crop results
    
    
    %datacrop is sparce matrix with cropped data or array of sparce matrices
    
    data = varargin;
    data{end} = data{end}(:,:,1);

    data = guiplot(data{:}, plot = kwargs.plot, linestyle = 'none', docked = true, ...
        aspect = 'equal');
    % set(gcf,'WindowKeyPressFcn',@KeyPressFcn);
    ind = zeros(size(data{end}{1}));
    % global running;
    running = true;
    while running
        try
            pol = drawpolygon();
            ind = inpolygon(data{1}{1}, data{2}{1}, pol.Position(:, 1), pol.Position(:, 2)) | ind;
        catch
            break;
        end
    end

    data{end}{1} = data{end}{1}.*ind;
    varargin{end} = varargin{end}.*ind;

    if kwargs.show
        data = guiplot(data{:}, plot = kwargs.plot, linestyle = 'none', docked = true, ...
                aspect = 'equal');
    end
    
    x = varargin{end};
    x = shiftdim(x, 2);
    x = x(:, :);
    x = x';

    [i,j,v] = find(x);
    v = reshape(v, [], size(varargin{end}, 3));
    [Ut,St,Vt] = svd(v);
    
    V = Vt;
    S = St;
    
    U = zeros([size(varargin{end},1,2), numel(find(ind))]);
    U(repmat(ind, 1, 1, numel(find(ind)))) = Ut;
    
end