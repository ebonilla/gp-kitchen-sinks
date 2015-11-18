function  mteugpTestUSPSBinary( str_idxMethod, str_D, str_boolSample, str_writeLog )
%MTEUGPTESTUSPS Run MTEUGP on USPSP data
%   Detailed explanation goes here
DATASET       = 'uspsData';
RESULTS_DIR   = 'tmp2/results';
linearMethod  = {'Taylor', 'Unscented'};

[idxMethod, D, boolSample, writeLog] = parseInput(str_idxMethod, str_D, str_boolSample, str_writeLog);

runSingle(RESULTS_DIR, DATASET, linearMethod{idxMethod}, D, boolSample, writeLog);




end


function runSingle(RESULTS_DIR, DATASET, linearMethod, D, boolSample, writeLog)
RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
system(['mkdir -p ', RESULTS_DIR]);

if (writeLog)
    str = datestr(now, 30);
    diary([RESULTS_DIR,  '/', str, '.log']);
end
fname = [RESULTS_DIR, '/', 'uspsData', '.mat'];
data         = mteugpLoadDataUSPS(DATASET, boolSample);

% Learning Model
model        = mteugpGetConfigUSPSBinary( data.xtrain, data.ytrain,linearMethod, D );
model.resultsFname =  fname;
model.perfFunc = @mteugpGetPerformanceBinaryClass;

%model        = mteugpLearn( model, data.xtest, data.ytest );
model        = mteugpLearnSimplified( model, data.xtest, data.ytest );

save(fname, 'model');

% Predictions
model.resultsFname = fname;
mteugpSavePerformance(inf, model, data.xtest, data.ytest);

diary off;

end






%% showProgress(benchmark, linearMethod, perf)
function showProgress(linearMethod, perf)
fprintf('USPS: %s: --> NLP=%.4f, ERROR=%.4f \n',linearMethod, perf.mnlp, perf.errorRate );
end





%
function [idxMethod, D, boolSample, writeLog] = parseInput(str_idxMethod, str_D, str_boolSample, str_writeLog);


idxMethod = str2num(str_idxMethod);
D         = str2num(str_D);
boolSample  = str2num(str_boolSample);
writeLog  = str2num(str_writeLog);

end