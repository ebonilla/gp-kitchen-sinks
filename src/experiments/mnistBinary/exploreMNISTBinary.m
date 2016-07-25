function   exploreMNISTBinary(  )
%SAVEMNIST save MNIST data in format required by the mteugp model
%   Data has been previously exported from Ami'r phyton code
%
x = []; y = [];
DATADIR = 'data/mnistBinaryData';
fname = [DATADIR, '/', 'mnistBinary', '.mat'];
load(fname);
v = randperm(60000);

for i = 1 : 20
    idx = v(i);
    X = reshape(x(idx,:), 28, 28)';
    figure;imagesc(X); colormap(gray);
    label = y(idx); % 0 to 9 
    title(['idx=',num2str(idx), '-->', num2str(label) ]);
end

end

