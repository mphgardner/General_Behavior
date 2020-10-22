function auROC = AUROC(A,B)
%This performs an auROC analysis on the vectors A and B
A = A(:)';
B = B(:)';

df = diff(sort([A B]));
df(df == 0) = [];
step = abs(min(df));

x = min([A B])-1:step:max([A B])+1;
if isempty(x)
    auROC = 0.5;
    return
end    
l = length(x);
a = histc(A,x);
b = histc(B,x);
aa = cumsum(a);
bb = cumsum(b);
xa = 1- aa/aa(l);
yb = 1- bb/bb(l);
auROC = - trapz(xa,yb);

end
