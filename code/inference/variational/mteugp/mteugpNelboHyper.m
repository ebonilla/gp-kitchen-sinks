function nelbo  = mteugpNelboHyper( theta, model )
%MTEUGPNELBOHYPER Summary of this function goes here
%   Nelbo used for optimization of all hyper-parameters
% theta = [featureParam; likelihoodParam; PriorParam]
%       = [featureParam; sigma2y; sigma2w]
%
% featureParam: used directly by model.featFunc
% sigma2y = exp(theta_y): P-dimensional vector
% Although  sigma2w is a D-dimensional here we consider an isotropic 
% parameterization sigma2w = exp(theta_w)*ones(D,1)
%

model = mteugpUpdateHyper( model, theta );

% UNCOMMENT ME PLEAE
model = mteugpOptimizeMeans(model);
model = mteugpOptimizeCovariances(model);
nelbo =  getNelboHyper(model);
% DELETE BELOW
%nelbo =  mteugpNelbo(model);

end



function nelbo =  getNelboHyper(model)
sigma2y      = model.sigma2y;
diagSigmaInv = 1./(sigma2y);
P            = model.P;
N            = model.N;
Q            = model.Q;
D            = model.D;

PhiM    = model.Phi*model.M; % N*Q
%[N P Q] = siz(model.A);
C = zeros(N, P);
for p = 1 : P
    Ap     = squeeze(model.A(:,p,:));
    C(:,p) = sum(Ap.*PhiM,2);
end
C        = model.Y - C - model.B;
elbo = sum(sum(bsxfun(@times,C, diagSigmaInv').*C)); % quad term

% remaining terms coming from KL and likelihood after cancelation of traces at optimal M,C
elbo = elbo +  N*( P*log(2*pi) + sum(log(sigma2y)) );
for q = 1 : Q
    sigma2w = model.sigma2w(q);
    C       = model.C(:,:,q); % posterior covariance
    cholC   = getCholSafe(C);
    m       = model.M(:,q); % posterior mean
    elbo   = elbo +  (1/sigma2w)*(m'*m)  ...
                  - getLogDetChol(cholC) ...
                  + D*log(sigma2w);
end

elbo  = -0.5*elbo;

nelbo = -elbo;


end


%% getNelboHyper
function nelbo = getNelboHyperOld(model)
% It actually uses a simplified version of the nelbo

sigma2y     = model.sigma2y;
Sigmainv    = diag(1./(sigma2y));
M           = model.M';
P           = model.P;
N           = model.N;
Q           = model.Q;
D           = model.D;

elbo = 0;
% Quadratic term
for n = 1 : N 
    yn       = model.Y(n,:)';
    An       = squeeze(model.A(n,:,:));
    phin     = model.Phi(n,:)';
    bn       = model.B(n,:)';
    elbo        = elbo + (yn - An*M*phin - bn)'*Sigmainv*(yn - An*M*phin - bn); % TODO: Improve efficiency
end

% remaining terms coming from KL and likelihood after cancelation of traces at optimal M,C
elbo = elbo +  N*( P*log(2*pi) + sum(log(sigma2y)) );
for q = 1 : Q
    sigma2w = model.sigma2w(q);
    C       = model.C(:,:,q); % posterior covariance
    cholC   = getCholSafe(C);
    m       = model.M(:,q); % posterior mean
    elbo   = elbo +  (1/sigma2w)*(m'*m)  ...
                  - getLogDetChol(cholC) ...
                  + D*log(sigma2w);
end

elbo  = -0.5*elbo;

nelbo = -elbo;



end































