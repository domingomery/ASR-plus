% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_main.m : Main Program
%
% acc    : accuracy
% t      : testing time per face in seconds
% stbase : name of the database
% options: experiment options
%
% (c) Domingo Mery - PUC (2013), ND (2014)


function [acc,t] = asr_main(stbase,options)



% input

%%%%%%%%%%%%%%%%%%
% 1. DEFINITIONS
%%%%%%%%%%%%%%%%%%

% general
clb; warning('off','all')
opdef          = asr_defoptions();                   % default options
op             = asr_mergeoptions(options,opdef);    % merging user option with default options

% images
[f,op]         = asr_setimages(stbase,op);           % 'orl','yale','cas','rr','ar','lfwf', etc


op.k           = min([op.k f.imgmax]);               % number of classes <= number of images
op.heigh       = f.h;
op.width       = f.w;

switch op.feat
    case 'gray'
        op.a   = op.w;                               % patch's heigh
        op.b   = op.w;                               % patch's width
        op.ez  = op.a*op.b/(op.patchsub)^2;          % number of pixels
    case 'lbp'
        op.a   = op.w;                               % patch's heigh
        op.b   = op.w;                               % patch's width
        op.ez  = 59;                                 % descriptor's size
end
op.ez0         = 1;                                  % 1 includes descriptor and location, ez+1 includes location only


% labels
op.dD          = Bds_labels(op.R*ones(op.k,1));

dall           = Bds_labels(op.n*ones(op.k,1));      % labels of all images (k subjects with n images per subject)

itrain         = (1:op.n*op.k)';
itest          = op.n:op.n:op.n*op.k;
itrain(itest)  = [];

op.itest       = itest;
op.ntest       = length(itest);
op.dtest       = dall(itest);                        % labels of testing data
op.ix          = itrain;
op.uninorm     = 1;
dtrain         = Bds_labels(op.m*op.n*ones(op.k,1)); % ideal class, k subjects, nxm patches per person
ii             = asr_itfull(itest,op.m);
dtrain(ii,:)   = [];


%%%%%%%%%%%%%%%%%%%
% IMAGE ACQUISITION
%%%%%%%%%%%%%%%%%%%
f              = asr_imgselection(f,op);             % selected images after shaprness evaluation (if any)
% f.tf(1:4)'
f              = asr_showimages(f,op);               % display all images and show in yellow the test images

%%%%%%%%%%%%%%%%%%%
% DESCRIPTION
%%%%%%%%%%%%%%%%%%%

op.train        = 1;
[z,x,nd]        = asr_patches(f,op);
op.dtrain       = repmat(dtrain,[nd 1]); 

p              = asr_descriptor(z,x,op);             % building of descriptor p = g(z,x)

clear z x

if op.stoplist == 1
    op         = asr_visualvoc(p,op);                % create a visual vocabulary, stop list & tfidf
end

%%%%%%%%%%%%%%%%%%%
% MODELLING
%%%%%%%%%%%%%%%%%%%
[YP,YC]        = asr_modell(p,op);            % (YP,YC): Parent and Children clusters

clear p

%%%%%%%%%%%%%%%%
% TESTING
%%%%%%%%%%%%%%%%
op.m           = op.m2;
tic

% extracting patches for testing
op.ix          = itest;
op.train       = 0;
[zt,xt]        = asr_patches(f,op);
pt             = asr_descriptor(zt,xt,op);

clear zt xt

if op.stoplist == 1
    [~,op.itf]  = asr_stopout(pt,op);
else
    op.itf     = true(size(pt.z,1),1);
end

% computing distances to clusters
[D,S,IX,YC,Ytest] = asr_dist(pt,YP,YC,op);

clear pt

% classification
op.IX          = IX;
op.tfidf       = 0;
[ds,vt]        = asr_testing(f,Ytest,YC,D,S,op);

% save asr_data f op YP YC

% performance evaluation
t = toc/op.ntest;

acc              = asr_eval(f,ds,itest,dall,vt,op);
fprintf('asr:   testing time = %7.4f sec/face\n',t);
st =   ['asr:    performance = ' num2str(round(acc(1)*100)) '%'];
disp(st)
if op.show > 0
    if op.show>2
       title(st)
    end
end

