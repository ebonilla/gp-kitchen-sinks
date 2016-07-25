function  L  = getChol( Sigma )
%GETCHOL Summary of this function goes here
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

if ( isDiag(Sigma) )
    L = sqrt(Sigma);
else
    L = chol(Sigma, 'lower'); % 
end



return;
