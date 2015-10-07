function  mteugpRunAllMNIST(  )
%MTEUGPRUNALLUSPS Summary of this function goes here
%   Detailed explanation goes here
for idxMethod = 1 : 2
    for d = [500 1000]
        mteugpTestMNISTBinary( num2str(idxMethod), num2str(d), '0', '1' );
    end
end

for idxMethod = 1 : 2
    for d = [500 1000]
        mteugpTestMNIST( num2str(idxMethod), num2str(d), '0', '1' );
    end
end



end

