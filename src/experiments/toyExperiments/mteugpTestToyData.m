    function   mteugpTestToyData( idxBench, idxMethod, idxFold, ...
                            D, writeLog  )
%MTEUGPTESTTOYDATA Tests MTEUGP on a series of toy data examples 
%   Data generated and evaluated using the model of Steinberg and Bonilla
%   (NIPS, 2014)
% idxBench=: 1 : 5
% idxMethod: 1 : 2
% idxFold: 1:5
% D: Dimensionality of feature space
if ( ischar(idxBench) )
    [idxBench, idxMethod, idxFold, D, writeLog] = ...
                        parseInput(idxBench, idxMethod, idxFold, D, writeLog);
end 
                
RESULTS_DIR = 'tmp2/results';  % 


DATASET     = 'toyData';
benchmark   = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};

for i = idxBench
    evaluateBenchmark(RESULTS_DIR, DATASET, benchmark{i}, idxMethod, idxFold, D, writeLog);
end


end



%% 
function [idxBench, idxMethod, idxFold, D, writeLog] = ...
                parseInput(str_idxBench, str_idxMethod, str_idxFold, str_D, str_writeLog)

idxBench  = str2num(str_idxBench);
idxMethod = str2num(str_idxMethod);
idxFold   = str2num(str_idxFold);
D         = str2num(str_D);
writeLog  = str2num(str_writeLog);

end


%% evaluateBenchmark(DATASET, benchmark)
function evaluateBenchmark(RESULTS_DIR, DATASET, benchmark, idxMethod, idxFold, D, writeLog)
% Just avoids Matlab sending me stupid warning
linearMethod = {'Taylor', 'Unscented'};
for i = idxMethod                    
    runAllFolds(RESULTS_DIR, DATASET, benchmark, linearMethod{i}, idxFold, D, writeLog);
end


end


%% runAllFolds() 
function runAllFolds(RESULTS_DIR, DATASET, benchmark, linearMethod, idxFold, D, writeLog)
RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
system(['mkdir -p ', RESULTS_DIR]);

if (writeLog)
    str = datestr(now, 30);
    diary([RESULTS_DIR, '/',str, '.log']);
end

for k = idxFold
    data  =  mteugpReadSingleFoldToy(DATASET, benchmark, k);
    [model, pred, perf] = runSingle(data, benchmark, linearMethod, D);    
    fname = [RESULTS_DIR, '/', benchmark, '_k', num2str(k), '.mat'];
    
    % Saving model, predictions and performance
    save(fname, 'model', 'pred', 'perf');
    showProgress(benchmark, k, linearMethod, perf);
end

diary off;


end


%%  [model, pred, perf] = runSingleFold(data, benchmark, linearMethod, D )
function [model, pred, perf] = runSingle(data, benchmark, linearMethod, D )

model             = mteugpGetConfigToy( data.xtrain, data.ytrain, benchmark, linearMethod, D );
model             = mteugpLearn( model );
%model             = mteugpLearnSimplified( model, data.xtest, data.gtest );
%model             = mteugpLearnAllSimplified( model );
 

[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, data.xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         

% Model performance
perf = mteugpGetPerformanceToy(pred, data.ftest, data.gtest);

end

  

%% showProgress(benchmark, linearMethod, perf)
function showProgress(benchmark, fold, linearMethod, perf)
fprintf('MODEL: %s(%d): %s --> SMSE(f*)=%.4f, NLPD(f*)=%4f, SMS(g*)=%.4f \n', benchmark, fold, linearMethod, perf.smseFstar, perf.nlpdFstar, perf.smseGstar);
end





%  plot_data(x, y, xstar, fstar, gstar )
function plot_data(x, y, xstar, fstar, gstar )
[v, idx] = sort(xstar);
plot(v, fstar(idx), 'r', 'LineWidth',2); hold on;
plot(v, gstar(idx), 'g','LineWidth',2); hold on;
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data
set(gca, 'FontSize', 14);
legend({'fstar', 'ystar', 'ytrain'});
end