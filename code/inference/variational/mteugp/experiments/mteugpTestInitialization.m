function model = mteugpTestInitialization()

model = testIntializationUSPS();


end

function model = testIntializationUSPS()
% loads initialization that yields bad local optima 
data   = mteugpLoadDataUSPS('uspsData', 0);


fname = 'recycle/tmp2/results-bad/uspsData/D100/Taylor/uspsData_0.mat';
model.initFunc = @(model) loadModelFromFile(model, fname);
% adding some new structures

%model = mteugpLearnSimplified( model, data.xtest, data.ytest );
mteugpLearn( model, data.xtest, data.ytest );

end


function model =  loadModelFromFile(model, fname)
load(fname, 'model');

% structures in new implementation
model.featTransform    = 'linear';
model.lambdayTransform = 'exp';
model.lambdawTransform = 'exp';
model.predMethod       = 'mc';


% replace mean with good model
%good = load('tmp2/results-good/uspsData/D100/Taylor/uspsData_0.mat', 'model');
%model.M = good.model.M;

% replace featParam with new mapping
%
% quadratic mapping
% sigma_z         = exp(model.featParam); model.featParam = sqrt(sigma_z);
%
% linear mapping
% sigma_z         = exp(model.featParam); model.featParam = sigma_z;
%
% model           = mteugpUpdateFeatures(model, model.featParam);


% adding noise to targets 
% model.Y(model.Y==1) = 1 - 0.1;
% model.Y(model.Y==0) = 0.1;

% 


% we suffle the examples 
% idx     = randperm(length(model.Y));
% model.X = model.X(idx,:);
% model.Y = model.Y(idx,:);
% model   = mteugpUpdateFeatures(model, model.featParam);

end

