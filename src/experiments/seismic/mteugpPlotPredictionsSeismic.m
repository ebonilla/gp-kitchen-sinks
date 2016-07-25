function pred_handle = mteugpPlotPredictionsSeismic(Gpred, Y, n_layers)
% plot forward predictions vs real observations
pred_handle = figure;
FONTSIZE = 18;
layercolor = 'rbgm';
hold on;
for layer = 1 : n_layers
    scatter(Y(:, layer), Gpred(:, layer), 10, layercolor(layer));
end
title('Real observations vs predicted observations')
ylabel('y');
xlabel('ysim');

set(gca, 'FontSize', FONTSIZE);

end
