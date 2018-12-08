function J = asr_blur(I,b)
t = round(b*8.5);
if t>1
    H = fspecial('gaussian',t,b);
    J = imfilter(I,H);
else
    disp('Warning: blur parameter is too small... the image was culd not be blurred.');
    J=I;
end

