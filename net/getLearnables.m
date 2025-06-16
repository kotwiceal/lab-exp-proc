function [learnables, szl, nl] = getLearnables(net, kwargs)
    % get learnables of dlnetwork.

    arguments
        net (1,1) dlnetwork
        kwargs.shape (1,:) char {mustBeMember(kwargs.shape, {'array', 'cell'})} = 'array'
        kwargs.ans (1,:) char {mustBeMember(kwargs.ans, {'dlarray', 'double'})} = 'dlarray' 
    end

    sz = size(net.Learnables); nl = [];
    learnables = []; szl = cell(1, sz(1));
    for i = 1:sz(1)
        temp = net.Learnables{i, 3}{1};
        szl{i} = size(temp);
        switch kwargs.ans
            case 'double'
                temp = double(gather(extractdata(temp)));
        end
        switch kwargs.shape
            case 'array'
                learnables = cat(1, learnables, temp(:));
            case 'cell'
                learnables{i} = temp;
        end
    end

    temp = 0;
    for j = 1:numel(szl)
        temp = temp+prod(szl{j});
    end
    nl = temp;

end