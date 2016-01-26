function  [model, grad] =  mteugpUnwrapHyperSimplified(model, theta)
% assume precision parameterization
% e.g. lambda_y = exp(theta)

[theta_f, theta_y, theta_w] = mteugpSplitHyper(theta, model.P, model.Q);
[theta_f, grad_f]           = mteugpUnwrapParameter(theta_f, model.featTransform);

[lambday, grad_y] = mteugpUnwrapParameter(theta_y, model.lambdayTransform);
[lambdaw, grad_w] = mteugpUnwrapParameter(theta_w, model.lambdawTransform);


% updating model variances and features
model.lambday = lambday;
model.lambdaw = lambdaw;
model.sigma2y = 1./lambday; 
model.sigma2w = 1./lambdaw;
model = mteugpUpdateFeatures(model, theta_f);

% final vector of gradients wrt precisions
grad  = [grad_f; grad_y; grad_w];

end


% OLD VERSION
% function model  = mteugpUnwrapHyper( model, theta )
% %MTEUGPUNWRAPHYPER Summary of this function goes here
% %   Detailed explanation goes here
% 
% L          = length(theta);
% P          = model.P; % Number of tasks
% Q          = model.Q; % Number of latent functions
% 
% nFeatParam = L - P - Q; % Number of feature parameters
% theta_phi  = theta(1:nFeatParam);
% theta_y    = theta(nFeatParam + 1 : nFeatParam + P);
% theta_w    = theta(nFeatParam + P + 1 : L); % should be Q-dimensional
% 
% % Updating corresponding structures
% model.featParam = theta_phi;
% model.Phi       = feval(model.featFunc, model.X, model.Z, theta_phi); 
% model.sigma2y   = exp(theta_y(:));
% model.sigma2w   = exp(theta_w(:));
% 
% 
% end

  