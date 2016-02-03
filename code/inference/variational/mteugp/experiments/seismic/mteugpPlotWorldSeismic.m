function mteugpPlotWorldSeismic(data, depth, vel)
% plot world model -- Depth
% depth (n_x x n_layers)
% vel   [nx x n_layers)

PlotWorldModelAlistair(data.xtrain', depth', vel', data.n_layers, data.d', data.v');

end

%%
function PlotWorldModelAlistair(x, fopt, vopt, n_layers, f, v)
figure;
plot([x(1), x(end)], [0, 0], 'k', 'linewidth', 3);
hold on;
for layer = 1 : n_layers
    plot(x, -fopt(layer, :), 'b', 'linewidth', 3);
    if (~isempty(f))
        plot(x, -f(layer, :), 'r--', 'linewidth', 3);
    end
end
title('Depth of boundaries')
xlabel('Sensor location (m)')
ylabel('Height (m)')
leg = {'Ground', 'Predicted boundaries'};
if ( ~isempty(v) )
    leg{end+1} = 'True Boundaies';
end
legend(leg);
    
    
% plot world model -- Velocity
figure;
hold on;
for layer = 1 : n_layers
    plot(x, vopt(layer, :), 'b', 'linewidth', 3);
    if ( ~isempty(v) )
    plot(x, v(layer, :), 'r--', 'linewidth', 3);
    end
end
title('Velocity of layers')
xlabel('Sensor location (m)')
ylabel('Velocity (m/s)')
leg = {'Predicted velocities'};
if ( ~isempty(v) )
    leg{end+1} = 'True velocities';
end
legend(leg);

end