function data  = mteugpLoadDataMNISTBinary(DATASET, boolSample)
x = []; xx = []; y = []; yy = [];
load(['data/', DATASET, '/mnistBinary.mat']);
data.xtrain = x;
data.ytrain = y;
data.xtest   = xx;
data.ytest   = yy;

if (boolSample)
    data = subSampleData(data);
end 
end


% Just for testing
function data = subSampleData(data)
N = 100;
v = randperm(size(data.xtrain,1));
idx = v(1:N);
data.xtrain = data.xtrain(idx,:);
data.ytrain = data.ytrain(idx,:);



end

