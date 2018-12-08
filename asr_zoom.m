function I = asr_zoom(I,z)
[N0,M0] = size(I);
N = N0+2*z;
M = M0+2*z;
J = imresize(I,[N M]);
n = abs(z);
if z<0
    I = zeros(N0,M0);
    I(n+1:n+N,n+1:n+M) = J;
else
    I = J(n:n+N0-1,n:n+M0-1);
end
