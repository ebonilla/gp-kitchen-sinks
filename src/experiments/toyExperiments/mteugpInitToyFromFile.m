function model = mteugpInitToyFromFile(benchmark, linearMethod, ...
                                        fold, D )
%MTEUGPINITTOYFROMFILE Summary of this function goes here
%   Detailed explanation goes here

fname =  ['results/toyData/', 'D', num2str(D), '/', linearMethod, ...
            '/', benchmark, '_k', num2str(fold), '.mat'];

load(fname, 'model');
model.nelbo = [];

fprintf('Model initialized from %s\n', fname);

end

