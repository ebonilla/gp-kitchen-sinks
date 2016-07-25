function [mnlp, errorRate] = mteugpEvaluateResultsMNIST(  )
%MTEUGPEVALUATERESULTSUSPSBINARY Summary of this function goes here
%   Detailed explanation goes here
global SRCDIR;      % where the predictions are stored
global TRGFIGDIR;   % Where the figures are saved
global TRGTEXDIR; % where the latex table will be stored
SRCDIR = 'results'; 
TRGFIGDIR = 'tex/icml2016/figures';
TRGTEXDIR = 'tex/icml2016';
dataName = 'mnistData';
 
aliasMethod   = {'EKS', 'UKS'};
linearMethod  = {'Taylor', 'Unscented'}; 
strDim        = {'500', '1000'};
strDimLabel   = {'D=1000', 'D=2000'};


B = length(linearMethod);
L = length(strDim);

mnlp      = zeros(L,B);
errorRate = zeros(L,B);
for j = 1 : B
    fprintf('%s\t', linearMethod{j});
    for i = 1 : L
        perf = loadSingleResult(dataName, strDim{i}, linearMethod{j});
        mnlp(i,j) = perf.mnlp;
        errorRate(i,j) = perf.errorRate;   
         fprintf('%s\t', strDimLabel{i});
        fprintf('|NLP=%.4f|\t', mnlp(i,j) );
        fprintf('|erroRate=%.4f|\t',errorRate(i,j) );
    end
    fprintf('\n');
end
end 
 


function perf = loadSingleResult(dataName, strDim, linearMethod)
% load data
global SRCDIR;      % where the predictions are stored

data = mteugpLoadDataMNIST(dataName, 0);
fname = [SRCDIR, '/', dataName, '/D', strDim, '/', linearMethod, '/', dataName, '.mat'];
load(fname, 'model', 'pred'); % model, pred
perf = mteugpGetPerformanceMultiClass(data.ytest, pred);

end


 

 