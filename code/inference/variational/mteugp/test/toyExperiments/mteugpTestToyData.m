function   mteugpTestToyData( D  )
%MTEUGPTESTTOYDATA Tests MTEUGP on a series of toy data examples 
%   Data generated and evaluated using the model of Steinberg and Bonilla
%   (NIPS, 2014)
% D: Dimensionality of feature space

DATASET = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};
%benchmark = {'lineardata'};

for i = 1 : length(benchmark)
  evaluateBenchmark(DATASET, benchmark{i}, D);
end

end

% evaluateBenchmark(DATASET, benchmark)
function evaluateBenchmark(DATASET, benchmark, D)
% Just avoids Matlab sending me stupid warning
linearMethod = {'Taylor', 'Unscented'};
for i = 1 : length(linearMethod)
    runAllFolds(DATASET, benchmark, linearMethod{i}, D);
end


end


%% runAllFolds() 
function runAllFolds(DATASET, benchmark, linearMethod, D)
RESULTS_DIR = ['results/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
system(['mkdir -p ', RESULTS_DIR]);
nFolds = 5;

for k = 1 : nFolds
    data  =  mteugpReadSingleFoldToy(DATASET, benchmark, k);
    
    [model, pred, perf] = runSingleFold(data, benchmark, linearMethod, D);    
    fname = [RESULTS_DIR, '/', benchmark, '_k', num2str(k), '.mat'];
    save(fname, 'model', 'pred', 'perf');
    showProgress(benchmark, k, linearMethod, perf);
end

end


%% showProgress(benchmark, linearMethod, perf)
function showProgress(benchmark, fold, linearMethod, perf)
fprintf('MODEL: %s(%d): %s --> SMSE(f*)=%.4f, NLPD(f*)=%4f, SMS(g*)=%.4f \n', benchmark, fold, linearMethod, perf.smseFstar, perf.nlpdFstar, perf.smseGstar);
end


%%  [model, pred, perf] = runSingleFold(data, benchmark, linearMethod, D )
function [model, pred, perf] = runSingleFold(data, benchmark, linearMethod, D )

model             = mteugpGetConfigToy( data.xtrain, data.ytrain, benchmark, linearMethod, D );
model             = mteugpLearn( model );

[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, data.xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         

% Model performance
perf = mteugpGetPerformanceToy(pred, data.ftest, data.gtest);


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