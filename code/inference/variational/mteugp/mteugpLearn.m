function  model  = mteugpLearn( model, xtest, ytest )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here
% xtest, ytest: used only to evaluate the model as we go -> to check
% progress

optConf = model.globalConf;

model                = model.initFunc(model); 
model.nelbo          = zeros(optConf.iter + 2,1);
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
    
    % We save results here after optimizing variational parameters
    if (isfield(model,'resultsFname'))
        [pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, xtest );
        pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         
        perf                        = model.perfFunc(ytest, pred);
        mteugpShowPerformance(i, model.resultsFname, model.linearMethod, perf)
        save(model.resultsFname, 'model');
    end
    
    %model = mteugpOptimizeFeatures(model);    
    model  = mteugpOptimizeHyper(model);

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

end
 

%


%% showProgress(iter, val)
function showProgress(iter, val)
fprintf('Nelbo(%d) %.4f\n', iter-1, val );
end



    














