function mteugpPlotPredictionsSeismic(Gpred, Y, n_layers)
% plot forward predictions vs real observations
figure;

layercolor = 'rbgm';
hold on;
for layer = 1 : n_layers
    scatter(Y(:, layer), Gpred(:, layer), 10, layercolor(layer));
end
title('Real observations vs predicted observations')
ylabel('y')
xlabel('ysim')
end
