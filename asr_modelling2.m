% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_modellin2.m : Learning modell after Ruben's idea
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function [Zp,Xp,Zc,Xc] = asr_modelling2(z,x,options)

Q              = options.Q;
k              = options.k;
R              = options.R;
ez             = size(z,2);
dict           = options.dictionary;
show           = options.show;
dtrain         = options.dtrain;

%par.Tdata      = options.Tdata;
%par.dictsize   = options.dictsize;
%par.iternum    = options.iternum;
%par.memusage   = options.memusage;

if options.stoplist == 1;
    [z,i_go] = Bsq_stopout(z,options);
    x        = x(i_go,:);
    dtrain   = dtrain(i_go);
end

Zp = zeros(Q*k,ez);
Xp = zeros(Q*k,2);
Zc = zeros(R*k*Q,ez);
Xc = zeros(R*k*Q,2);

if show>1
    if dict == 1
        ft = Bio_statusbar('modelling');
    else
        ft = Bio_statusbar('ksvd');
    end
end


for i=1:k
    if show>1
        fprintf('*');
        ft = Bio_statusbar(i/k,ft);
    end
    ii                 = dtrain==i;
    zi                 = z(ii,:);
    xi                 = x(ii,:);
    
    ok = 0;
    NC = 20;
    while not(ok)
        
        [~,dz]             = vl_kmeans(zi',NC,'Algorithm','Elkan');
        [~,dx]             = vl_kmeans(xi',NC,'Algorithm','Elkan');
        inew               = (dz-1)*NC+dx;
        hh                 = hist(double(inew),1:NC^2);
        [ih,jh]            = sort(hh,'descend');
        ii1                = jh(ih>=R);
        if length(ii1)>=Q
            ok = 1;
        else
            NC = round(NC/1.25);
            if show>1
                fprintf('.');
            end
            % [i NC]
        end
    end
    zpi                     = zeros(Q  ,ez);
    zci                     = zeros(Q*R,ez);
    xpi                     = zeros(Q  ,2);
    xci                     = zeros(Q*R,2);
    for q=1:Q
        ii                  = find(inew==ii1(q));
        zcqi                = zi(ii(1:R),:);
        xcqi                = xi(ii(1:R),:);
        zpi(q,:)            = mean(zcqi);
        xpi(q,:)            = mean(xcqi);
        zci(indices(q,R),:) = zcqi;
        xci(indices(q,R),:) = xcqi;
    end
    
    Zp(indices(i,Q),:)      = zpi;
    Xp(indices(i,Q),:)      = xpi;
    
    Zc(indices(i,Q*R),:)    = zci;
    Xc(indices(i,Q*R),:)    = xci;
    
end
if show>1
    delete(ft)
    fprintf('\n');
end

% if show == 2
%     i = 1;
%     w = options.w;
%     v = round(-0.5*w);
%     while(i>0)
%         i = input('subject? ');
%         if i>0
%             xx = YC(indices(i,Q*R),1:end-2);
%             qx = YC(indices(i,Q*R),end-1)/options.alpha;
%             qy = YC(indices(i,Q*R),end)  /options.alpha;
%
%             ii = indices(i,Q);
%             zz = YP(ii,1:end-2);
%             x  = YP(ii,end-1)/options.alpha;
%             y  = YP(ii,end)  /options.alpha;
%             x  = round(x+v);
%             y  = round(y+v);
%
%             I  = zeros(110,90);
%             z = zeros(w,w);
%             for j=1:Q
%                 z(:) = zz(j,:);
%                 I(x(j):x(j)+w-1,y(j):y(j)+w-1) = z;
%             end
%             figure(11)
%             clf
%             imshow(I,[])
%             pause
%             hold on
%             plot(y+w/2,x+w/2,'r.')
%             %for k=1:Q
%             %     text(y(k)+w/2,x(k)+w/2,num2str(k))
%             %end
%
%             p = vl_click;
%             x0 = p(2)-w/2;
%             y0 = p(1)-w/2;
%
%             dx = x-x0; dy = y-y0;
%             d = dx.*dx+dy.*dy;
%
%             [~,dj] = min(d);
%
%
%             II = [];
%             for ii=dj %1:Q
%                 JJ = [];
%                 for jj=1:R
%                     t = (ii-1)*R+jj;
%                     z(:) = xx(t,:);
%                     x    = qx(t)+v;
%                     y    = qy(t)+v;
%                     plot(y+w/2,x+w/2,'g.')
%                     JJ = [JJ z/max2(z)];
%                 end
%                 II = [II;JJ];
%             end
%             figure(12)
%             imshow(II,[])
%             pause
%
%         end
%     end
%
% end


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
