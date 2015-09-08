function  model  = mteugpLearn( model )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here

optConf = model.globalConf;

model                = mteugpInit(model); 
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

    %model = mteugpOptimizeFeatures(model);    
    model  = mteugpOptimizeHyper(model);

    tol = abs(model.nelbo(i) - model.nelbo(i-1));
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
 

%% showProgress(iter, val)
function showProgress(iter, val)
fprintf('Nelbo(%d) %.4f\n', iter-1, val );
end



    














