function model  = mteugpUnwrapHyper( model, theta )
%MTEUGPUNWRAPHYPER Summary of this function goes here
%   Detailed explanation goes here

L          = length(theta);
P          = model.P; % Number of tasks
Q          = model.Q; % Number of latent functions

nFeatParam = L - P - Q; % Number of feature parameters
theta_phi  = theta(1:nFeatParam);
theta_y    = theta(nFeatParam + 1 : nFeatParam + P);
theta_w    = theta(nFeatParam + P + 1 : L); % should be Q-dimensional

% Updating corresponding structures
model.featParam = theta_phi;
model.Phi       = feval(model.featFunc, model.X, model.Z, theta_phi); 
model.sigma2y   = exp(theta_y(:));
model.sigma2w   = exp(theta_w(:));


end

