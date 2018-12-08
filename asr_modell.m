% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_modell.m : Learning modell
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function [YP,YC] = asr_modell(p,options)

if options.show>0
    disp('asr: modelling...');
end


if options.modell == 1    
    [YP,YC] = asr_modelling1(p,options);
else
    % (Zp,Xp): Parent clusters (Q clusters for each class)
    % (Zc,Xc): Child clusters  (R clusters for each father cluster)
    % Z = f(intenisty), X = location 

    [Zp,Xp,Zc,Xc] = asr_modelling2(p.z,p.x,options);
    YP = [Zp Xp];
    YC = [Zc Xc];
end
