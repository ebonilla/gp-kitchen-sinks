function  model  = mteugpLearn( model )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here

optConf = model.globalConf;

model                = mteugpInit(model); 
model.Nelbo          = zeros(optConf.iter + 2,1);
i = 0;
model.Nelbo(i+1) =  mteugpNelbo( model ); 
showProgress(i+1, model.Nelbo(i+1));
tol = inf;
while (( i < optConf.iter) && (tol > optConf.tol) )
    i = i + 1;
    model = mteugpOptimizeMeans(model);         
    model = mteugpOptimizeCovariances(model);  
    
    model.Nelbo(i+1) =  mteugpNelbo( model );
    showProgress(i+1, model.Nelbo(i+1));

    %model = mteugpOptimizeFeatures(model);    
    model  = mteugpOptimizeHyper(model);

    tol = abs(model.Nelbo(i+1) - model.Nelbo(i));
end

i = i + 1;
% After final update of features
model = mteugpOptimizeMeans(model);        
model = mteugpOptimizeCovariances(model);   

model.Nelbo(i+1) =  mteugpNelbo( model );
showProgress(i+1, model.Nelbo(i+1));


end


%% showProgress(iter, val)
function showProgress(iter, val)
fprintf('Nelbo(%d) %.3f\n', iter, val );
end



    














