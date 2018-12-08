% DEMO for ASR+ 
%
% To run ASR+, following Matlab Toolboxes are required:
%             - VLFeat: http://www.vlfeat.org
%             - Balu  : http://dmery.ing.puc.cl/index.php/balu
%
% Mery, D.; Bowyer K. (2014): Face Recognition via Adaptive Sparse 
% Representations of Random Patches, IEEE Workshop on Information 
% Forensics and Security (WIFS 2014), Atlanta, Dec. 3-5.
%
% Paper can be downloaded from:
% http://web.ing.puc.cl/~dmery/Prints/Conferences/International/2014-WIFS-MeryBowyer.pdf
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


%% 1. Download database ORL

clc
close all
clear all
d = pwd;
st = [pwd '/orl/'];
orl_url = 'http://www.cl.cam.ac.uk/Research/DTG/attarchive/pub/data/att_faces.zip' ;
disp('ASR_plus demo requires a database to test. In this case we will use');
disp('ORL database from:');
disp(' ');
disp('F.S. Samaria and A.C. Harter: Parameterisation of a stochastic model for human face');
disp('identification. In Proceedings of the Second IEEE Workshop on Applications of');
disp('Computer Vision, pages 138-142, 1994.');
disp(' ');
disp('By downloading you agree to acknowledge the source of the images by including ');
disp('the citation in your publications.');
disp(' ')
yn = input('Do you want to download the image database [ 1=yes, 0=no ] (first time answer yes)? ');
if yn==1
    fprintf('Downloading ORL data to ''%s''. This will take a while...', st);
    unzip(orl_url,'orl');
    disp(' ');
    disp('ORL download succefully!');
    disp(' ');
end

%% 2. Copying faces of the original images

yn = input('Do you want to copy the image faces into the database [ 1=yes, 0=no ] (first time answer yes)? ');
if yn==1
    
    disp('Copying faces and croping images...');
    ft = Bio_statusbar('copying files');
    n = 40;
    for y=1:n
        ft = Bio_statusbar(y/n,ft);
        for t=1:10
            s1 = ['orl/s' num2str(y) '/' num2str(t) '.pgm' ];
            J = imresize(imread(s1),[110 90]);
            sf = ['orl/face_' num2fixstr(y,3) '_' num2fixstr(t,5) '.png' ];
            imwrite(J,sf,'png');
        end
    end
    delete(ft)
end


            

%% 3. ASR+
% The face images are in 'orl' directory using this format
% face_xxx_yyyy.png, where xxx corresponds to the subject and yyy corresponds
% to the number of the image of that subject.
% see asr_setimages.m for definition of all images of the experiment

% options of ASR+
% see asr_defoptions.m for default values of the options.

clear options;
options.k        = 40;   % # classes to be recognized
options.m        = 800;  % # patches per image
options.n        = 10;   % # images for training faces
options.Q        = 80;   % # parent clusters
options.R        = 50;   % # child clusters
options.w        = 16;   % size of the patch w x w
options.alpha    = 0.25; % weight factor
options.stoplist = 0;    % # visual words
options.show     = 3;    % display results

N                = 50;    % # repetitions of the experiment

eta = zeros(N,1);

for i=1:N
    eta(i) = asr_main('orl',options);
    fprintf('%2d) mean performance = %5.2f%%\n',i,100*mean(eta(1:i)));
end






