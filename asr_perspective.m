function J = asr_perspective(I,p)
[N,M] = size(I);

m1 = [1 1 N N
    1 M 1 M
    1 1 1 1];

b = abs(p)/2;

if p>0
    
    rr = -[b 0  -b 0
        b  -b  b -b];
    
else
    rr = -[0   b  0  -b
        b    -b  b  -b];
end

m2 = [m1(1:2,:)+rr; 1 1 1 1];
Hs = Bmv_homographySVD(m1,m2);

J = uint8(Bmv_projective2D(I,Hs,[N M],0));



