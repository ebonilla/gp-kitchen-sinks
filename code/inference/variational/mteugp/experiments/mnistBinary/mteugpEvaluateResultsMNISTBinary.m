function [mnlp, errorRate] = mteugpEvaluateResultsMNISTBinary(  )
%MTEUGPEVALUATERESULTSUSPSBINARY Summary of this function goes here
%   Detailed explanation goes here
dataName = 'mnistBinaryData';
RESULTS_DIR = 'results/cluster-20160129';
strDim       = {'500', '1000'};
linearMethod = {'Taylor', 'Unscented'}; 
aliasMethod  = {'EKS', 'UKS'};
B = length(linearMethod);
L = length(strDim);

mnlp      = zeros(L,B);
errorRate = zeros(L,B);
for i = 1 : L
    for j = 1 : B
        perf = loadSingleResult(RESULTS_DIR, dataName, strDim{i}, linearMethod{j});
        mnlp(i,j) = perf.mnlp;
        errorRate(i,j) = perf.errorRate;        
    end
end
end 
 


function perf = loadSingleResult(RESULTS_DIR, dataName, strDim, linearMethod)
% load data
RESULTS_DIR = [RESULTS_DIR, '/', dataName];

data = mteugpLoadDataMNISTBinary(dataName, 0);
fname = [RESULTS_DIR, '/D', strDim, '/', linearMethod, '/', dataName];
load(fname, 'model', 'pred'); % model, pred
perf = mteugpGetPerformanceBinaryClass(data.ytest, pred);

end




 