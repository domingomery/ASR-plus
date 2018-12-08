% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_modelling1.m : Learning Modell after ECCV2014
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function [YP,YC] = asr_modelling1(p,options)

% original after ECCV2014

Q              = options.Q;
k              = options.k;
R              = options.R;
ez             = options.ez;
dict           = options.dictionary;
show           = options.show;
dtrain         = options.dtrain;
spams          = options.spams;

par.Tdata      = options.Tdata;
par.dictsize   = options.dictsize;
par.iternum    = options.iternum;
par.memusage   = options.memusage;

if options.stoplist == 1;
    if options.vocloc == 0
        if show>0
            disp('asr: visual vocabulary does not include location information.');
        end
        Ystop = p.z;
    else
        Ystop = p.d;
    end
    [~,ifilt]      = Bsq_stopout(Ystop,options);
    Ytrain         = p.d(ifilt,:);
    dtrain         = dtrain(ifilt);
else
    if options.join == 1
        Ytrain     = p.d;
    else
        Ytrain     = p.z;
    end
end


ezz = ez+2;


YP = zeros(Q*k,ez+2);
YC = zeros(R*k*Q,ezz);
ik = 0;
if show>1
    if dict == 1
        ft = Bio_statusbar('modelling');
    else
        ft = Bio_statusbar('ksvd');
    end
end

param.K          = R;  % learns a dictionary with R elements
param.lambda     = 0;
param.numThreads = -1; % number of threads
param.batchsize  = 400;
param.verbose    = false;
param.iter       = 100;


for i=1:k
    if show>1
        ft = Bio_statusbar(i/k,ft);
    end
    ii                 = dtrain==i;
    YY                 = Ytrain(ii,:);
    [Ycen,jj]          = vl_kmeans(YY',Q,'Algorithm','Elkan');
    YP(indices(i,Q),:) = Ycen';
    
    for q=1:Q
        ik = ik+1;
        ii = find(jj==q);
        Yi = YY(ii,1:ezz);
        
        if length(ii)>R
            if dict==1
                D1 = vl_kmeans(Yi',R,'Algorithm','Elkan');
                CC = D1';
            else
                if spams == 0
                    par.data = Yi';
                    D1 = ksvd(par,'');
                    CC = D1';
                else
                    D1 = (mexTrainDL(Yi',param));
                    CC = Bft_uninorm(D1');
                end
            end
            % CC = Bft_uninorm(D1');
        else
            CC = Yi;
        end
        Rc = repmat(CC,[R 1]);
        
        YC(indices(ik,R),:) = Rc(1:R,:);
    end
end
if show>1
    delete(ft)
end
if show > 3
    i = 1;
    w = options.w;
    v = round(-0.5*w);
    while(i>0)
        i = input('subject? ');
        if i>0
            xx = YC(indices(i,Q*R),1:end-2);
            qx = YC(indices(i,Q*R),end-1)/options.alpha;
            qy = YC(indices(i,Q*R),end)  /options.alpha;
            
            ii = indices(i,Q);
            zz = YP(ii,1:end-2);
            x  = YP(ii,end-1)/options.alpha;
            y  = YP(ii,end)  /options.alpha;
            x  = round(x+v);
            y  = round(y+v);
            
            I  = zeros(110,90);
            z = zeros(w,w);
            for j=1:Q
                z(:) = zz(j,:);
                I(x(j):x(j)+w-1,y(j):y(j)+w-1) = z;
            end
            figure(11)
            clf
            imshow(I,[])
            pause
            hold on
            plot(y+w/2,x+w/2,'r.')
            %for k=1:Q
            %     text(y(k)+w/2,x(k)+w/2,num2str(k))
            %end
            
            p = vl_click;
            x0 = p(2)-w/2;
            y0 = p(1)-w/2;
            
            dx = x-x0; dy = y-y0;
            d = dx.*dx+dy.*dy;
            
            [~,dj] = min(d);
            
            
            II = [];
            for ii=dj %1:Q
                JJ = [];
                for jj=1:R
                    t = (ii-1)*R+jj;
                    z(:) = xx(t,:);
                    x    = qx(t)+v;
                    y    = qy(t)+v;
                    plot(y+w/2,x+w/2,'g.')
                    JJ = [JJ z/max2(z)];
                end
                II = [II;JJ];
            end
            figure(12)
            imshow(II,[])
            pause
            
        end
    end
    
end


% if options.father == 1
%     Cxy = YP(:,ez0:ez+2);
%     NN  = Q;
% else
%     Cxy = YC(:,ez0:ez);
%     NN = Q*R;
% end
% kd = cell(k); % preallocation of a cell
% for i=1:k
%     x = Cxy(indices(i,NN),1:sub:end)';
%     kd{i} = vl_kdtreebuild(x);
%     kd{i}.x = x;
% end
%
%
