function loss = tverskyloss(Y, T, param)
    %% Calculate Tversky loss.

    arguments (Input)
        Y % predict data
        T % target data
        param.alpha (1,1) = 0.5
        param.beta (1,1) = 0.5
        param.epsilon (1,1) = 1e-8
    end
    arguments (Output)
        loss 
    end

    % loss = tverskyLoss(Y,T,alpha,beta) returns the Tversky loss
    % between the predictions Y and the training targets T.   
    
    TP = sum(Y.*T, [1, 2]);
    FP = sum(Y.*(1-T), [1, 2]);
    FN = sum((1-Y).*T, [1, 2]); 
    numer = TP + param.epsilon;
    denom = TP + param.alpha*FP + param.beta*FN + param.epsilon;
    
    % Compute tversky index.
    lossTIc = 1 - numer./denom;
    lossTI = sum(lossTIc, 3);
    
    % Return average Tversky index loss.
    N = size(Y, 4);
    loss = sum(lossTI)/N;

end