function [mnlp, errorRate] = mteugpEvaluateResultsUSPSBinary(  )
%MTEUGPEVALUATERESULTSUSPSBINARY Summary of this function goes here
%   Detailed explanation goes here
global SRCDIR;
global TRGFIGDIR;
global SAVEPLOTS;


SRCDIR  = 'results'; % where the results are
%SRCDIR  = 'results/cluster-20160201'; % where the results are
TRGFIGDIR = 'tex/icml2016/figures'; % Where the save the plots
SAVEPLOTS = 1;
 
%draw_bars_flat();
[mnlp, errorRate]  = draw_bars_group();
%[mnlp, errorRate]  = draw_bars_separate();

end


function [mnlp, errorRate] = draw_bars_separate()
% This plots EKS, UKS as a funcion of D 
% and a different plot the benchmarks
strDim = {'100', '200', '400'};
strDimLabel   = {'D=200', 'D=400', 'D=800'};
linearMethod = {'Taylor', 'Unscented'}; 
aliasMethod  = {'EKS', 'UKS'};
B = length(linearMethod);
L = length(strDim);

% Gets models' performance
mnlp      = zeros(L, B);
errorRate = zeros(L, B);
for i = 1 : L
    for j = 1 : B   
        perf         = loadSingleResult(strDim{i}, linearMethod{j});
        mnlp(i,j)      = perf.mnlp;
        errorRate(i,j) = perf.errorRate;   
    end
end

barPlotModelOnly(errorRate, aliasMethod, strDimLabel, [0 0.05], 'Error Rate', '')
barPlotModelOnly(mnlp, aliasMethod, strDimLabel, [0 0.25], 'NLP', '')

[baseNames, b_nlp, b_error] =  getBaselines(0); 
barPlotModelOnly(b_error, baseNames, '', [0 0.05], 'Error Rate', 'Baseline')
barPlotModelOnly(b_nlp, baseNames, '', [0 0.25], 'NLP', 'Baseline')

end
 

%%
function barPlotModelOnly(errorMeasure, methodName, strTrueDim, ylimi, strYlabel, strFname)
global TRGFIGDIR;
global SAVEPLOTS;


figure;                    
strYlabel = upper(strYlabel);
FONT_SIZE = 18;
B = size(errorMeasure, 2);
x_model = 1 : B;
bar(x_model, errorMeasure'); colormap(summer);
if (~isempty(strTrueDim))
    legend(strTrueDim, 'Location', 'NorthEast', 'Orientation', 'Vertical', 'Box', 'on');
end
set(gca, 'FontSize', FONT_SIZE);
ylim(ylimi);
ystep = ylimi(2)/5;
set(gca, 'YTick', 0 : ystep : ylimi(2)); 
set(gca, 'Xtick', x_model);
set(gca, 'XTickLabel', methodName);
ylabel(strYlabel);

box off;

fname = [TRGFIGDIR, '/', ...
            'uspsData', strFname ,'-',strYlabel, '.eps'];
%% print('-depsc2', fname);        
fname = strrep(fname, ' ', '-');

if (SAVEPLOTS)
    saveas(gcf, fname, 'epsc' );
    system(['epstopdf ', fname]);
end

end

%% 
function [mnlp, errorRate] = draw_bars_group()
% This plots UKS, EKS as a function of D, as well as EGP, UGP
strDim = {'100', '200', '400'};
strDimLabel   = {'200', '400', '800'};
linearMethod = {'Taylor', 'Unscented'}; 
aliasMethod  = {'EKS', 'UKS'};
B = length(linearMethod);
L = length(strDim);

% Gets models' performance
mnlp      = zeros(L, B);
errorRate = zeros(L, B);
for i = 1 : L
    for j = 1 : B   
        perf         = loadSingleResult(strDim{i}, linearMethod{j});
        mnlp(i,j)      = perf.mnlp;
        errorRate(i,j) = perf.errorRate;   
    end
end

[baseName, b_nlp, b_error] =  getBaselines();
% mnlp      = [mnlp; b_nlp];
% errorRate = [errorRate; b_error]; 
% figure; bar(mnlp);
% bar(errorRate);
singleBarPlot(errorRate, b_error, aliasMethod, baseName, ...
            strDimLabel, [0 0.05], 'Error Rate');

singleBarPlot(mnlp, b_nlp, aliasMethod, baseName, ...
            strDimLabel, [0 0.25], 'NLP');
end


%% 
function singleBarPlot(errorMeasure, baseMeasure, methodName, ...
                        baseName, strTrueDim, ylimi, strYlabel)
global TRGFIGDIR;
global SAVEPLOTS;

figure;                    
strYlabel = upper(strYlabel);
FONT_SIZE = 18;
L = size(errorMeasure,1);
x_model = 1 : L;
x_line  = L + 0.5;
x_base  = L + 1;
x_tick_base = L + 0.8 : 0.5 :  L + length(baseName) - 0.5;
x_all  = [x_model, x_base];
bar(x_model, errorMeasure); colormap(summer);
hold on;
legend(methodName, 'Location', 'NorthWest');
baseError = [NaN*ones(size(errorMeasure)); baseMeasure];
bar(x_all, baseError, 'FaceColor', [0.9 0.9 0.9]);
plot([x_line, x_line], [0, max([errorMeasure(:); baseMeasure(:)])], ...
        'Color',  [0.1 0.1 0.1], 'LineStyle', '--');
set(gca, 'FontSize', FONT_SIZE);

ylim(ylimi);
ystep = ylimi(2)/5;
set(gca, 'YTick', 0 : ystep : ylimi(2)); 
set(gca, 'Xtick', [x_model, x_tick_base]);
set(gca, 'XTickLabel', [strTrueDim, baseName]);

ylabel(strYlabel);

box off;

fname = [TRGFIGDIR, '/', ...
            'uspsData-', strYlabel, '.eps'];
%% print('-depsc2', fname);        
fname = strrep(fname, ' ', '-');

if (SAVEPLOTS)
    saveas(gcf, fname, 'epsc' );
    system(['epstopdf ', fname]);
end

end


%%
function draw_bars_flat()
RESULTS_DIR = 'results/cluster-20160129/uspsData';
strDim       = {'100', '200', '400'};
linearMethod = {'Taylor', 'Unscented'}; 
aliasMethod  = {'EKS', 'UKS'};
B = length(linearMethod);
L = length(strDim);

strBench = cell(1, B*L);
mnlp      = zeros(1, L*B);
errorRate = zeros(1, L*B);
c = 1;
for i = 1 : L
    for j = 1 : B   
        perf         = loadSingleResult(RESULTS_DIR, strDim{i}, linearMethod{j});
        mnlp(c)      = perf.mnlp;
        errorRate(c) = perf.errorRate;   
        val  = 2*str2double(strDim{i}); % Actual dimensionality of feats
        str_label  = num2str(val);
        strBench{c}     = [aliasMethod{j}, '_{', str_label, '}'];
        c = c + 1;
    end
end

[baseNames, b_nlp, b_error] =  getBaselines();
mnlp      = [mnlp, b_nlp];
errorRate = [errorRate, b_error]; 
strBench = [strBench, baseNames];

barPlotFlat( strBench, mnlp, 'NLP', 0.25);
barPPlotFlat( strBench, errorRate, 'Error rate', 0.05);
end


%% 
function [baseNames, b_nlp, b_error] =  getBaselines(boolGPOnly)
if (nargin == 0)
    boolGPOnly = 1;
end

baseNames = { ...
    'EGP', ...    
    'UGP' ...
     'LAP', ... % Laplace
     'EP', ... % 
     'VB', ...
     'SVM', ... % using RBF
     'LR'... % Logistic Regression
    }; 
b_nlp = [   
            0.08051, ...
            0.07290 ...
             0.11528, ... 
             0.07522, ...
             0.10891, ...
             0.08055, ...
             0.11995, ...
        ];
b_error = [ 
            2.1992, ...        
            1.9405 ...
             2.9754, ...
             2.4580, ...
             3.3635, ...
             2.3286, ...
             3.6223, ...
           ]/100;
       
if (boolGPOnly)
    baseNames = baseNames(1:2);
    b_nlp     = b_nlp(1:2);
    b_error   = b_error(1:2);  
end

end


%%
function perf = loadSingleResult(strDim, linearMethod)
% load data
global SRCDIR;

data = mteugpLoadDataUSPS('uspsData', 0);
 
fname = [SRCDIR, '/', 'uspsData', '/D', strDim, '/', linearMethod, '/', 'uspsData.mat'];
load(fname, 'model', 'pred'); % model, pred
perf = mteugpGetPerformanceBinaryClass(data.ytest, pred);

end

function barPlotFlat(strMethod, val, strYlabel, ylimi)
FONT_SIZE = 18;
strYlabel = upper(strYlabel);
figure; 
bar(val);
set(gca, 'FontSize', FONT_SIZE);
ylim([0, ylimi]);
%set(gca, 'YTick', 0 : 0.01 : 0.05); 
set(gca, 'XTickLabel', strMethod);
ylabel(strYlabel);

box off;

fname = ['tex/icml2016/figures/', ...
            'uspsData-', strYlabel, '.eps'];
%% print('-depsc2', fname);        

fname = strrep(fname, ' ', '-');
saveas(gcf, fname, 'epsc' );
system(['epstopdf ', fname]);
%
%export_fig(fname);
end


