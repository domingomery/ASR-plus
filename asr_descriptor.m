% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_descriptor.m : Patch description
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function p = asr_descriptor(z,x,options)

method = options.desc;
alpha  = options.alpha;

p.z    = z;
p.x    = x;

switch method
    case 0
        p.d = z;
    case 1
        p.d  = Bft_uninorm([z alpha*x]);
    case 2
        p.d = Bft_uninorm([Bft_uninorm(z) alpha*x]);
    case 3
        p.d = [Bft_uninorm(z) alpha*x];

    case 4
        p.d = [z alpha*x];
    otherwise
        error('Method %d does not exist in asr_descriptor.\n',method);
end
