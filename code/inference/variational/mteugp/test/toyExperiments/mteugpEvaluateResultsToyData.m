function [basePerf, modelPerf] = mteugpEvaluateResultsToyData()

% Evaluates results on toy data
DATASET = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};
linearMethod = {'Taylor', 'Unscented', 'GP'};
nFolds = 5;
D      = 100;

basePerf = getPerformance(DATASET, benchmark, linearMethod, nFolds, D, 'baseline');
modelPerf = getPerformance(DATASET, benchmark, linearMethod, nFolds, D, 'mteugp' );

baseStat  = getPerfStats(basePerf);
modelStat = getPerfStats(modelPerf);
exportResults(baseStat, modelStat, benchmark, linearMethod);

end




% exportResults(base, perf)
function exportResults(baseStat, modelStat, benchmark, linearMethod)
% base: baseline performance
% perf: performance of the model
[B, M] = size(baseStat.smseF{1}); % $ benchmarks, # linearization method, # folds
fname = 'table-toy.tex';
fid = fopen(fname, 'wt');
fprintf(fid, '\\begin{tabular}{c c c c c}\n');
fprintf(fid, 'Benchmark & Algorithm & SMSE-f* (std) & NLPD-f* (std) &');
fprintf(fid, 'SMSE-g* (std) \\\\ \n');

for i = 1 : B
        fprintf(fid, '%s ', benchmark{i});
    for j = 1 : M
        writeLine(baseStat, linearMethod, fid, i, j);
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\\end{tabular}');
fclose(fid);
end


function writeLine(perfStat, linearMethod, fid, i, j)
% SMSE-f* (std)
meanVal = perfStat.smseF{1}(i,j);
stdVal  = perfStat.smseF{2}(i,j);        
if ( ~isnan(meanVal) )
    fprintf(fid, '& %s ', linearMethod{j});
    fprintf(fid, '& %.4f (%.4f) & ', meanVal, stdVal);
else
    fprintf(fid, '& %s & - & ',  linearMethod{j});
end
% NLPD-f* (std)
meanVal = perfStat.nlpdF{1}(i,j);
stdVal  = perfStat.nlpdF{2}(i,j);        
if ( ~isnan(meanVal) )
    fprintf(fid, '%.4f (%.4f) & ',  meanVal, stdVal);
else
    fprintf(fid, ' - & ');
end
% SMSE-g* (std)
meanVal = perfStat.smseG{1}(i,j);
stdVal  = perfStat.smseG{2}(i,j);        
if ( ~isnan(meanVal) )
     fprintf(fid, '%.4f (%.4f) ',  meanVal, stdVal);
else
     fprintf(fid, ' -  ');
end
fprintf(fid, '\\\\ \n');

end
       
% perfStat = getPerfStats(perf)
function perfStat = getPerfStats(perf)
perfStat.smseF{1} = mean(perf.smseF,3);
perfStat.nlpdF{1} = mean(perf.nlpdF,3);
perfStat.smseG{1} = mean(perf.smseG,3);
%
perfStat.smseF{2} = std(perf.smseF,0,3);
perfStat.nlpdF{2} = std(perf.nlpdF,0,3);
perfStat.smseG{2} = std(perf.smseG,0,3);

end


% base = getBaseline(DATASET, benchmark, linearMethod, nFolds)
function perf = getPerformance(DATASET, benchmark, linearMethod, nFolds, D, model )
switch model,
    case 'baseline',
        perfFunc = @getBaselineSingle;
    case 'mteugp'
        perfFunc = @getModelSingle;
end
B = length(benchmark);
M = length(linearMethod);

perf.smseF = zeros(B, M, nFolds);
perf.nlpdF = zeros(B, M, nFolds);
perf.smseG = zeros(B, M, nFolds);
for i = 1 : B
    for j = 1 : M
        for k = 1 : nFolds 
            [smseF, nlpdF, smseG] = perfFunc(DATASET, benchmark{i}, linearMethod{j}, k, D);
            perf.smseF(i,j,k) = smseF;
            perf.nlpdF(i,j,k) = nlpdF;
            perf.smseG(i,j,k) = smseG;
        end
    end
end
end


function  [smseF, nlpdF, smseG] = getModelSingle(DATASET, benchmark, linearMethod, fold, D )
smseF = NaN;
nlpdF = NaN;
smseG = NaN;
RESULTS_DIR = ['results/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
fname = [RESULTS_DIR, '/', benchmark, '_k', num2str(fold), '.mat'];
try
    load(fname, 'pred');
catch ME
    return;
end
data  =  mteugpReadSingleFoldToy(DATASET, benchmark, fold );
perf  = mteugpGetPerformanceToy(pred, data.ftest, data.gtest);
%
smseF = perf.smseFstar;
nlpdF = perf.nlpdFstar;
smseG = perf.smseGstar;

end


% Performance of Steiberg and Bonilla (2014)'s 
function [smseF, nlpdF, smseG] = getBaselineSingle(DATASET, benchmark, linearMethod, fold, D )
smseF = NaN;
nlpdF = NaN;
smseG = NaN;

% loads baseline results
fbase = ['data/', DATASET, '/', 'results', benchmark, '_res.mat'];
switch linearMethod,
    case 'Taylor',
        load(fbase, 'Ey_t', 'Em_t', 'Vm_t');
        Em   = Em_t;
        Vm   = Vm_t;
        Ey   = Ey_t;        
    case 'Unscented'
        load(fbase, 'Ey_s', 'Em_s', 'Vm_s');
        Em   = Em_s;
        Vm   = Vm_s;
        Ey   = Ey_s;        
    case 'GP',
        if (~strcmp(benchmark,'lineardata')) % linear GP only applicable to linear data
            return;
        end
        load(fbase, 'Em_l', 'Vm_l');
        Em   = Em_l;
        Vm   = Vm_l;              
        Ey   = Em_l;

end
base.mFpred = Em(fold,:)'; 
base.vFpred = Vm(fold,:)'; 
base.gpred  = Ey(fold,:)';

data  =  mteugpReadSingleFoldToy(DATASET, benchmark, fold );
perf  = mteugpGetPerformanceToy(base, data.ftest, data.gtest);

smseF = perf.smseFstar;
nlpdF = perf.nlpdFstar;
smseG = perf.smseGstar;
end






