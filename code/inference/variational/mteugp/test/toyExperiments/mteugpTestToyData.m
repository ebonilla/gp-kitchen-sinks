function   mteugpTestToyData( D  )
%MTEUGPTESTTOYDATA Tests MTEUGP on a series of toy data examples 
%   Data generated and evaluated using the model of Steinberg and Bonilla
%   (NIPS, 2014)
% D: Dimensionality of feature space

DATASET = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};
%benchmark = {'lineardata'};

for i = 1 : 1 %length(benchmark)
  evaluateBenchmark(DATASET, benchmark{i}, D);
end

end

% evaluateBenchmark(DATADIR, benchmark)
function evaluateBenchmark(DATADIR, benchmark, D)
% Just avoids Matlab sending me stupid warning
linearMethod = {'Taylor', 'Unscented'};
for i = 1 : 1%length(linearMethod)
    runAllFolds(DATADIR, benchmark, linearMethod{i}, D);
end


end


%% runAllFolds() 
function runAllFolds(DATADIR, benchmark, linearMethod, D)

% loads baseline results
fbase = ['data/', DATADIR, '/', 'results', benchmark, '_res.mat'];
switch linearMethod,
    case 'Taylor',
        load(fbase, 'Ey_t', 'Em_t', 'Vm_t');
        Ey   = Ey_t;
        Em   = Em_t;
        Vm   = Vm_t;
    case 'Unscented'
        load(fbase, 'Ey_s', 'Em_s', 'Vm_s');
        Ey   = Ey_s;
        Em   = Em_s;
        Vm   = Vm_s;
end

RESULTS_DIR = ['results/', DATADIR, '/', 'D', num2str(D), '/', linearMethod];
system(['mkdir -p ', RESULTS_DIR]);
    
f = []; train = []; test = [];  x = [];  y = [];
load(['data/', DATADIR, '/', benchmark], 'f',  'train', 'test', 'x', 'g', 'y');
train = train+1; test = test+1; % shifts indices to Matlab 
nFolds = size(train, 1);


%figure;
for k = 1 : 1 %nFolds
    [xtrain, ftrain, ytrain, xtest, ftest, gtest] = readSingleFold(x, f, g, y, train, test, k);
    

    %subplot(2,3,k); 
    %plot_data(xtrain, ytrain, xtest, ftest, ytest ); 
    %title(benchmark);
    base.mFpred = Em(k,:)'; 
    base.vFpred = Vm(k,:)'; 
    base.gpred  = Ey(k,:)';
    
    [model, pred, perf, perfBase] = runSingleFold(xtrain, ytrain, xtest, ftest, gtest, benchmark, linearMethod, D, base );    
    fname = [RESULTS_DIR, '/', benchmark, '_k', num2str(k), '.mat'];
    save(fname, 'model', 'pred', 'perf', 'perfBase');
    showProgress(benchmark, k, linearMethod, perf, perfBase);
end

end


%% showProgress(benchmark, linearMethod, perf)
function showProgress(benchmark, fold, linearMethod, perf, perfBase)
fprintf('MODEL: %s(%d): %s --> SMSE(f*)=%.4f, NLPD(f*)=%4f, SMS(g*)=%.4f \n', benchmark, fold, linearMethod, perf.smseFstar, perf.nlpdFstar, perf.smseGstar);
fprintf('BASELINE: %s(%d): %s --> SMSE(f*)=%.4f, NLPD(f*)=%4f, SMS(g*)=%.4f \n', benchmark, fold, linearMethod, perfBase.smseFstar, perfBase.nlpdFstar, perfBase.smseGstar);

end


%% [model, mFpred, vFpred, gpred] = runSingleFold(xtrain, ytrain, xtest, benchmark, linearMethod )
function [model, pred, perf, perfBase] = runSingleFold(xtrain, ytrain, xtest, ftest, gtest, benchmark, linearMethod, D, base )

model             = mteugpGetConfigToy( xtrain, ytrain, benchmark, linearMethod, D );
model             = mteugpLearn( model );

[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         

% Model performance
perf = getPerformance(pred, ftest, gtest);

% Performance of Steiberg and Bonilla (2014)'s 
perfBase = getPerformance(base, ftest, gtest);



end


%  getPerformance(pred, ftest, gtest)
function perf = getPerformance(pred, ftest, gtest)
perf.smseFstar  = mySMSE([], ftest, pred.mFpred );
perf.nlpdFstar  = myMLL( [], ftest,  pred.mFpred , pred.vFpred );
perf.smseGstar  = mySMSE([], gtest, pred.gpred );
end



% Read single fold of data
function [xtrain, ftrain, ytrain, xtest, ftest, gtest] = ...
               readSingleFold(x, f, g, y, train, test, k)
    xtrain = x(train(k,:))';
    ftrain = f(train(k,:))';
    ytrain = y(train(k,:))';

    xtest = x(test(k,:))';
    ftest = f(test(k,:))';
    gtest = g(test(k,:))';
    
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