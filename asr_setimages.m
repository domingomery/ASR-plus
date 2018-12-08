% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_setimages.m : Definition of all images of the experiment
%
% (c) Domingo Mery - PUC (2013), ND (2014)


function [f,options] = asr_setimages(ix,options)

f.ix_database    = ix;
f.path           = [options.local_data '/' ix '/'];
f.prefix         = 'face_';

options.imgtrain = [];
options.imgtest  = [];
options.sel      = 1;

ix0 = ix;

switch ix
    case 'jaffe'
        f.extension     = 'png';
        f.imgmax        = 7;
        f.resize        = [110 90];
        f.digits        = 5;
        options.border  = 8;
        options.smin    = 0;
        options.triggs  = 0;                                 % enhancement after Tan & Triggs
    case 'orl'
        f.extension     = 'png';
        f.imgmax        = 40;
        f.resize        = [110 90];
        f.digits        = 5;
        options.border  = 10;
        options.smin    = 0;
        options.triggs  = 0;                                 % enhancement after Tan & Triggs
    otherwise
        error('Unknown database');
end
f.ti = 1;
f.tf = 1;
I         = asr_imgload(f,1);
[f.h,f.w] = size(I); % dimension of the images height x width

sf = ['data_' ix0 '.mat'];
if ~exist(sf,'file')
    disp('estimating number of images per class...')
    nimg = asr_nimg(f);
    save(sf,'nimg');
else
    x = load(sf);
    nimg = x.nimg;
end
options.nimg = nimg;
