clear all; clc; close all;

benchmark = 'poly3data';
fold = 1;

 data  =  mteugpReadSingleFoldToy('toyData', benchmark, fold );
 
% bad results
fname = ['results/toyData/D100/Unscented/', benchmark, '_k', num2str(fold), '.mat'];
load(fname, 'model', 'pred', 'perf' );
model1 = model;
pred1  =  pred;
perf1  = perf;
clear model pred perf;

% good results  
fname = ['results/tmp/toyData/D100/Unscented/', benchmark, '_k', num2str(fold), '.mat'];
load(fname, 'model', 'pred', 'perf' );
model2 = model;
pred2  =  pred;
perf2  = perf;
clear model pred perf;

subplot(2,1,1);
mteugpPlotPredictions1D( data ,model1, pred1 ); title('MODEL1');
subplot(2,1,2);
mteugpPlotPredictions1D( data ,model2, pred2 ); title('MODEL2');


figure, subplot(1,2,1);
semilogy(model1.nelbo, 'b'); hold on;
semilogy(model2.nelbo, 'r'); 
ylabel('Training Nelbo');
legend({'M1', 'M2'}); set(gca, 'FontSize', 18);
%
subplot(1,2,2);
bar([perf1.nlpdFstar, perf2.nlpdFstar]); 
set(gca, 'xticklabel',{'M1', 'M2'});
set(gca, 'FontSize', 18);
ylabel('Test NLPD');

