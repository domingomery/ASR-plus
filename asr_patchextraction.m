% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_patchextraction.m : Patch Extraction
% z: intenisty values
% x: location values
%
% (c) Domingo Mery - PUC (2013), ND (2014)


function     [z,x] = asr_patchextraction(f,options)

ix      = options.ix;
m       = options.m;
a       = options.a;
b       = options.b;
show    = options.show;
preproc = options.preproc;

dblur    = asr_defvalue(options,'blur',0);         % blur
drota    = asr_defvalue(options,'rotation',0);     % rotation
dzoom    = asr_defvalue(options,'zoom',0);         % zoom
dpers    = asr_defvalue(options,'perspective',0);  % perspective
doccl    = asr_defvalue(options,'occlusion',0);    % occlussion

if show>0
    fprintf('asr: extracting patches with blur=%d, rota=%d, zoom=%d, pers=%d, occl=%d...\n',dblur,drota,dzoom,dpers,doccl);
end



border   = asr_defvalue(options,'border',0);       % border
triggs   = asr_defvalue(options,'triggs',0);       % triggs
saliency = asr_defvalue(options,'saliency',0);     % saliency
border0  = border;

N = length(ix);
I = asr_imgload(f,1);
[h,w] = size(I);

U = asr_LUTpatches(h,w,a,b);

if show>1
    ff = Bio_statusbar('Extracting features');
    if show>2
        fig2 = figure(2);
    end
end
z = zeros(N*m,options.ez);
x = zeros(N*m,2);

if saliency==4
    r   = min([h w])/2-border;
    r2  = r*r;
    i0  = h/2; j0 = w/2;
    R_off     = zeros(h,w);
    for i=1:h;
        for j=1:w
            x2 = (i-i0)^2+(j-j0)^2;
            if x2<=r2
                R_off(i,j) = 1;
            end
        end
    end
end

for i=1:N
    ip = indices(i,m);
    I0 = asr_imgload(f,ix(i),preproc);
    I  = I0;
    
    if dblur>0
        I = asr_blur(I,dblur);
    end
    
    if triggs==1
        I = tantriggs(I);
    end
    
    if drota~=0
        I = imrotate(I,drota,'crop');
        border = border0 + 15;
    end
    
    if dzoom~=0
        I = asr_zoom(I,dzoom);
        if dzoom<0
            border = border0-round(dzoom);
        end
    end

    if dpers~=0
        I = asr_perspective(I,dpers);
        border = border0+round(abs(dpers)/2);
    end
    
    %if distortion~=0
    %    I = asr_distortion(I,distortion);
    %end
    
    if doccl>0
        I = asr_occlusion(I,doccl);
    end

    if show>1
        ff = Bio_statusbar(i/N,ff);
        if show>2
            imshow(I,[]);drawnow
        end
    end
    if std2(I)<1e-12
        fprintf('check image %d in directory %s\n',i,f.path)
        error('Image not found...')
    end
    
    switch saliency
        case 0 % anywhere
            ii        = border+randi(h-a+1-2*border,m,1);
            jj        = border+randi(w-b+1-2*border,m,1);
        case 1 % salient regions
            [~,J_off] = Bim_cssalient(I,1,0);
            R_off     = J_off>0;
            mm = 10*m;
            ii        = border+randi(h-a+1-2*border,mm,1);
            jj        = border+randi(w-b+1-2*border,mm,1);
            [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
            im        = randi(length(ii),m,1);
            ii        = ii(im)-round(border+a/2);
            jj        = jj(im)-round(border+b/2);
        case 2 % edges
            J_off     = edge(I,'canny',0.1,1);
            R_off     = imdilate(J_off,ones(7,7));
            mm        = 10*m;
            ii        = border+randi(h-a+1-2*border,mm,1);
            jj        = border+randi(w-b+1-2*border,mm,1);
            [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
            im        = randi(length(ii),m,1);
            ii        = ii(im)-round(border+a/2);
            jj        = jj(im)-round(border+b/2);
        case 3 % no specular regions
            R_off     = I0<245;
            mm        = 10*m;
            ii        = border+randi(h-a+1-2*border,mm,1);
            jj        = border+randi(w-b+1-2*border,mm,1);
            [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
            im        = randi(length(ii),m,1);
            ii        = ii(im)-round(border+a/2);
            jj        = jj(im)-round(border+b/2);
        case 4 % circular
            % R_off circle already calculated at the begining of this program
            mm        = 10*m;
            ii        = border+randi(h-a+1-2*border,mm,1);
            jj        = border+randi(w-b+1-2*border,mm,1);
            [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
            im        = randi(length(ii),m,1);
            ii        = ii(im)-round(border+a/2);
            jj        = jj(im)-round(border+b/2);
    end
    
    z(ip,:)         = asr_readpatches(I,ii,jj,U,options);
    x(ip,:)         = [ii jj];
    
    
end
x = x+ones(N*m,1)/2*[a b];
%x(:,1) = x(:,1)/h;
%x(:,2) = x(:,2)/w;
if show>1
    delete(ff)
    if show>2
        close(fig2);
    end
end
if options.uninorm == 1 % normalization
    z         = Bft_uninorm(z);
    x         = [x(:,1)/options.heigh x(:,2)/options.width];
end