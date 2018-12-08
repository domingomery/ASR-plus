% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_eval.m : Accuracy evaluation
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function p = asr_eval(f,ds,it,dall,vt,options)
show = options.show;
p = Bev_performance(ds,options.dtest);
if and(p<1,show>2)
    ii = find(ds~=options.dtest);
    JJ = [];
    for i=1:length(ii)
        I = [];
        I = asr_imgload(f,it(ii(i)));
        [N,M] = size(I);
        %if options.blur~=0
        %    I = asr_blur(I,options.blur);
        %end
        
        I = [I 256*ones(size(I,1),5)];
        jj = find(dall==ds(ii(i)));
        if isempty(jj)
            for j=1:options.n
                I = [I 128*ones(N,M)];
            end
        else
            for j=1:options.n
                I = [I asr_imgload(f,jj(j))];
            end
        end
        JJ = [JJ;I];
    end
    figure(3)
    imshow(imresize(JJ,0.5),[])
end


if show>2
    figure(4)
    asr_showconfusion(vt./(repmat(sum(vt,2),[1 options.k])))
end
