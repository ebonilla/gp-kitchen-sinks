function mteugpTestMNISTBinary( str_idxMethod, str_D, str_boolSample, str_writeLog )
%mteugpTestMNISTBinary Run MTEUGP on MNIST BInary data
%   Detailed explanation goes here
DATASET       = 'mnistBinaryData';
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


function runSingle(RESULTS_DIR, DATASET, linearMethod, D, boolSample)
RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
fname = [RESULTS_DIR, '/', DATASET, '.mat'];
system(['mkdir -p ', RESULTS_DIR]);
data         = loadDataMNISTBinary(DATASET, boolSample);

% Learning Model
model        = mteugpGetConfigMNISTBinary( data.xtrain, data.ytrain,linearMethod, D );
model.resultsFname =  fname;
model.perfFunc = @mteugpGetPerformanceBinaryClass;
model        = mteugpLearn( model, data.xtest, data.ytest );
save(fname, 'model');

% Predictions
model.resultsFname = fname;
mteugpSavePerformance(inf, model, data.xtest, data.ytest);

end


%
function data = loadDataMNISTBinary(DATASET, boolSample)
x = []; xx = []; y = []; yy = [];
load(['data/', DATASET, '/mnistBinary.mat']);
data.xtrain = x;
data.ytrain = y;
data.xtest   = xx;
data.ytest   = yy;

if (boolSample)
    data = subSampleData(data);
end 
end


% Just for testing
function data = subSampleData(data)
N = 100;
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