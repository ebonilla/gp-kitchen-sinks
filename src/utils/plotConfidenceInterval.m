function plotConfidenceInterval(xstar,mu, se, t, area, colorM, colorS)
% plots a function with confidence intervals
% mu: vector of mean values of the function
% se: vector of standard errors
% t: value of +/- se to achieve some % confidence
% t=1.96 by default
% Edwin V. Bonilla (http://ebonilla.github.io/)

if (~exist('t', 'var') || isempty(t))
    t = 1.96;
end

if(~exist('area', 'var'))
    area = 1;
end

if (~exist('colorM', 'var'))
    colorM = 'k';
end

if (~exist('colorS', 'var'))
    colorS = [7 7 7]/8;
end

% making all vectors column vectors
xstar = xstar(:);
mu = mu(:);
se = se(:);

if (area) % draws std errors as colored areas
    f = [mu+t*se;flip(mu-t*se)];
    fill([xstar; flip(xstar)], f, colorS, 'EdgeColor', colorS);
    hold on; plot(xstar, mu, colorM, 'LineWidth', 2);
else
    f = [mu+t*se ,mu-t*se ];    
    plot(xstar, mu, 'LineWidth', 2, 'Color', colorM); hold on;
    plot(xstar, f(:,1), 'Color', colorS, 'LineStyle', '--');
    plot(xstar, f(:,2), 'Color', colorS, 'LineStyle', '--');
end



return;