function  Gstar  = mteugpPredictLinear( model, xstar )
%MTEUGPPREDICTLINEAR Summary of this function goes here
%   Detailed explanation goes here
% predicts using linearization at phi_*

% Updates the model with test data
model.X         = xstar;
model.Phi       = feval(model.featFunc, model.X, model.featParam);
[ A, B ]        = mteugpUpdateLinearization( model);
Nstar           = size(xstar,1);
Gstar           = zeros(Nstar, model.P);
M               = model.M';
for n = 1 : Nstar
    An         = squeeze(A(n,:,:));
    phin       = model.Phi(n,:)';
    bn         = B(n,:)';
    Gstar(n,:) = An*M*phin + bn;
end

end

