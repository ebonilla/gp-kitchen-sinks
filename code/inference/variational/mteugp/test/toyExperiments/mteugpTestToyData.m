function   mteugpTestToyData(  )
%MTEUGPTESTTOYDATA Tests MTEUGP on a series of toy data examples 
%   Data generated and evaluated using the model of Steinberg and Bonilla
%   (NIPS, 2014)
DATASET = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};
%benchmark = {'lineardata'};

for i = 1 : 1 %length(benchmark)
  evaluateBenchmark(DATASET, benchmark{i});
end

end

% evaluateBenchmark(DATADIR, benchmark)
function evaluateBenchmark(DATADIR, benchmark)
% Just avoids Matlab sending me stupid warning
linearMethod = {'Taylor', 'Unscented'};
for i = 1 : 1%length(linearMethod)
    runAllFolds(DATADIR, benchmark, linearMethod{i});
end


end


%% runAllFolds() 
function runAllFolds(DATADIR, benchmark, linearMethod)
RESULTS_DIR = ['results/', DATADIR, '/', linearMethod];
system(['mkdir -p ', RESULTS_DIR]);
    
f = []; train = []; test = [];  x = [];  y = [];
load(['data/', DATADIR, '/', benchmark], 'f',  'train', 'test', 'x', 'y');
train = train+1; test = test+1; % shifts indices to Matlab 
nFolds = size(train, 1);


%figure;
for k = 1 : 1 %nFolds
    [xtrain, ftrain, ytrain, xtest, ftest, ytest] = readSingleFold(x, f, y, train, test,k);
    

    %subplot(2,3,k); 
    %plot_data(xtrain, ytrain, xtest, ftest, ytest ); 
    %title(benchmark);

    [model, pred, perf] = runSingleFold(xtrain, ytrain, xtest, ftest, benchmark, linearMethod );    
    fname = [RESULTS_DIR, '/', benchmark, '_k', num2str(k), '.mat'];
    save(fname, 'model', 'pred', 'perf');
    showProgress(benchmark, linearMethod, perf);
end

end


%% showProgress(benchmark, linearMethod, perf)
function showProgress(benchmark, linearMethod, perf)
fprintf('%s: %s --> SMSE=%.4f, NLPD=%4f \n', benchmark, linearMethod, perf.smseFstar, perf.nlpdFstar);
end


%% [model, mFpred, vFpred, gpred] = runSingleFold(xtrain, ytrain, xtest, benchmark, linearMethod )
function [model, pred, perf] = runSingleFold(xtrain, ytrain, xtest, ftest, benchmark, linearMethod )

model             = mteugpGetConfigToy( xtrain, ytrain, benchmark, linearMethod );
model             = mteugpLearn( model );

[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         

perf.smseFstar  = mySMSE([], ftest, pred.mFpred );
perf.nlpdFstar  = myMLL( [], ftest,  pred.mFpred , pred.vFpred );

end




% Read single fold of data
function [xtrain, ftrain, ytrain, xtest, ftest, ytest] = ...
               readSingleFold(x, f, y, train, test, k)
    xtrain = x(train(k,:))';
    ftrain = f(train(k,:))';
    ytrain = y(train(k,:))';

    xtest = x(test(k,:))';
    ftest = f(test(k,:))';
    ytest = y(test(k,:))';
    
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