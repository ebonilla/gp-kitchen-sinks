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
