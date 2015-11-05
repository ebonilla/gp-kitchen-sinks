function Cq = mteugpGetCq(Aq, Phi, sigma2wq, diagSigmayinv)
D          = size(Phi,2);
Hq         =   (1/sigma2wq) * eye(D); 
v          = diagProd(bsxfun(@times, Aq, diagSigmayinv'), Aq'); % Nx1
AA         = bsxfun(@times,Phi', sqrt(v'));
Hq         = Hq + AA*AA';           % Cq^{-1} 
cholHq     = getCholSafe(Hq);
Cq         = getInverseChol(cholHq);

end

