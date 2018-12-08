% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_patchextraction.m : Patch Extraction
% z:  intenisty values
% x:  location values
% nd: number of groups of pacthes
%
% (c) Domingo Mery - PUC (2013), ND (2014)


function     [z,x,nd] = asr_patches(f,options)

if options.train == 1
    dblur = asr_defvalue(options,'blurtrain',0);  % blur
    drota = asr_defvalue(options,'rotatrain',0);  % rotation
    dzoom = asr_defvalue(options,'zoomtrain',0);  % zoom
    dpers = asr_defvalue(options,'perstrain',0);  % perspective
    doccl = asr_defvalue(options,'occltrain',0);  % occlussion
else
    dblur = asr_defvalue(options,'blurtest',0);  % blur
    drota = asr_defvalue(options,'rotatest',0);  % rotation
    dzoom = asr_defvalue(options,'zoomtest',0);  % zoom
    dpers = asr_defvalue(options,'perstest',0);  % perspective
    doccl = asr_defvalue(options,'occltest',0);  % occlussion
end

options.blur        = 0; % blur
options.rotation    = 0; % rotation
options.zoom        = 0; % zoom
options.perspective = 0; % perspective
options.occlusion   = 0; % occlussion

% Computing size of arrays z and x

s = 1;

if dblur(1)>0
    s = s+length(dblur);
end

if drota(1)~=0
    s = s+length(drota);
end

if dzoom(1)~=0
    s = s+length(dzoom);
end

if dpers(1)~=0
    s=s+length(dpers);
end

if doccl(1)>0
    s = s+length(occl);
end

Nm = length(options.ix)*options.m;

z = zeros(Nm*s,options.ez);
x = zeros(Nm*s,2);

nd = 1;

ii = indices(nd,Nm);
[z(ii,:),x(ii,:)] = asr_patchextraction(f,options);          % z = f(intensity), x = (x,y) location

if dblur(1)>0
    for i = 1:length(dblur)
        options.blur = dblur(i);
        nd = nd+1;
        ii = indices(nd,Nm);
        [z(ii,:),x(ii,:)] = asr_patchextraction(f,options);          % z = f(intensity), x = (x,y) location
    end
    options.blur        = 0;
end

if drota(1)~=0
    for i = 1:length(drota)
        options.rotation = drota(i);
        nd = nd+1;
        ii = indices(nd,Nm);
        [z(ii,:),x(ii,:)] = asr_patchextraction(f,options);          % z = f(intensity), x = (x,y) location
    end
    options.rotation        = 0;
end

if dzoom(1)~=0
    for i = 1:length(dzoom)
        options.zoom = dzoom(i);
        nd = nd+1;
        ii = indices(nd,Nm);
        [z(ii,:),x(ii,:)] = asr_patchextraction(f,options);          % z = f(intensity), x = (x,y) location
    end
    options.zoom        = 0;
end

if dpers(1)~=0
    for i = 1:length(dpers)
        options.perspective = dpers(i);
        nd = nd+1;
        ii = indices(nd,Nm);
        [z(ii,:),x(ii,:)] = asr_patchextraction(f,options);          % z = f(intensity), x = (x,y) location
    end
    options.perspective        = 0;
end

if doccl(1)>0
    for i = 1:length(occl)
        options.occlusion = doccl(i);
        nd = nd+1;
        ii = indices(nd,Nm);
        [z(ii,:),x(ii,:)] = asr_patchextraction(f,options);          % z = f(intensity), x = (x,y) location
    end
    options.occlusion        = 0;
end
