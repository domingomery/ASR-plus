% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_testing.m : Recognition of the test images
%
% (c) Domingo Mery - PUC (2013), ND (2014)


function [ds,vt] = asr_testing(f,Ytest,YC,D,S,options)

show           = options.show;
ntest          = options.ntest;
m              = options.m;
k              = options.k;
s              = options.s;
R              = options.R;
scqth          = options.scqth;
ez             = size(Ytest,2);
Q              = options.Q;
dtest          = options.dtest;
itf            = options.itf;

ds             = zeros(ntest,1);
vt             = zeros(ntest,k);
cosang         = options.cosang;

if show>0
    disp('asr: testing...');
    if show>1
        b              = Bio_statusbar('testing');
        if show>2
            fig3           = figure(3);
            set(fig3,'OuterPosition',[540,480,200,200])
        end
    end
end
if options.father ~= 1
    D = fix((D-1)/options.R)*R+1;
end

kk      = 1:k;
h0      = (0:R-1)';
h1      = repmat(h0,[1 k]);
h1      = (h1(:));
DDbak   = options.dD;
Tbak    = options.T;
jx      = zeros(R,k);

kkRQ = single((kk-1)*R*Q);

for i_t = 1:ntest
    t   = (i_t-1)*m;
    dp  = zeros(m,1);
    sc  = zeros(m,1);
    Px  = ones(m,k);
    for j=1:m
        options.ik     = S(t+j,:)>cosang; %
        nk             = sum(options.ik);
        if and(nk>0,itf(t+j))
            ypatch     = Ytest(t+j,:);   % patch j of test image i_t
            if options.father == 2
                jx(:)       = options.IX(:,t+j,:);
                Ap          = YC(jx,:);
            else
                i0          = kkRQ+D(t+j,:);
                h2          = repmat(i0,[R 1]);
                Ap          = YC(h1+h2(:),:); % dictionary for patch k
            end
            
            iik             = repmat(options.ik,[R 1])==1;
            options.dD      = DDbak(iik);
            options.T       = round(Tbak*nk/k)+1; % options.T  = Tbak;
            [dpq,scq,~,Pxj] = asr_modsrc(ypatch,Ap(iik,:)',options);
            % p          = p + 1;
            dp(j)           = dpq;
            sc(j)           = scq;
            % hh(p)      = S(t+j,dpq);
            Px(j,:) = Pxj*k;
        end
    end

    [si,sj]   = sort(sc,'descend');
    jj        = find(si>scqth);
    sm        = min([length(jj) s]);
    switch options.tfidf
        % ECCV2014 Method
        case 0
            switch options.strclass
                case 1
                    ds(i_t)   = mode(dp(sj(jj(1:sm))));
                case 2
                    PP = prod(Px);
                   [~,ds(i_t)] = max(PP); 
                case 3
                   PP = prod(Px(jj,:));
                   [~,ds(i_t)] = max(PP); 
                case 4
                   PP = prod(Px(jj(1:sm),:));
                  [~,ds(i_t)] = max(PP);
            end
            vt(i_t,:) = hist(dp(sj(jj(1:sm))),1:k);
            
            % Using Term Frequency-Inverse Document Frequency Wighting (Sivic & Zisserman, PAMI 2009)
            % All selected patches define a document
        case 1
            jselec        = sj(jj(1:sm));
            Yj            = options.Ytest0(t+1:t+m,1:ez+2);
            Yp            = Yj(jselec,:);
            [ixp,dxp]     = vl_kdtreequery(options.kd_voc,options.voc,Yp','NumNeighbors',1);
            nid           = hist(ixp(dxp<0.18),1:options.NV);
            nd            = length(jselec);
            N             = options.k*(options.n-1);
            vq            = nid/nd.*log(N./(options.Ni_go+1e-15));
            vq            = vq/norm(vq);
            vdot          = options.Vd*vq';
            [~,jg]        = sort(vdot,'descend');
            tj            = fix((jg-1)/(options.n-1))+1;
            ds(i_t)       = tj(1);
            
            % Using Term Frequency-Inverse Document Frequency Wighting (Sivic & Zisserman, PAMI 2009)
            % Patches classified by SRC as class 'x' define document 'x'. The
            % similarity is ranked.
        case 2
            jselec        = sj(jj(1:sm));
            js            = false(m,1);
            js(jselec)    = true;
            Yj            = options.Ytest0(t+1:t+m,1:ez+2);
            
            fg = zeros(k,1);
            
            for sb = 1:k;
                
                dpsb          = dp;
                dpsb(not(js)) = 0;
                ip            = dpsb==sb;
                Yp            = Yj(ip,:);
                [ixp,dxp]     = vl_kdtreequery(options.kd_voc,options.voc,Yp','NumNeighbors',1);
                nid           = hist(ixp(dxp<0.18),1:options.NV);
                nd            = length(jselec);
                N             = options.k*(options.n-1);
                vq            = nid/nd.*log(N./(options.Ni_go+1e-15));
                vq            = vq/norm(vq);
                vdot          = options.Vd*vq';
                [ii,jg]       = sort(vdot,'descend');
                tj            = fix((jg-1)/(options.n-1))+1;
                % ii(20:end)    = 0;
                fg(sb) = sum(ii((tj==sb)));
            end
            [~,jfg] = max(fg);
            ds(i_t)   = jfg;
        case 3
            jselec        = sj(jj(1:sm));
            js            = false(m,1);
            js(jselec)    = true;
            Yj            = options.Ytest0(t+1:t+m,:);
            
            fg = zeros(k,1);
            
            for sb = 1:k;
                
                dpsb          = dp;
                dpsb(not(js)) = 0;
                ip            = dpsb==sb;
                Yp            = Yj(ip,:);
                ixp           = vl_kdtreequery(options.kd_voc,options.voc,Yp','NumNeighbors',1);
                % nid           = hist(ixp(dxp<0.18),1:options.NV);
                nid           = hist(ixp,1:options.NV);
                nd            = length(jselec);
                N             = options.k*(options.n-1);
                vq            = nid/nd.*log(N./(options.Ni_go+1e-15));
                vq            = vq/norm(vq);
                vdot          = options.Vd*vq';
                [ii,jg]       = sort(vdot,'descend');
                tj            = fix((jg-1)/(options.n-1))+1;
                ii(20:end)    = 0;
                fg(sb) = sum(ii((tj==sb)))+3*sum(sc(dp==sb));
            end
            [~,jfg] = max(fg);
            ds(i_t)   = jfg;
    end
    
    
    
    
    
    
    
    
    if show>1
        b = Bio_statusbar(i_t/ntest,b);
        if show>2
        ixy = f.sxy(i_t,:);
        if ds(i_t) == dtest(i_t);
            scol = 'g';
        else
            scol = 'r';
        end
        figure(1)
        plot(ixy([1 2 2 1 1]),ixy([3 3 4 4 3]),scol)
        
        figure(3)
        per = Bev_performance(ds(1:i_t),dtest(1:i_t));
        bar(per*100)
        axis([0 2 0 110])
        title(['performance = ' num2str(round(per*100)) '%'])
        end
    end
    
end
if show>1
    delete(b)
end

% Codigo para mostrar patches y clusters
%
%             if show==2
%                 figure(4)
%                 clf
%                 II = asr_loadimg(f,ix(i_t));
%                 imshow(II,[]);
%                 hold on
%                 y1 = xyt(t+j,1)-w/2;
%                 x1 = xyt(t+j,2)-w/2;
%                 plot([x1 x1+w x1+w x1 x1],[y1+w y1+w y1 y1 y1+w],'r')
%
%                 figure(5)
%                 x = zeros(w,w);
%                 x(:) = ypatch;
%                 clf;
%                 imshow(x,[])
%                 figure(6)
%                 clf
%                 II = [];
%                 for ii=1:k;
%                     JJ=[];
%                     for jj=1:R;
%                         x(:)=Bim_lin(Ap((ii-1)*20+jj,:));
%                         JJ=[JJ x];
%                     end;
%                     II=[II;JJ];
%                 end;
%                 JJ = [];
%                 for ii=1:k
%                     yy = (ii-1)*w;
%                     xx = (D1(t+j,ii)-1)*w;
%                     %                   plot([xx+1 xx+1 xx+w xx+w xx+1],[yy+1 yy+w yy+w yy+1 yy+1],'g');
%                     JJ = [JJ;II(yy+1:yy+w,xx+1:xx+w)];
%                 end
%                 II = [II zeros(size(II,1),fix(w/4)) JJ];
%                 imshow(II,[])
%                 hold on
%                 for ii=1:k
%                     yy = (ii-1)*w;
%                     xx = (D1(t+j,ii)-1)*w;
%                     plot([xx+1 xx+1 xx+w xx+w xx+1],[yy+1 yy+w yy+w yy+1 yy+1],'g');
%                     JJ = [JJ;II(yy+1:yy+w,xx+1:xx+w)];
%                 end
%                 % enterpause
%             end



