function   mteugpTestToyData(  )
%MTEUGPTESTTOYDATA Tests MTEUGP on a series of toy data examples 
%   Data generated and evaluated using the model of Steinberg and Bonilla
%   (NIPS, 2014)
DATADIR = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};
%benchmark = {'lineardata'};

for i = 1 : length(benchmark)
  evaluateBenchmark(DATADIR, benchmark{i});
end

end

% evaluateBenchmark(DATADIR, benchmark)
function evaluateBenchmark(DATADIR, benchmark)
% Just avoids Matlab sending me stupid warning
f = []; train = []; test = [];  x = [];  y = [];
load([DATADIR, '/', benchmark], 'f',  'train', 'test', 'x', 'y');
train = train+1; test = test+1; % shifts indices to Matlab 
nFolds = size(train, 1);

figure;
for k = 1 : nFolds
    [xtrain, ftrain, ytrain, xtest, ftest, ytest] = readSingleFold(x, f, y, train, test,k);

    subplot(2,3,k); 
    plot_data(xtrain, ytrain, xtest, ftest, ytest ); 
    title(benchmark);
  % fname = ['resultsOpper/', benchmark, '_k', num2str(k), '.mat'];
  %  save(fname, 'mufPred', 'sigmafStar', 'yStar', 'pred');
end
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

function plot_data(x, y, xstar, fstar, gstar )
[v, idx] = sort(xstar);
plot(v, fstar(idx), 'r', 'LineWidth',2); hold on;
plot(v, gstar(idx), 'g','LineWidth',2); hold on;
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data
set(gca, 'FontSize', 14);
legend({'fstar', 'ystar', 'ytrain'});
end