function [theta_f, theta_y, theta_w] = mteugpSplitHyper(theta, P, Q)
% Edwin V. Bonilla (http://ebonilla.github.io/)

L          = length(theta);
nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = theta(1:nFeatParam);
theta_y    = theta(nFeatParam + 1 : nFeatParam + P);
theta_w    = theta(nFeatParam + P + 1 : L); % should be Q-dimensional

end
