function y = cell2arr(x, param)
    arguments (Input)
        x cell
        param.serialwrap (1,1) logical = false
    end
    arguments (Output)
        y double
    end
    
    if param.serialwrap
        y = zeros(numel(x), numel(x{1}));
        for i = 1:numel(x)
            y(i,:) = x{i};
        end
        y = reshape(y, numel(x), size(x{1}));
        y = shiftdim(y, -1);
    else
        wrapper = @(x) squeeze(permute(reshape(cell2mat(x), [size(x{1}, 1), numel(x), size(x{1}, 2:ndims(x{1}))]), [1, (1:ndims(x{1}))+2, 2]));
        y = wrapper(x);
    end

end