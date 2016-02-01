function [mnlp, errorRate] = mteugpEvaluateResultsMNISTBinary(  )
%MTEUGPEVALUATERESULTSUSPSBINARY Summary of this function goes here
%   Detailed explanation goes here
global SRCDIR;      % where the predictions are stored
global TRGFIGDIR;   % Where the figures are saved
global TRGTEXDIR; % where the latex table will be stored
SRCDIR = 'results/cluster-20160201'; 
TRGFIGDIR = 'tex/icml2016/figures';
TRGTEXDIR = 'tex/icml2016';
dataName = 'mnistBinaryData';
 
aliasMethod   = {'EKS', 'UKS'};
linearMethod  = {'Taylor', 'Unscented'}; 
strDim        = {'500', '1000'};
strDimLabel   = {'D=1000', 'D=2000'};


B = length(linearMethod);
L = length(strDim);

mnlp      = zeros(L,B);
errorRate = zeros(L,B);
for i = 1 : L
    for j = 1 : B
        perf = loadSingleResult(dataName, strDim{i}, linearMethod{j});
        mnlp(i,j) = perf.mnlp;
        errorRate(i,j) = perf.errorRate;        
    end
end
end 
 


function perf = loadSingleResult(dataName, strDim, linearMethod)
% load data
global SRCDIR;      % where the predictions are stored

data = mteugpLoadDataMNISTBinary(dataName, 0);
fname = [SRCDIR, '/', dataName, '/D', strDim, '/', linearMethod, '/', dataName, '.mat'];
load(fname, 'model', 'pred'); % model, pred
perf = mteugpGetPerformanceBinaryClass(data.ytest, pred);

end




 