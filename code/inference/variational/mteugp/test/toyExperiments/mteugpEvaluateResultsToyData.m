function mteugpEvaluateResultsToyData()
try % delete file with unexectuted runs
    system('rm runs-left.txt'); 
catch ME
end

% Exports table for D=100
% evaluateResultsToyData(100, 1);

evaluateResultsAllD();


end

function evaluateResultsAllD()
close all;
boolExport = 0; % export results to latex Table?
linearMethod = {'EKS', 'UKS', 'GP'};
benchmark    = upper({'linear', 'poly3', 'exp', 'sin', 'tanh'});
% strDim       = {'10', '20', '50', '100'};
strDim       = {'20', '50', '100'};
v_d          = cellfun(@str2double, strDim);
L = length(v_d);
modelStat = cell(1,L);
for j = 1 : L
    D = v_d(j);
    [basePerf, modelPerf, baseStat{j}, modelStat{j}] = evaluateResultsToyData(D, boolExport);
end

baseValue = [-1.8 -2];
for idxMethod = 1 : 2
    strMethod = linearMethod{idxMethod};
    % SMSE (f*)
    [meanVal, stdVal] = getMatrixForBarPlot(modelStat, 'smseF', idxMethod);
    drawBarPlot(meanVal, stdVal, strDim, benchmark, 'SMSE-f*',strMethod, 0);

    % NLPD (f*)
    [meanVal, stdVal] = getMatrixForBarPlot(modelStat, 'nlpdF', idxMethod);
    drawBarPlot(meanVal, stdVal, strDim, benchmark, 'NLPD-f*', strMethod, baseValue(idxMethod) );

    % SMSE (g*) 
    [meanVal, stdVal] = getMatrixForBarPlot(modelStat, 'smseG', idxMethod);
    drawBarPlot(meanVal, stdVal, strDim, benchmark, 'SMSE-g*', strMethod, 0);

end


end



function drawBarPlot(meanVal, stdVal, strDim, benchmark, strYlabel, strMethod, baseValue)
FONT_SIZE = 18;
BAR_WIDTH = 1;

%figure('PaperPositionMode','auto');
figure; 

[hb, he] = mybarweb(meanVal, stdVal, strDim, benchmark, BAR_WIDTH, parula, baseValue);
set(gca, 'FontSize', FONT_SIZE);
h_legend = findobj(gcf,'Tag','legend');
set(h_legend, 'FontSize', FONT_SIZE, 'location', 'NorthWest', 'Orientation', 'vertical');
ylabel(strYlabel);
box off;

% hlt = text(...
%     'Parent', h_legend.DecorationContainer, ...
%     'String', '# Features', ...
%     'HorizontalAlignment', 'center', ...
%     'VerticalAlignment', 'bottom', ...
%     'Position', [0.5, 1.05, 0], ...
%     'Units', 'normalized', ...
%     'FontSize', FONT_SIZE);
% legend boxon;
fname = ['tex/aistats2016/figures/', ...
            'toyData-', strMethod, '-', strrep(strYlabel, '*', 'star'), '.eps'];
% print('-depsc2', fname);        
%
% saveas(gcf, fname, 'epsc' );
%system(['epstopdf ', fname]);
%
export_fig(fname);
end


function [meanVal, stdVal]= getMatrixForBarPlot(cellStat, field, idxMethod)
% cellStat: cell of perf structures
% filed: one of {smseF, nlpdF, smseG}
%  p  = getfield(cellStat{i}, field); is a structure with mean and std
%  fields
% each being a BxM matrix of performance, where B is the # benchmarks and M
%  is the number of methods
D       = length(cellStat); 
perf    = cellStat{1}.(field);
B       = size(perf.mean,1);  
meanVal = zeros(B, D); 
stdVal  = zeros(B, D);

for d = 1 : D
    perf         =  cellStat{d}.(field);
    meanVal(:,d) =  perf.mean(:,idxMethod);    
    stdVal(:,d)  =  perf.std(:,idxMethod);
end


end

function [basePerf, modelPerf, baseStat, modelStat] = evaluateResultsToyData(D, boolExport)

% Evaluates results on toy data
RESULTS_DIR = 'results';
DATASET = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};
linearMethod = {'Taylor', 'Unscented', 'GP'};
nFolds = 5;
basePerf = getPerformance([], DATASET, benchmark, linearMethod, nFolds, D, 'baseline');
modelPerf = getPerformance(RESULTS_DIR, DATASET, benchmark, linearMethod, nFolds, D, 'mteugp' );

baseStat  = getPerfStats(basePerf);
modelStat = getPerfStats(modelPerf);

if (boolExport)
    exportResults(baseStat, modelStat, benchmark, linearMethod);
end

end




% exportResults(base, perf)
function exportResults(baseStat, modelStat, benchmark, linearMethod)
% base: baseline performance
% perf: performance of the model
[B, M] = size(baseStat.smseF.mean); % # benchmarks, # linearization method, 

% Replaces the names of the benchmark
for i = 1 : B
%     benchmark{i} = strrep(benchmark{i}, 'lineardata', '$\mathrm{f}$');
%     benchmark{i} = strrep(benchmark{i}, 'poly3data', '$\mathrm{f^3 + f^2 + f}$');
%     benchmark{i} = strrep(benchmark{i}, 'expdata', '$\mathrm{\exp(f)}$');
%     benchmark{i} = strrep(benchmark{i}, 'sindata', '$\mathrm{\sin(f)}$');
%     benchmark{i} = strrep(benchmark{i}, 'tanhdata', '$\mathrm{\tanh(f)}$');
      benchmark{i} = strrep(benchmark{i}, 'data', '');
end



fname = 'tex/aistats2016/table-toy.tex';
fid = fopen(fname, 'wt');
%fprintf(fid, '\\begin{table*}\n');
%fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{tabular}{c c c c c}\n');
fprintf(fid, 'g(f) & Method & SMSE-f* (std) & NLPD-f* (std) &');
fprintf(fid, 'SMSE-g* (std) \\\\ \n');
fprintf(fid, '\\toprule\n');
for i = 1 : B
    fprintf(fid, '%s ', benchmark{i});
    for j = 1 : M % model
        if (~strcmp(linearMethod{j}, 'GP'))
            strMethod = strrep(linearMethod{j}, 'Taylor', '\eks');
            strMethod = strrep(strMethod, 'Unscented', '\uks');            
            %writeLine(modelStat, ['S-',linearMethod{j}], fid, i, j);
            writeLine(modelStat, strMethod, fid, i, j);
        end
    end
    fprintf(fid, '\n');
    for j = 1 : M % baseline
        if (~strcmp(linearMethod{j}, 'GP') || (strcmp(benchmark{i}, 'lineardata'))  ) 
            writeLine(baseStat, linearMethod{j}, fid, i, j);
        end
    end
    fprintf(fid, '\n');
    
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
%fprintf(fid, '\\end{table*}');
fclose(fid);
end


function writeLine(perfStat, linearMethod, fid, i, j)
linearMethod = strrep(linearMethod, 'GP', '\gp');
linearMethod = strrep(linearMethod, 'Taylor', '\egp');
linearMethod = strrep(linearMethod, 'Unscented', '\ugp');
% SMSE-f* (std)
meanVal = perfStat.smseF.mean(i,j);
stdVal  = perfStat.smseF.std(i,j);        
if ( ~isnan(meanVal) )
    fprintf(fid, '& %s ', linearMethod);
    fprintf(fid, '& %.4f (%.4f) & ', meanVal, stdVal);
else
    fprintf(fid, '& %s & - & ',  linearMethod);
end
% NLPD-f* (std)
meanVal = perfStat.nlpdF.mean(i,j);
stdVal  = perfStat.nlpdF.std(i,j);        
if ( ~isnan(meanVal) )
    fprintf(fid, '%.4f (%.4f) & ',  meanVal, stdVal);
else
    fprintf(fid, ' - & ');
end
% SMSE-g* (std)
meanVal = perfStat.smseG.mean(i,j);
stdVal  = perfStat.smseG.std(i,j);        
if ( ~isnan(meanVal) )
     fprintf(fid, '%.4f (%.4f) ',  meanVal, stdVal);
else
     fprintf(fid, ' -  ');
end
fprintf(fid, '\\\\ \n');

end
       
% perfStat = getPerfStats(perf)
function perfStat = getPerfStats(perf)
perfStat.smseF.mean = mean(perf.smseF,3);
perfStat.nlpdF.mean = mean(perf.nlpdF,3);
perfStat.smseG.mean = mean(perf.smseG,3);
%
perfStat.smseF.std = std(perf.smseF,0,3);
perfStat.nlpdF.std = std(perf.nlpdF,0,3);
perfStat.smseG.std = std(perf.smseG,0,3);

end


% base = getBaseline(DATASET, benchmark, linearMethod, nFolds)
function perf = getPerformance(RESULTS_DIR, DATASET, benchmark, linearMethod, nFolds, D, model )
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
fid = fopen('runs-left.txt', 'at');
for i = 1 : B
    for j = 1 : M
        for k = 1 : nFolds 
            [smseF, nlpdF, smseG] = perfFunc(RESULTS_DIR, DATASET, benchmark{i}, linearMethod{j}, k, D);
            
            % prints unexecuted runs
            if (isnan(smseF) && (strcmp(model,'mteugp')) && (~strcmp(linearMethod{j}, 'GP')))
                fprintf(fid, '%d %d %d %d 0\n', i, j, k, D);
            end
            perf.smseF(i,j,k) = smseF;
            perf.nlpdF(i,j,k) = nlpdF;
            perf.smseG(i,j,k) = smseG;
        end
    end
end
fclose(fid);

end


function  [smseF, nlpdF, smseG] = getModelSingle(RESULTS_DIR, DATASET, benchmark, linearMethod, fold, D )
smseF = NaN;
nlpdF = NaN;
smseG = NaN;

% no GP method for model 
if (strcmp(linearMethod, 'GP'))
    return;
end

RESULTS_DIR = [RESULTS_DIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
fname = [RESULTS_DIR, '/', benchmark, '_k', num2str(fold), '.mat'];
try
    load(fname, 'pred');
catch ME
    fprintf('Warning: file %s could not be loaded\n', fname);
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
function [smseF, nlpdF, smseG] = getBaselineSingle(RESULTS_DIR, DATASET, benchmark, linearMethod, fold, D )
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






