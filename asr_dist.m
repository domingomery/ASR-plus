% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_dist.m : Distances to the modell
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function [D,S,IX,YC,Ytest] = asr_dist(pt,YP0,YC0,options)

Q              = options.Q;
R              = options.R;
ez             = options.ez;
show           = options.show;

if show>0
    disp('asr: computing distances...');
end

if options.join == 0 % descriptor does not contain location
    YC     = single(YC0(:,1:ez));
    YP     = single(YP0(:,1:ez));
    Ytest  = single(pt.z);
    if options.uninorm == 0 % it is necessary since the similarity requieres uninorm
        YC    = single(Bft_uninorm(YC));
        YP    = single(Bft_uninorm(YP));
        Ytest = single(Bft_uninorm(Ytest));
    end
else
    YC     = single(Bft_uninorm(YC0));
    YP     = single(Bft_uninorm(YP0));
    Ytest  = single(Bft_uninorm(pt.d));
end

if ~isfield(options,'sub')
    sub        = 1;
else
    sub        = options.sub;
end

ii    = 1:size(YC,2);
jj    = ii(1:sub:end);

k     = options.k;
m     = options.m;
ntest = options.ntest;
nt    = size(Ytest,1);

if show>1
    ft = Bio_statusbar('distances');
end

switch options.father
    case 0 % CVPR original paper: search for nearest child, it takes all children from the same child cluster
        Cxy = YC(:,ii);
        NN = Q*R;
    case 1 % search for nearest father
        Cxy = YP(:,ii);
        NN  = Q;
    case 2 % Ruben's idea: search for nearest child, it takes all R nearest children from any child cluster
        Cxy = YC(:,ii);
        NN  = Q*R;
end

D  = zeros(k*m,ntest,'single');
S  = zeros(k*m,ntest,'single');
if options.father == 2
    IX = zeros(R,nt,k,'int32');
else
    IX = [];
end
y  = Ytest(:,jj);
for i = 1:k
    rr      = indices(i,NN);
    if show>1
        ft      = Bio_statusbar(i/k,ft);
    end
    X       = y*Cxy(rr,jj)';        % dot product means similarity (see eq. (5) Sivic et al PAMI2009)
    [j2,i2] = max(X,[],2);          % max means the most similar vectors
    D(:,i)  = i2';                  % index of which vector is the most similar
    S(:,i)  = j2';                  % value of the similarity, the large the similar
    if options.father == 2
        [~, IXX]  = sort(X,2,'descend');
        IX(:,:,i) = IXX(:,1:R)'+rr(1)-1;
    end
end
if show>1
    delete(ft);
end