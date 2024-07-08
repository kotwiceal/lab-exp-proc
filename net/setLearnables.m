function net = setLearnables(net, learnables, szl)
    %% Set learnables to dlnetwork.

    arguments
        net (1,1) dlnetwork
        learnables (:,1) dlarray
        szl (1,:) cell
    end

    indb = 1;
    for i = 1:numel(szl)
        indu = prod(szl{i});
        temp = reshape(learnables(indb:indb+indu-1), szl{i});
        indb = indu + 1;
        net.Learnables{i, 3}{1} = temp;
    end
end