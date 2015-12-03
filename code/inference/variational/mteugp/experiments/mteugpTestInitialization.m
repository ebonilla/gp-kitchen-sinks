function model = mteugpTestInitialization()

% loads initialization that yields bad local optima 
model.initFunc = @loadModelFromFile;
data   = mteugpLoadDataUSPS('uspsData', 0);

model = mteugpLearnSimplified( model, data.xtest, data.ytest );
%mteugpLearn( model, data.xtest, data.ytest );

end


function model =  loadModelFromFile(model)
load('tmp2/results-bad/uspsData/D100/Taylor/uspsData_0.mat', 'model');

% replace mean with good model
%good = load('tmp2/results-good/uspsData/D100/Taylor/uspsData_0.mat', 'model');
%model.M = good.model.M;


end

