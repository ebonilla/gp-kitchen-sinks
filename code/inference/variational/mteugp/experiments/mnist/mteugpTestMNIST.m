function  mteugpTestMNIST( str_idxMethod, str_D, str_boolSample, str_writeLog )
%mteugpTestMNIST Run MTEUGP on MNIST data
%   Detailed explanation goes here
DATASET       = 'mnistData';
RESULTS_DIR   = 'results';
linearMethod  = {'Taylor', 'Unscented'};

[idxMethod, D, boolSample, writeLog] = parseInput(str_idxMethod, str_D, str_boolSample, str_writeLog);
if (writeLog)
    str = datestr(now, 30);
    diary([RESULTS_DIR, '/',DATASET, '/', str, '.log']);
end


runSingle(RESULTS_DIR, DATASET, linearMethod{idxMethod}, D, boolSample);


diary off;


end


function perf = runSingle(RESULTS_DIR, DATASET, linearMethod, D, boolSample)
RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
fname = [RESULTS_DIR, '/', DATASET, '.mat'];
system(['mkdir -p ', RESULTS_DIR]);
data           = loadDataMNIST(DATASET, boolSample);

% Learning Model
model              = mteugpGetConfigMNIST( data.xtrain, data.ytrain,linearMethod, D );
model.resultsFname =  fname;
model.perfFunc = @mteugpGetPerformanceMultiClass;
model              = mteugpLearn( model, data.xtest, data.ytest );
save(fname, 'model');

% Predictions
[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, data.xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         

% Performance
perf = mteugpGetPerformanceMultiClass(data.ytest, pred);
mteugpShowPerformance(length(model.nelbo), model.resultsFname, model.linearMethod, perf);


save(fname, 'model', 'pred', 'perf');
end



%
function dd  = loadDataMNIST(DATASET, boolSample)
data = [];
load(['data/', DATASET, '/mnist_data.mat']);

dd.xtrain = data{1}.train_X;
dd.ytrain = data{1}.train_Y;
dd.xtest  = data{1}.test_X;
dd.ytest  = data{1}.test_Y;

clear data;

if (boolSample)
    dd = subSampleData(dd);
end 
end


% Just for testing
function data = subSampleData(data)
N = 20;
v = randperm(size(data.xtrain,1));
idx = v(1:N);
data.xtrain = data.xtrain(idx,:);
data.ytrain = data.ytrain(idx,:);


end

%
function [idxMethod, D, boolSample, writeLog] = parseInput(str_idxMethod, str_D, str_boolSample, str_writeLog);


idxMethod = str2num(str_idxMethod);
D         = str2num(str_D);
boolSample  = str2num(str_boolSample);
writeLog  = str2num(str_writeLog);

end