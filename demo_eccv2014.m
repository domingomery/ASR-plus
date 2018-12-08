% DEMO for ASR+ 
%
% To run ASR+, following Matlab Toolboxes are required:
%             - VLFeat: http://www.vlfeat.org
%             - Balu  : http://dmery.ing.puc.cl/index.php/balu
%
% D. Mery, K. Bowyer (2014): Recognition of Facial Attributes using 
% Adaptive Sparse Representations of Random Patches. SoftBiometrics 
% Workshop of ECCV2014. Sep. 7th, Zurich.
%
% Paper can be downloaded from:
% http://web.ing.puc.cl/~dmery/Prints/Conferences/International/2014-ECCV-MeryBowyer.pdf
%
% Code written by: 
% Domingo Mery, Universidad Catolica de Chile, 2014
% http://dmery.ing.puc.cl dmery@ing.puc.cl
%
% Copyright 2014 by Group of Machine Intelligence (GRIMA), Department of 
% Computer Science, Universidad Catolica - Chile, and Computer Vision 
% Research Lab, Department of Computer Science and Engineering, University
% of Notre Dame, Indiana, USA.
%
% All rights reserved. This work is licensed under a Creative Commons 
% Attribution-Noncommercial-Share Alike 2.5 Generic License.
%  
% Permission to use, copy, or modify these programs and their documentation 
% for educational and research purposes only and without fee is hereby 
% granted, provided that this copyright notice appears on all copies and 
% supporting documentation.  For any other uses of this software, in 
% original or modified form, including but not limited to distribution in 
% whole or in part, specific prior permission must be obtained from 
% Pontificia Universidad Catolica de Chile.  These programs shall not be 
% used, rewritten, or adapted as the basis of a commercial software or 
% hardware product without first obtaining appropriate licenses from the 
% Pontificia Universidad Catolica de Chile.  Pontificia Universidad 
% Catolica de Chile makes no representations about the suitability of this 
% software for any purpose.  It is provided "as is" without express or 
% implied warranty.


%% 1. Download database JAFFE

clc
close all
clear all
d = pwd;
st = [pwd '/jaffe/'];
jaffe_url = 'http://www.kasrl.org/jaffeimages.zip' ;
disp('ASR_plus demo requires a database to test. In this case we will use');
disp('JAFFE database from:');
disp(' ');
disp('Michael J. Lyons, Miyuki Kamachi, Jiro Gyoba.');
disp('Japanese Female Facial Expressions (JAFFE), Database of digital images (1997)');
disp(' ');
disp('By downloading you agree to acknowledge the source of the images by including ');
disp('the citation in your publications.');
disp(' ')
yn = input('Do you want to download the image database [ 1=yes, 0=no ] (first time answer yes)? ');
if yn==1
    fprintf('Downloading JAFFE data to ''%s''. This will take a while...', st);
    unzip(jaffe_url);
    disp(' ');
    disp('JAFFE download succefully!');
    disp(' ');
end

%% 2. Cropping faces of the original images

yn = input('Do you want to detect, crop and copy image faces into the database [ 1=yes, 0=no ] (first time answer yes)? ');
if yn==1
    
    disp('Detecting faces and croping images...');
    d = dir([st '*.tiff']);
    
    NE = 0;
    HA = 0;
    SA = 0;
    SU = 0;
    AN = 0;
    DI = 0;
    FE = 0;
    
    x = 'NEHASASUANDIFEPI';
    
    n = length(d);
    close all
    figure(1)
    ft = Bio_statusbar('copying files');
    for i=1:n
        ft = Bio_statusbar(i/n,ft);
        na = d(i).name;
        si = [st na];
        I = imread(si);
        [xy,Icrop] = Bfr_facedetection(I,0);
        if ~isempty(Icrop)
            J = uint8(round(imresize(Icrop,[110 90])));
            e = na(4:5);
            y = (strfind(x,e)+1)/2;
            eval([e '=' e '+1;']);
            eval([' t = ' e ';']);
            subplot(1,7,y)
            imshow(J)
            drawnow
            sf = ['jaffe/face_' num2fixstr(y,3) '_' num2fixstr(t,5) '.png' ];
            imwrite(J,sf,'png');
        end
    end
    delete(ft);
    fprintf('%d face images was cropped and copied in ''%s''.\n',n,st);
    fprintf('face_001*.png: there are %d (NE) ''neutral'' faces.\n'  ,length(dir([st '/face_001*.png'])));
    fprintf('face_002*.png: there are %d (HA) ''happiness'' faces.\n',length(dir([st '/face_002*.png'])));
    fprintf('face_003*.png: there are %d (SA) ''sadness'' faces.\n'  ,length(dir([st '/face_003*.png'])));
    fprintf('face_004*.png: there are %d (SU) ''surprise'' faces.\n' ,length(dir([st '/face_004*.png'])));
    fprintf('face_005*.png: there are %d (AN) ''anger'' faces.\n'    ,length(dir([st '/face_005*.png'])));
    fprintf('face_006*.png: there are %d (DI) ''disgust'' faces.\n'  ,length(dir([st '/face_006*.png'])));
    fprintf('face_007*.png: there are %d (FE) ''fear'' faces.\n'     ,length(dir([st '/face_007*.png'])));
    close all
end

%% 3. ASR+
% The face images are in 'jaffe' directory using this format
% face_xxx_yyyy.png, where xxx corresponds to the class and yyy corresponds
% to the number of the sample of that class.
% see asr_setimages.m for definition of all images of the experiment

% options of ASR+
% see asr_defoptions.m for default values of the options.

clear options;
options.k     = 7;    % # classes to be recognized
options.m     = 200;  % # patches per image
options.n     = 29;   % # images for training faces
options.Q     = 100;  % # parent clusters
options.R     = 80;   % # child clusters
options.w     = 40;   % size of the patch w x w
options.alpha = 3;    % weight factor
options.NV    = 100;  % # visual words
options.show  = 3;    % display results

N             = 50;   % # repetitions of the experiment

eta = zeros(N,1);

for i=1:N
    eta(i) = asr_main('jaffe',options);
    fprintf('%2d) mean performance = %5.2f%%\n',i,100*mean(eta(1:i)));
end






