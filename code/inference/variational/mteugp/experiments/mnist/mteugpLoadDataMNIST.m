function dd  = mteugpLoadDataMNIST(DATASET, boolSample)
data = [];
load(['data/', DATASET, '/mnist_data.mat']);

dd.xtrain = data{1}.train_X;
dd.ytrain = data{1}.train_Y;
dd.xtest  = data{1}.test_X;
dd.ytest  = data{1}.test_Y;

clear data;

if (boolSample)
    dd = subSampleData(dd);
end 
end


% Just for testing
function data = subSampleData(data)
N = 20;
v = randperm(size(data.xtrain,1));
idx = v(1:N);
data.xtrain = data.xtrain(idx,:);
data.ytrain = data.ytrain(idx,:);


end

 