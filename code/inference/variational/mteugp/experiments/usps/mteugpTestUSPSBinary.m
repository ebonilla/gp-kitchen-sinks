function  mteugpTestUSPSBinary( str_idxMethod, str_D, str_boolSample, str_writeLog )
%MTEUGPTESTUSPS Run MTEUGP on USPSP data
%   Detailed explanation goes here
DATASET       = 'uspsData';
RESULTS_DIR   = 'results';
linearMethod  = {'Taylor', 'Unscented'};

[idxMethod, D, boolSample, writeLog] = parseInput(str_idxMethod, str_D, str_boolSample, str_writeLog);
if (writeLog)
    str = datestr(now, 30);
    diary([RESULTS_DIR, '/',DATASET, '/', str, '.log']);
end


perf = runSingle(RESULTS_DIR, DATASET, linearMethod{idxMethod}, D, boolSample);
showProgress(linearMethod{idxMethod}, perf);


diary off;


end


function perf = runSingle(RESULTS_DIR, DATASET, linearMethod, D, boolSample)
RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
fname = [RESULTS_DIR, '/', 'uspsData', '.mat'];
system(['mkdir -p ', RESULTS_DIR]);

data         = loadDataUSPS(DATASET, boolSample);
model        = mteugpGetConfigUSPSBinary( data.xtrain, data.ytrain,linearMethod, D );

model.resultsFname =  fname;
model        = mteugpLearn( model );
save(fname, 'model');
[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, data.xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         
perf = mteugpGetPerformanceBinaryClass(data.ytest, pred);
save(fname, 'model', 'pred', 'perf');
end






%% showProgress(benchmark, linearMethod, perf)
function showProgress(linearMethod, perf)
fprintf('USPS: %s: --> NLP=%.4f, ERROR=%.4f \n',linearMethod, perf.mnlp, perf.errorRate );
end


function perf = mteugpGetPerformanceBinaryClass(ytest, pred)
perf.mnlp      = myMNLP( [], ytest, pred.gpred  );
perf.errorRate = myErrorRate([], ytest, pred.gpred );

end

%
function data = loadDataUSPS(DATASET, boolSample)
x = []; xx = []; y = []; yy = [];
load(['data/', DATASET, '/USPS_3_5_data.mat']);

% Change class labels -1 -> 0
y(y == -1)   = 0; 
yy(yy == -1) = 0;
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
N = 50;
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