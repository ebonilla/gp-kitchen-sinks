function [mnlp, errorRate] = mteugpEvaluateResultsUSPSBinary(  )
%MTEUGPEVALUATERESULTSUSPSBINARY Summary of this function goes here
%   Detailed explanation goes here
RESULTS_DIR = 'results/uspsData';
strDim       = {'100', '200', '400'};
linearMethod = {'Taylor', 'Unscented'}; 
aliasMethod  = {'EKS', 'UKS'};
B = length(linearMethod);
L = length(strDim);

mnlp      = zeros(L,B);
errorRate = zeros(L,B);
for i = 1 : L
    for j = 1 : B
        perf = loadSingleResult(RESULTS_DIR, strDim{i}, linearMethod{j});
        mnlp(i,j) = perf.mnlp;
        errorRate(i,j) = perf.errorRate;        
    end
end
end



function perf = loadSingleResult(RESULTS_DIR, strDim, linearMethod)
% load data
data = mteugpLoadDataUSPS('uspsData', 0);

fname = [RESULTS_DIR, '/D', strDim, '/', linearMethod, '/', 'uspsData.mat'];
load(fname, 'model', 'pred'); % model, pred
perf = mteugpGetPerformanceBinaryClass(data.ytest, pred);

end



