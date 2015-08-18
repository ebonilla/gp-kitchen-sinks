function [ meanF, CovF ] = mteugpGetPosteriorF( model, q, Phi )
%MTEUGPGETPOSTERIORF Summary of this function goes here
%   Detailed explanation goes here
% Get posterior over f_q

meanF = Phi*model.M(:,q);
CovF  = Phi*model.C(:,:,q)*Phi';


end

