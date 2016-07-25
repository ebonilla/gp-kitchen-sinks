function  model  = mteugpLearnSimplified( model, xtest, ytest )
%MTEUGPLEARNSIMPLIFIED mteugpLearn using simplified version of NELBO
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

TCHANGE = 2; % number of iterations to check for change in NELBO

model.nelbo = [];
model            = model.initFunc(model); 
optConf          = model.globalConf;
oldNelbo         = model.nelbo;

i = 1;
model.nelbo      = zeros(optConf.iter + 2,1);
model.nelbo(i)   =  mteugpNelboSimplified( model ); 
mteugpShowProgress(i, model.nelbo(i));

i              = i + 1;
model          = mteugpOptimizeMeansSimplified(model);         
model.nelbo(i) =  mteugpNelboSimplified( model );
mteugpShowProgress(i, model.nelbo(i));


tol = inf;
while (( i < optConf.iter) && (tol > optConf.ftol) )    
    % We save results here after optimizing variational parameters
    if ( mod(i,5) == 0 )
       % model = mteugpUpdateCovariances(model);     
        mteugpSavePerformance(i, model, xtest, ytest);
    end
    
    %model  = mteugpOptimizeFeatParam( model );
    %model  = mteugpOptimizeSigma2y( model );
    %model  = mteugpOptimizeSigma2w(model);
    model          = mteugpOptimizeHyperSimplified(model );
    model          = mteugpOptimizeMeansSimplified(model);         
    model          = mteugpUpdateCovariances(model);     

    i = i + 1;
    model.nelbo(i) =  mteugpNelboSimplified( model );
    mteugpShowProgress(i, model.nelbo(i));

    if (mod(i-1,TCHANGE) == 0)
        tol = abs( model.nelbo(i) - model.nelbo(i-TCHANGE) );
    end
    % tol = abs( (model.nelbo(i) - model.nelbo(i-1))/model.nelbo(i)   );
end
% After final update covariances
T = i;
model.nelbo(T+1:end) = [];

model.nelbo = [oldNelbo; model.nelbo];

end







 