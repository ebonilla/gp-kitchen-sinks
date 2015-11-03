function nelbo  = mteugpNelboSimplified( model )
%MTEUGPNELBOSIMPLIFIED Simplified version of the Nelbo that
%  eliminates {C_q} from  explicit optimization


% gets required variables from model
sigma2y      = model.sigma2y;
diagSigmayinv = 1./(sigma2y);
diagSigmawinv = 1./model.sigma2w;   
P             = model.P;
N             = model.N;
Q             = model.Q;
D             = model.D;
M             = model.M; % posterior means
MuF           = model.Phi*M; % Mu_f = M*Phi

switch (model.linearMethod)
    case 'Taylor',
        [Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, N, P, Q);
        Ytilde    = model.Y - Gval;
        Ys        = bsxfun(@times, Ytilde, diagSigmayinv); % NxP
        ell       = sum(sum(Ys.*Ytilde)); % (y - g)^T Sigmay^-1 (y - g)
        ell       = ell + N*( P*log(2*pi) + sum(log(sigma2y)) );
        kl        = sum(sum(bsxfun(@times, M, diagSigmawinv).*M)); 
        for q = 1 : Q
            kl = kl + D*log(model.sigma2w(q));
            kl = kl + getLogDetTerm(J(:,:,q), model.Phi, model.sigma2w(q), diagSigmayinv);            
        end       
    case 'Unscented'
        ME = MException('VerifyMethod:UnsupportedLinearMethod', ...
             'Method Unscented currently unsupported');
          throw(ME);
end
nelbo = 0.5*(ell + kl); 

end


function logDetTerm = getLogDetTerm(Aq, Phi, sigma2wq, diagSigmayinv)
D = size(Phi,2);
Hq         =   (1/sigma2wq) * eye(D); 
v          = diagProd(bsxfun(@times, Aq, diagSigmayinv'), Aq'); % Nx1
AA         = bsxfun(@times,Phi', sqrt(v'));
Hq         = Hq + AA*AA';           % Cq^{-1} 
cholHq     = getCholSafe(Hq);
logDetTerm = getLogDetChol(cholHq); % log(det(Cq^{-1})

end