function makeMNISTBinaryData()
data = [];
load('data/mnistData/mnist_data.mat');

% training
x = data{1}.train_X;
y = makeBinaryLabel(data{1}.train_Y);

% test data
xx = data{1}.test_X;
yy = makeBinaryLabel(data{1}.test_Y);

system('mkdir -p data/mnistBinaryData');
save('data/mnistBinaryData/mnistBinary.mat', 'x', 'y', 'xx', 'yy');

end

% tas: Is it an odd number?
%  0: even, 1: odd
function y = makeBinaryLabel(Y)
classes = (0 : 9)';
[~,idx] = max(Y, [], 2);
y =  rem(classes(idx),2);

end

