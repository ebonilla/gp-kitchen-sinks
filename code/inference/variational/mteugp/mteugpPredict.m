function  Gstar  = mteugpPredict( model, MeanF, VarF )
%MTEUGPPREDICT Summary of this function goes here
%   Predicts the (noiseless) target variable (g*) for the EUGP
% based on the Gaussian predictive distribution
% MeanF: Nstar x Q matrix of means
% varF: Nstar x Q matrix of variances 
% model.nSmamples: Number of samples for MC averaging
% model.fwdFunc: forward function g(f):
%   it assumes it can handle multiple test points f* and 
%   return a matrix Nstar x P
% Gstar: matrix of Nstar x P predictions
% 

[Nstar, Q] = size(MeanF);
P          = model.P;
nSamples   = model.nSamples;
stdF       = std(VarF);

%% MC averaging
Z  = rand(Nstar, Q, nSamples);
G  = zeros(Nstar, P, nSamples);
for i = 1 : nSamples
    Fstar    = MeanF + Z(:,:,i).*stdF; % sample p(f*)
    G(:,:,i) = feval(model.fwdFunc, Fstar);  % g*
end
Gstar = mean(G,3);    

end

% TODO
% integrand for numerical integration
%function integrandQuad(model, f)
%g = model.fwdFunc(
%  gxs = self._passnlfunc(self.nlfunc, xsn)
%           quad_msEf = (xsn - Emn)**2 / Vmn
%            return gxs * np.exp(-0.5 * (quad_msEf + np.log(2 * np.pi * Vmn)))
%            