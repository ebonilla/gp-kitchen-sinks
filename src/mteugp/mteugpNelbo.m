function nelbo  = mteugpNelbo( model )
%MTEUGPNELBO Return the negative evidence lower bound (NELBO) for a given
%model
% Edwin V. Bonilla (http://ebonilla.github.io/)


%% KL term
kl  = mteugpGetKL( model );

%% ELL term
ell = mteugpGetELL(model);

elbo = ell - kl;


nelbo = - elbo;
end




