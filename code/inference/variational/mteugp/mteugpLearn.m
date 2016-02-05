function  model  = mteugpLearn( model, xtest, ytest )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here
% xtest, ytest: used only to evaluate the model as we go -> to check
% progress

model.nelbo = [];
model            = model.initFunc(model); 
optConf = model.globalConf;
%if (~isempty(model.nelbo)) % There awas a previous run 
%     model  = mteugpOptimizeHyper(model);
%end
oldNelbo         = model.nelbo;
model.nelbo      = zeros(optConf.iter + 2,1);
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
    
    save(model.resultsFname, 'model');  
    % We save results here after optimizing variational parameters
    if (nargin > 1)
        mteugpSavePerformance(i, model, xtest, ytest);
    end
    
    model = mteugpOptimizeFeatures(model);    
    %model  = mteugpOptimizeHyper(model);

    tol = abs( model.nelbo(i) - model.nelbo(i-1) );
    % tol = abs( (model.nelbo(i) - model.nelbo(i-1))/model.nelbo(i)   );
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



    
 













