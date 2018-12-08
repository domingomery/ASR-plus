% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_visualvoc.m : Visual vocabulary, stopl-list and tfidf
%
% (c) Domingo Mery - PUC (2013), ND (2014)

% From Spyrou et al 2010:
% "... most of the cmmon visual words, i.e., those with smallest iDF values,
% are not descriminative and their abscence would facilitate the retrieval
% process. On the other hand, the rarest visual words are in most of the
% cases as result of noise and may distract the retrieval process. To
% overcome those problems, a stop list is created that includes the most
% and the least frequent visual words of the image collection."
%
% From Sivic & Zisserman (2003):
% "Using a stop list the most frequent visual words that occur in almost all
% images are supressed. The top 5% (of the frequency of visual words over
% all the keyframes) and bottom 10% are stopped."

function options = asr_visualvoc(p,options)

show = options.show;

k    = options.k;      % number of subjects
n    = options.n;      % number of images per subject
m    = options.m;      % number of patches per image
docu = options.docu;   % one document = one subject (1), or one image (2)

if docu == 1
    N = k;             % number of documents
    M = m*(n-1);       % number of patches per document
else
    N = k*(n-1);       % number of documents
    M = m;             % number of patches per document
end
options.ixn  = Bds_labels(M*ones(N,1));
if options.vocloc == 0
    if show>0
        disp('asr: visual vocabulary does not include location information.');
    end
    Y = p.z;
else
    if show>0
        disp('asr: visual vocabulary does include location information.');
    end
    Y = p.d;
end

options      = Bsq_visualvoc(Y,options);

