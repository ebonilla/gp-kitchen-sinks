function mteugpPlotPredictions1D( data ,model, pred )
%MTEUGPPLOTPREDICTIONS1D Summary of this function goes here
%   Detailed explanation goes here

[xtest, idx] = sort(data.xtest);
mFpred   = pred.mFpred(idx);
vFpred   = pred.vFpred(idx);
gpred   = pred.gpred(idx);
plot_confidence_interval(xtest, mFpred, sqrt(vFpred), [], 1, 'b', [0.7 0.9 0.95]); 
hold on; 
plot(xtest, gpred, 'k--', 'LineWidth', 2); hold on;  
%
%
ftest = data.ftest(idx);
gtest = data.gtest(idx);
plot(xtest, ftest, 'r', 'LineWidth',2); hold on;
plot(xtest, gtest, 'g','LineWidth',2); hold on;
plot(data.xtrain, data.ytrain, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data
set(gca, 'FontSize', 14);





legend({'Model std (f*)', 'Model mean(f*)', 'Model mean(g*)', 'ftrue', 'gtrue', ...
    'ytrain'}, 'Location', 'SouthEast');
title(upper(model.linearMethod));


end



function plot_data(x, y, xstar, fstar, gstar )
[v, idx] = sort(xstar);
plot(v, fstar(idx), 'r', 'LineWidth',2); hold on;
plot(v, gstar(idx), 'g','LineWidth',2); hold on;
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data
set(gca, 'FontSize', 14);
end


