function errRate  = myErrorRateMulti( ytrain, ytest, pYpred )
%MYERRORRATE Summary of this function goes here
%   Classification error rate 
% pYpred(j) = P(y = class_j), j = 1 ... C
% Assumes ytest(j) in {0,1}
% ytrain: ingnored but kept for consistency with othe loss functions
% [N C] size(ytest) = size(pYpred)

[~, cpred] = max(pYpred, [], 2);
[~, ctest] = max(ytest, [], 2);

errRate = sum(ctest ~= cpred) / length(ctest);


end

