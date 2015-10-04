function   exploreMNIST(  )
%SAVEMNIST save MNIST data in format required by the mteugp model
%   Data has been previously exported from Ami'r phyton code
%
DATADIR = 'data/mnistData';
fname = [DATADIR, '/', 'mnist_data', '.mat'];
load(fname);
v = randperm(60000);

for i = 1 : 20
    idx = v(i);
    x = data{1}.train_X(idx,:);
    X = reshape(x, 28, 28)';
    imagesc(X); colormap(gray);
    label = find(data{1}.train_Y(idx,:) == 1) - 1; % 0 to 9 
    title(num2str(label));
    pause(2);
end

end

