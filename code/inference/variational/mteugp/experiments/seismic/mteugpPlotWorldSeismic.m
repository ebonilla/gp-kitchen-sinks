function [d_handle, v_handle] = mteugpPlotWorldSeismic(data, depth, vel, std_depth, std_vel, mcmc)
% plot world model -- Depth
% depth (n_x x n_layers)
% vel   [nx x n_layers)

[d_handle, v_handle] = PlotWorldModelAlistair(data.xtrain', depth', vel', std_depth', std_vel', ...
                    data.n_layers, data.d', data.v', mcmc);

end

%%
function [d_handle, v_handle] = PlotWorldModelAlistair(x, fopt, vopt, std_f, std_v, n_layers, f, v, mcmc)
FONTSIZE = 24;

d_handle = figure;
%plot([x(1), x(end)], [0, 0], 'k', 'linewidth', 1);
hold on;
for layer = 1 : n_layers
    if (isempty(std_f))
        plot(x, -fopt(layer, :), 'b', 'linewidth', 3);
    else
        mu = -fopt(layer, :);
        se = std_f(layer,:); 
        plotSingleConfidenceIntrerval(x, mu, se, - mcmc.meanH(layer, :), mcmc.stdH(layer,:));
    end    
    if (~isempty(f))
        plot(x, -f(layer, :), 'r--', 'linewidth', 3);
    end
end
title('Depth of boundaries')
xlabel('Sensor location (m)')
ylabel('Height (m)')
leg = {'Ground', 'Predicted boundaries (std)', 'Predicted boundaries (mean)'};
if ( ~isempty(v) )
    leg{end+1} = 'True Boundaies';
end
%legend(leg, 'Location', 'North', 'Orientation', 'Vertical');
set(gca, 'FontSize', FONTSIZE);    
set(gca,'color','none');

% plot world model -- Velocity
v_handle = figure;
hold on;
for layer = 1 : n_layers
    if (isempty(std_v))
        plot(x, vopt(layer, :), 'b', 'linewidth', 3);
    else
        mu = vopt(layer, :);
        se = std_v(layer,:); 
        plotSingleConfidenceIntrerval(x, mu, se, mcmc.meanV(layer,:), mcmc.stdV(layer, :));        
    end
    if ( ~isempty(v) )
    plot(x, v(layer, :), 'r--', 'linewidth', 3);
    end
end
%box on;
title('Velocity of layers')
xlabel('Sensor location (m)')
ylabel('Velocity (m/s)')
leg = {'Predicted velocities (std)', 'Predicted velocities (mean)'};
        
if ( ~isempty(v) )
    leg{end+1} = 'True velocities';
end
%legend(leg, 'Location', 'North', 'Orientation', 'Vertical');
set(gca, 'FontSize', FONTSIZE);  
set(gca,'color','none');

end

function plotSingleConfidenceIntrerval(xstar, mu, se, m0, s0)
colorS = [0.7 0.9 0.95];
colorM = 'b';
xstar = xstar(:);
mu = mu(:);
se = se(:);
t = 1;
f = [mu+t*se;flip(mu-t*se)];
fill([xstar; flip(xstar)], f, colorS, 'EdgeColor', colorS);
hold on; plot(xstar, mu, colorM, 'LineWidth', 2);

plot(xstar, m0, 'k--');
plot(xstar, m0-t*s0, 'k-.');
plot(xstar, m0+t*s0, 'k-.');

end


















