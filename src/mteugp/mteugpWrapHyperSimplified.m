function theta = mteugpWrapHyperSimplified(model)
 theta_f = mteugpWrapParameter(model.featParam, model.featTransform);
 theta_y = mteugpWrapParameter(model.lambday, model.lambdayTransform);
 theta_w = mteugpWrapParameter(model.lambdaw,model.lambdawTransform );
 theta  =  [theta_f; theta_y; theta_w ];
 
end

 
% Old version
% function [ theta ] = mteugpWrapHyper( model )
% %MTEUGPWRAPHYPER Summary of this function goes here
% %   Detailed explanation goes here
% % featureParam: used directly by model.featFunc
% % sigma2y = exp(theta_y): P-dimensional vector
% % sigma2w = exp(theta_w): Q-dimensional vector
% 
% theta = model.featParam; % feture Parameters are taken care of by feature function
% theta = [theta; log(model.sigma2y)];     
% theta = [theta; log(model.sigma2w)]; % 
% 
% end

 