function [ Sigmainv ] = mteugpGetSigmaInv( sigma2y )
%MTEUGPGETSIGMAINV Summary of this function goes here
%   Get (Sigma_y)^-1 based on vector of diagonals sigma2y
Sigmainv = diag(1./sigma2y);

end

