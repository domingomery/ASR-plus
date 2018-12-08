function Y = asr_readpatches(I,ii,jj,U,options)
% ii: i values of coordinate i of first pixel of all patches
% jj: j values of coordinate j of first pixel of all patches
% I : grayvalue image
% U : Lookup Table of the indices of the patches computed using LUTpatches
h     = size(I,1);
kk    = (jj-1)*h+ii;
Iv    = I(:);
n     = length(kk);



if ~exist('options','var')
    feat = 'gray';
else
    feat = options.feat;
end

switch feat
    case 'gray'
        s     = options.patchsub;
        zz    = false(options.w,options.w);
        zz(1:s:end,1:s:end) = true;
        ii    = zz(:);
        m     = sum(ii);
        Y     = zeros(n,m);
        Y(:)  = Iv(U(kk,ii));
    case 'lbp'
       % m     = size(U,2);
       options.vdiv = 1;                      % one vertical divition
       options.hdiv = 1;                      % one horizontal divition
       options.semantic = 0;                  % classic LBP
       options.samples  = 8;                  % number of neighbor samples
       options.mappingtype = 'u2';            % uniform LBP
       % options.mappingtype = 'ri';          % rotation invariant (VERY BAD!!)
       options.show        = 0;
       [X,~,opt] = Bfx_lbp(I,[],options);     % LBP features
       options.maxD = size(X,2);
       Y = zeros(n,options.maxD);
       a = options.a;
       b = options.b;
       for i=1:n
           Y(i,:) = Bfx_lbpi(opt.Ilbp(ii(i):ii(i)+a-1,jj(i):jj(i)+b-1),[],options);
       end
end
% ez = m;