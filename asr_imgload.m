function I = asr_imgload(f,i,q)
if ~exist('q','var')
    q = 0;
end
sf  = [f.path f.prefix num2fixstr(f.ti(i),3) '_' num2fixstr(f.tf(i),f.digits) '.' f.extension ];
I   = double(imread(sf));
if isfield(f,'resize')
    I = imresize(I,f.resize);
    I = I - min2(I);   % to ensure positive grayvalues
    I = I/max2(I)*255; % to ensure grayvalues between 0 and 255
end

if isfield(f,'gray')
    if f.gray==1
        if size(I,3)==3
            I = double(rgb2gray(uint8(I)));
        end
    end
end

if isfield(f,'window')
    w = f.window;
    if ~isempty(w)
        I = I(w(1):w(2),w(3):w(4),:);
    end
end


if q>0 % pre-processing
    [N,M] = size(I);
    switch q
        case 1 % Mery's equalization
            J  = Bim_equalization(imresize(I,[256 256]));
            I  = imresize(J,[N M]);
        case 2 % Matlab's equalization
            I  = histeq(double(I)/256);
        case 3 % Median filter
            I  = medfilt2(I,[3 3]);
        case 4 % Sharpen filter
            L  = [0 1 0; 1 -4 1; 0 1 0];
            I  = I-0.15*(conv2(I,L,'same'));
    end
end
