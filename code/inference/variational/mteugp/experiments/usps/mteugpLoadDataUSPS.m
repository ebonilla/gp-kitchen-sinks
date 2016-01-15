function data = mteugpLoadDataUSPS(DATASET, boolSample)
x = []; xx = []; y = []; yy = [];
load(['data/', DATASET, '/USPS_3_5_data.mat']);

% Change class labels -1 -> 0
y(y == -1)   = 0; 
yy(yy == -1) = 0;
data.xtrain = x;
data.ytrain = y;
data.xtest   = xx;
data.ytest   = yy;

if (boolSample)
    data = subSampleData(data);
end 

data = reshuffle_training_data(data);


end


% Just for testing
function data = subSampleData(data)
N = 10;
v = randperm(size(data.xtrain,1));
idx = v(1:N);
data.xtrain = data.xtrain(idx,:);
data.ytrain = data.ytrain(idx,:);


end


function data = reshuffle_training_data(data)

idx         = randperm(size(data.ytrain,1));
data.xtrain = data.xtrain(idx,:);
data.ytrain = data.ytrain(idx,:);

end
