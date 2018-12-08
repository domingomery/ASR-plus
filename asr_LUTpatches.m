% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_LUTpatches.m : indices of all pixels of all patches of size axb in an
% image of size hxw a patch is defined from pixel (i,j) of the image to 
% pixel (i+a-1,j+b-1)
%
% (c) Domingo Mery - PUC (2013), ND (2014)

function U = asr_LUTpatches(h,w,a,b)

U = zeros(w*h,a*b);
for i=1:h-a+1
    for j=1:w-b+1
        no = (j-1)*h+i;
        t = zeros(a,b);
        for k=0:b-1
            t(:,k+1) = (no:no+a-1)'+k*h;
        end
        U(no,:) = t(:)';
    end
end
