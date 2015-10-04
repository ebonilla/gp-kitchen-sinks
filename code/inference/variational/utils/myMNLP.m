function nll  = myMNLP( ytrain, ytest, pYpred )
%MYNLP Mean negtive log probability  
%   Under Bernoulli's likelihood
% pYpred: p(ypred = 1)
% Assumes ytest in {0,1}
% ytrain: ingnored but kept for consistency with othe loss functions
nll = sum(-(ytest .* log(pYpred) + (1 - ytest) .* log(1 - pYpred))) / length(ytest);
    

end

