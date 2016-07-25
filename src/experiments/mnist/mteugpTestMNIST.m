function  mteugpTestMNIST(idxMethod,  D, boolSample, writeLog)
%mteugpTestMNIST Run MTEUGP on MNIST data
%   Detailed explanation goes here
DATASET       = 'mnistData';
RESULTS_DIR   = 'results';
linearMethod  = {'Taylor', 'Unscented'};

if (ischar(idxMethod))
    [idxMethod, D, boolSample, writeLog] = parseInput(idxMethod,  D, boolSample, writeLog);
end

runSingle(RESULTS_DIR, DATASET, linearMethod{idxMethod}, D, boolSample, writeLog);


end
 

function runSingle(RESULTS_DIR, DATASET, linearMethod, D, boolSample, writeLog)
RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
system(['mkdir -p ', RESULTS_DIR]);

if (writeLog)
    str = datestr(now, 30);
    diary([RESULTS_DIR,  '/', str, '.log']);
end
fname = [RESULTS_DIR, '/', DATASET, '.mat'];
data           = mteugpLoadDataMNIST(DATASET, boolSample);

% Learning Model
model              = mteugpGetConfigMNIST( data.xtrain, data.ytrain,linearMethod, D );
model.resultsFname =  fname;
model              = mteugpLearn( model, data.xtest, data.ytest );
save(fname, 'model');

% Predictions
model.resultsFname = fname;
mteugpSavePerformance(inf, model, data.xtest, data.ytest);

diary off;

end



%


%
function [idxMethod, D, boolSample, writeLog] = parseInput(str_idxMethod, str_D, str_boolSample, str_writeLog);


idxMethod = str2num(str_idxMethod);
D         = str2num(str_D);
boolSample  = str2num(str_boolSample);
writeLog  = str2num(str_writeLog);

end