function nelbo  = mteugpNelbo( model )
%MTEUGPNELBO Summary of this function goes here
%   Detailed explanation goes here


%% KL term
kl  = mteugpGetKL( model );

%% ELL term
ell = mteugpGetELL(model);

elbo = ell - kl;


nelbo = - elbo;
end




