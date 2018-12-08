function nimg = asr_nimg(f)
x = dir([f.path '/' f.prefix '*.' f.extension]);

n = length(f.prefix)+4;
d = f.digits;

nimg = zeros(1000,1);
y    = cat(1,x.name);
z    = y(:,1:n);
st   = ' ';
sub  = 0;
for i=1:size(z,1);
    if compare(st,z(i,:))~=0,
        sub = sub+1;
        st=z(i,:);
        img = 0;
    end;
    img = img+1;
    nimg(sub) = img;
    if img ~= str2num(x(i).name(end-d-3:end-3-1))
        error('%s is inconsistent!!!',x(i).name)
    end
end
nimg = nimg(1:sub);