function mteugpRunAllToy(  )
%MTEUGPRUNALLTOY Summary of this function goes here
%   Detailed explanation goes here

for idxBench = 1 : 5
    for idxMethod = 1 : 2
        for idxFold = 1 : 5
            for D = [25, 50, 100]
            mteugpTestToyData( idxBench, idxMethod, idxFold, D, 1);
            end
        end
    end
end

end

    