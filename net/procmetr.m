function res = procmetr(T, Y, param)
    arguments (Input)
        T {mustBeA(T, {'double', 'cell'})} % target data
        Y {mustBeA(Y, {'double', 'cell'})} % predict data
        param.type {mustBeMember(param.type, {'none', 'segmentation'})} = 'none'
        param.ans {mustBeMember(param.ans, {'struct', 'table'})} = 'struct'
    end
    arguments (Output)
        res {mustBeA(res, {'struct', 'table'})}
    end

    if isa(T, 'cell'); T = cell2arr(T); end
    if isa(Y, 'cell'); Y = cell2arr(Y); end

    res = struct;

    % estimate confusion matrix
    res.tp = T.*Y;
    res.tn = (1-T).*(1-Y);
    res.fn = T.*(1-Y);
    res.fp = (1-T).*Y;
    
    res.n = res.tp+res.tn+res.fn+res.fp;
    res.p = (res.tp+res.fp)./res.n;
    
    res.prec = res.tp./(res.tp+res.fp); % precision
    res.sens = res.tp./(res.tp+res.fn); % sensivify
    res.spec = res.tn./(res.tn+res.fp); % specificity
    res.acc = (res.tp+res.tn)./(res.p+res.n); % accuracy
    res.f1 = (2 .* res.prec .* res.sens) ./ (res.prec + res.sens); % f1-score

    switch param.type
        case 'segmentation'

            temp = struct2cell(res);

            temp1 = cellfun(@(x) {mean(x, [3, 4], 'omitmissing')}, temp, UniformOutput = false);
            temp2 = cellfun(@(x) mean(x, 'all', 'omitmissing'), temp, UniformOutput = false);

            tab1 = table(temp1{:}, VariableNames = fieldnames(res)+"m");
            tab2 = table(temp2{:}, VariableNames = fieldnames(res)+"mm");

            res1 = cellfun(@(x) {x}, struct2cell(res), UniformOutput = false);
            res1 = table(res1{:}, VariableNames = fieldnames(res));
            
            res = table2struct([res1, tab1, tab2]);

    end

    switch param.ans
        case 'table'
            res = struct2table(res, AsArray = true);
    end

end