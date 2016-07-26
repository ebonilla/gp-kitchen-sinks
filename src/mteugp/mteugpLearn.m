function  model  = mteugpLearn( model, xtest, ytest )
%MTEUGPLEARN Learns an MTEUGP model (aka extended/unscented kitchen sinks)
% INPUT:
%   - model: structure as obained from  mteugpGetConfigDefault.m
%   -  xtest, ytest: used only to evaluate the model as we go -> to check progress
% OUTPUT:
%   - model: modified structure with learned posterior parameters (model.M and Model.C) and
%   hyperparameters (m.featParam, m.sigma2y, m.sigma2w)
%
% Edwin V. Bonilla (http://ebonilla.github.io/)

model.nelbo = [];
model       = model.initFunc(model); 
optConf     = model.globalConf;
oldNelbo    = model.nelbo;
model.nelbo = zeros(optConf.iter + 2,1);
i = 1;
model.nelbo(i) =  mteugpNelbo( model ); 
showProgress(i, model.nelbo(i));
tol = inf;
while (( i < optConf.iter) && (tol > optConf.ftol) )
    i = i + 1;
    model = mteugpOptimizeMeans(model);         
    model = mteugpOptimizeCovariances(model);  
    
    model.nelbo(i) =  mteugpNelbo( model );
    showProgress(i, model.nelbo(i));
    
    if ( ~isempty(model.resultsFname) ) 
        save(model.resultsFname, 'model');  
    end
    
    % We save results here after optimizing variational parameters
    if (nargin > 1)
        mteugpSavePerformance(i, model, xtest, ytest);
    end
    
    model  = mteugpOptimizeHyper(model);

    tol = abs( model.nelbo(i) - model.nelbo(i-1) );
end
i = i + 1;
% After final update of features / hyper-parameters
model = mteugpOptimizeMeans(model);        
model = mteugpOptimizeCovariances(model);   

model.nelbo(i) =  mteugpNelbo( model );
showProgress(i, model.nelbo(i));

T = i;
model.nelbo(T+1:end) = [];

model.nelbo = [oldNelbo; model.nelbo];

end
 

%


%% showProgress(iter, val)
function showProgress(iter, val)
fprintf('Nelbo(%d) %.4f\n', iter-1, val );
end



    
 













