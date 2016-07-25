function nelbo  = mteugpNelbo( model )
%MTEUGPNELBO Summary of this function goes here
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)


%% KL term
kl  = mteugpGetKL( model );

%% ELL term
ell = mteugpGetELL(model);

elbo = ell - kl;


nelbo = - elbo;
end




