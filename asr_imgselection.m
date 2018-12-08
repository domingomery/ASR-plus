% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_imgselection.m : Selection of subjects and images of the database
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function f = asr_imgselection(f,options)

y=now/1e5;t=sprintf('%17.15f',y);x=(str2num(t(end))+1);
for i=1:x
    y=rand;
end

% rng('shuffle'); % Reinitialize the random number generator used by rand

k    = options.k;
n    = options.n;
smin = options.smin;
z    = options.nz;
show = options.show;
nimg = options.nimg;


if show>0
    disp('asr: selecting subjects, training and testing images...');
end

N    = length(nimg); % number of available images in database

sj     = randperm(N,N);

i     = 0;
j     = 0;

Ti    = zeros(k,1); % selected subjects

Tf    = zeros(k,n); % selected images


SHA = zeros(200,200);
if sum(f.ix_database(1:2)=='rr')==2
    load data_rr_sha
end

seltrain = ~isempty(options.imgtrain); % for AR+

if seltrain==1
    imgtrain = options.imgtrain;
    ntrain   = length(imgtrain);
    imgtest  = options.imgtest;
    ntest    = length(imgtest);
else
    imgtrain = 1:15000;
    imgtest  = 1:15000;
end

if show>1
    ft = Bio_statusbar('sampling faces');
end
% II = [];
sh = 10000;

I    = asr_imgload(f,1);
[nI,mI] = size(I);
II = zeros(nI*k,mI*n,'uint8');


while and(i<k,j<N)
    if show>1
        ft = Bio_statusbar(i/k,ft);
    end
    j          = j+1;
    indiv      = sj(j);
    
    % x          = rand(nimg(indiv),1); [~,xj]    = sort(x);
    if seltrain==1
       ii = randperm(ntrain,ntrain);
       jj = randperm(ntest,ntest);
       xj = [imgtrain(ii) imgtest(jj)];
    else
       xj = randperm(nimg(indiv),nimg(indiv));
    end
    a          = 0;
    ok         = 0;
    p          = 0;
    tp         = zeros(1,200);
    
    KK         = zeros(f.h,f.w,200);
    while ok==0
        a = a+1;
        if a<=nimg(indiv)
            f.ti = indiv;
            % okk = 0;
            if p<(n-1)
                okk = sum(imgtrain==xj(a))>0;
            else
                okk = sum(imgtest==xj(a))>0;
            end
            if okk
                f.tf = xj(a);
                I    = asr_imgload(f,1);
                if smin>0
                    if SHA(indiv,xj(a)) == 0;
                        sh = asr_sharpness(I,z,z);
                        SHA(indiv,xj(a)) = sh;
                        save data_rr_sha SHA
                        disp('*')
                    else
                        sh = SHA(indiv,xj(a));
                    end
                end
                if sh > smin
                    p = p + 1;
                    KK(:,:,p) = I;
                    tp(p) = xj(a);
                end
            end
        else
            ok = 1;
        end
        if p == n
            ok = 1;
        end
    end
    %[nI,mI] = size(I);
    JJ = zeros(nI,mI*n);
    if p>=n
        if ~isempty(options.imgtrain)
            %>sp = 1:n;
            sjp = 1:n;
        else
            %>sp = rand(n,1);
            sjp = randperm(n,n);
        end
        %>[~,sjp] = sort(sp);
        sjj = sjp(1:n);
        t = tp(sjj);
        for q=1:n
            % JJ = [JJ KK(:,:,sjj(q))];
            JJ(:,indices(q,mI)) = KK(:,:,sjj(q));
        end
        i = i+1;
        Ti(i) = indiv;
        Tf(i,:) = t;
        % II = [II; JJ];
        II(indices(i,nI),:) = uint8(JJ);
    end
end
if i<k
    error('not enough persons were selected')
end
if show>1
    delete(ft);
end
Ti = repmat(Ti,[1 n])';
f.ti = Ti(:);
Tf = Tf';
f.tf = Tf(:);
f.II = II;
