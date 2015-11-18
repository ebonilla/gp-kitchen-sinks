function  model  = mteugpLearnSimplified( model, xtest, ytest )
%MTEUGPLEARNSIMPLIFIED mteugpLearn using simplified version of NELBO
%   Detailed explanation goes here

optConf = model.globalConf;

model.nelbo = [];
model            = model.initFunc(model); 
%if (~isempty(model.nelbo)) % There awas a previous run 
%     model  = mteugpOptimizeHyper(model);
%end
oldNelbo         = model.nelbo;
model.nelbo      = zeros(optConf.iter + 2,1);
i = 1;
model.nelbo(i) =  mteugpNelboSimplified( model ); 
showProgress(i, model.nelbo(i));
tol = inf;
while (( i < optConf.iter) && (tol > optConf.ftol) )
    i = i + 1;
    model = mteugpOptimizeMeansSimplified(model);         
        
    model.nelbo(i) =  mteugpNelboSimplified( model );
    showProgress(i, model.nelbo(i));
    
    % We save results here after optimizing variational parameters
    if ( mod(i,5) == 0 )
       % model = mteugpUpdateCovariances(model);     
        mteugpSavePerformance(i, model, xtest, ytest);
    end
    
    %model  = mteugpOptimizeFeatParam( model );
    %model  = mteugpOptimizeSigma2y( model );
    %model  = mteugpOptimizeSigma2w(model);
    model  = mteugpOptimizeHyperSimplified(model );

    tol = abs( model.nelbo(i) - model.nelbo(i-1) );
    % tol = abs( (model.nelbo(i) - model.nelbo(i-1))/model.nelbo(i)   );
end
i = i + 1;
% After final update of  hyper-parameters
model = mteugpOptimizeMeansSimplified(model);         
model = mteugpUpdateCovariances(model);     

model.nelbo(i) =  mteugpNelboSimplified( model );
showProgress(i, model.nelbo(i));

T = i;
model.nelbo(T+1:end) = [];

model.nelbo = [oldNelbo; model.nelbo];

end


%% showProgress(iter, val)
function showProgress(iter, val)
fprintf('Nelbo(%d) %.4f\n', iter-1, val );
end


 