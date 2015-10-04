function errRate  = myErrorRate( ytrain, ytest, pYpred )
%MYERRORRATE Summary of this function goes here
%   Classification error rate 
% pYpred: p(ypred = 1)
% Assumes ytest in {0,1}
% ytrain: ingnored but kept for consistency with othe loss functions

errRate = sum(ytest ~= (pYpred >= 0.5)) / length(ytest);


end

