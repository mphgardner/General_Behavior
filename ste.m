function [STE] = ste(V)
%Determines the standard error of a vector
%This determines the standard error of a vector, should be updated for
%matrices

%If V is a vector this computes the ste along the correct dimension
if min(size(V)) == 1
STE = nanstd(V)/(sum(~isnan(V)))^.5;
else
STE = nanstd(V)./((sum(~isnan(V)))).^.5;
end



end

