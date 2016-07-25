function nll  = myMNLPMulti( ytrain, ytest, pYpred )
%MYNLP Mean negtive log probability  for multi-class classification
%   Under Categorical distribution likelihood
% pYpred(j) = P(y = class_j), j = 1 ... C
% Assumes ytest(j) in {0,1}
% ytrain: ingnored but kept for consistency with othe loss functions
% [N C] size(ytest) = size(pYpred)

% Matlab reads matrix columnwise so we need to transpose things
pYpred = pYpred';
nll = mean(log(pYpred(logical(ytest')))); 

    
end

