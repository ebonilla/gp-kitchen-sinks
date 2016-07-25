function mteugpExample()
% Example of using MTEUGP (aka Extended and Unscented Kitchen Sinks)
% See Bonilla et al (International Conference on Machine Learning, 2016)
% Edwin V. Bonilla (http://ebonilla.github.io/)
rng('default');
linearMethod    = 'Unscented';         % {'Taylor', 'Unscented'}
D               = 50;              % number of features
fwdModel        = @exampleFwdModel; % This is the fwd model (problem specific)

[xtr,ytr,xte, yte, fte]   = generateData(fwdModel);


%% Learns model using default configuration
model = mteugpGetConfigDefault(xtr, ytr, fwdModel, linearMethod, D );
model = mteugpLearn( model );

%% Predicts distribution over f_* and single point over y (g*)
[mFpred, vFpred]  = mteugpGetPredictive( model, xte );
gpred = mteugpPredict( model, mFpred, vFpred ); %         

%% Plots results
figure;
[~, idx] = sort(xte);
plot(xte, fte, 'b.'); hold on;
plotConfidenceInterval(xte(idx), mFpred(idx), sqrt(vFpred(idx))); 
title('Fpred');

figure;
plot(xte, yte, 'b.'); hold on;
plot(xte, gpred, 'ro');
title('Gpred');

end

%% Generates data from a GP and passses them through the fwdModel
function [xtr,ytr, xte, yte, fte] = generateData(fwdModel)
N   = 1000;
Ntr = floor(0.2*N);

x   = linspace(-2*pi,2*pi, N)';
ell = 0.6;
sf2 = 0.8^2;
loghyper = [ log(ell);log(sqrt(sf2)) ];
covfunc = @covSEiso;
f = sampleGP(x, covfunc,loghyper);
g =  fwdModel(f);

idx = randperm(N);
xtr = x(idx(1:Ntr),:);
ytr = g(idx(1:Ntr),:);
xte = x(idx(Ntr+1:end),:);
yte = g(idx(Ntr+1:end),:);

fte  = f(idx(Ntr+1:end),:);


FONT_SIZE = 12;
plot(xtr,ytr, 'b.'); hold on;
plot(xte, fte, 'ro');
plot(xte,yte, 'go');
legend('ytrain', 'ftest', 'ytest');
set(gca, 'FontSize', FONT_SIZE);

end


%% Example of fwd nodel 
function [ g, dg ] = exampleFwdModel(f )
g  = f.^3 + f.^2 + f;
dg = 3*f.^2 + 2*f + 1;
end



