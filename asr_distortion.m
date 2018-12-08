function J = asr_distortion(I,b)
m1 = [1  1 110 110
    1 90   1  90
    1  1   1  1];

if b>0
    if b<100
        rr = b*(rand(2,4)-0.5);
    else
        if b<200
            if b<150
                b = (b-100)/2;
                rr = -[b 0  -b 0
                    b  -b  b -b];
            else
                b = (b-150)/2;
                rr = -[b   b  -b -b
                       b  -b  b -b];
            end
            %rr = [-10 0  10 0
            %      -10 0  -10 0];
            
        else
            if b<250
                b = (b-200)/2;
                rr = -[0   b  0  -b
                    b    -b  b  -b];
            else
                b = (b-250)/2;
                rr =  [b   b  -b -b
                       b  -b  b -b];
            end
            %rr = [0  -10  0  10
            %      0  10  0  10];
        end
    end
    
    
else
    rr = -b*(ones(2,4)-0.5);
end
m2 = [m1(1:2,:)+rr; 1 1 1 1];
Hs = Bmv_homographySVD(m1,m2);

J = Bmv_projective2D(I,Hs,[110 90],0);


