% Evaluates results on toy data
DATASET = 'toyData';
benchmark = {'lineardata', 'poly3data', 'expdata', 'sindata', 'tanhdata'};


for i = 1 : 1 %length(benchmark)
  evaluateBenchmark(DATASET, benchmark{i}, D);
end
