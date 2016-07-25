function  mteugpRunAllUSPS(  )
%MTEUGPRUNALLUSPS Summary of this function goes here
%   Detailed explanation goes here
for idxMethod = 1 : 2
    for d = [400 200 100]
        mteugpTestUSPSBinary( num2str(idxMethod), num2str(d), '0', '1' );
    end
end


end

