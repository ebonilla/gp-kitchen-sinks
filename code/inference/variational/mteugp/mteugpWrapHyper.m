function [ theta ] = mteugpWrapHyper( model )
%MTEUGPWRAPHYPER Summary of this function goes here
%   Detailed explanation goes here
% featureParam: used directly by model.featFunc
% sigma2y = exp(theta_y): P-dimensional vector
% sigma2w = exp(theta_w): Q-dimensional vector

theta = model.featParam; % feture Parameters are taken care of by feature function
theta = [theta; log(model.sigma2y)];     
theta = [theta; log(model.sigma2w)]; % 

end

