function data  =  mteugpReadSingleFoldToy(DATASET, benchmark, fold )
%MTEUGPREADSINGLEFOLDTOY Summary of this function goes here
%   Detailed explanation goes here

f = []; train = []; test = [];  x = [];  y = [];
load(['data/', DATASET, '/', benchmark], 'f',  'train', 'test', 'x', 'g', 'y');
train = train+1; test = test+1; % shifts indices to Matlab 


% Read single fold of data
data.xtrain = x(train(fold,:))';
data.ftrain = f(train(fold,:))';
data.ytrain = y(train(fold,:))';

data.xtest = x(test(fold,:))';
data.ftest = f(test(fold,:))';
data.gtest = g(test(fold,:))';
    
end


