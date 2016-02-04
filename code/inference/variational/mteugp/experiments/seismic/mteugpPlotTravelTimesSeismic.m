function mteugpPlotTravelTimesSeismic(x, y, n_layers)
% plot travel times
% x: (n_x x 1)
% y: (n_x x n_layers)
clf;
hold on;
for layer = 1 : n_layers
    plot(x, y(:, layer), 'g', 'linewidth', 3);
end
set(gca,'YDir','reverse');
title('Travel times');
xlabel('Sensor location (m)');
ylabel('Time (s)');


end
 