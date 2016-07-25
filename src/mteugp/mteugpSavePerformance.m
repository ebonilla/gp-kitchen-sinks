function mteugpSavePerformance(i, model, xtest, ytest)
% Edwin V. Bonilla (http://ebonilla.github.io/)

if (~isfield(model,'resultsFname'))
    return;
end

[pred.mFpred, pred.vFpred]  = mteugpGetPredictive( model, xtest );
pred.gpred                  = mteugpPredict( model, pred.mFpred, pred.vFpred ); %         
perf                        = model.perfFunc(ytest, pred);
mteugpShowPerformance(i, model.resultsFname, model.linearMethod, perf);
save(model.resultsFname, 'model', 'pred', 'perf');

end



function mteugpShowPerformance(iter, resultsFname, linearMethod, perf)
fprintf('### Partial Results ###\n');
fprintf('%s \n', resultsFname );
names = fieldnames(perf);
fprintf('GlobalIter(%d): LinearMethod=%s --> ', iter, linearMethod );
for i = 1 : length(names)
    fprintf('%s=%.4f ', names{i}, perf.(names{i}));
end
fprintf('\n');
fprintf('### ###\n');

end

