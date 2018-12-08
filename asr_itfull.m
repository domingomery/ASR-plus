% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_itfull.m : Indices conversion
%
% (c) Domingo Mery - PUC (2013), ND (2014)


function iw = asr_itfull(it,P)

nit = length(it);

iw = zeros(P*nit,1);

for i=1:nit
    iw(indices(i,P),1) = indices(it(i),P);
end


