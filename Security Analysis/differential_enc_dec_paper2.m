clc
clear all


D = 0;
UACI = 0;

i0 = imread('child.jpg');


i1 = encr(i0,0);
i2 = encr(i0,1);

[m,n] = size(i1);
%encryption

for i = 1:m
  for j = 1:n
    if i1(i,j) ~= i2(i,j)
      D = D + 1;
      UACI = UACI + abs(((double(i1(i,j))-double(i2(i,j))))/(m*n*255));
    end
   end
end    

NPCR = (D/(m*n))*100;
UACI = UACI*100;
display(NPCR);
display(UACI);



function x1 =  alt(r,x0 )
if x0 < 0.5
    x1 = mod ((r*x0*(1-x0) + ((4-r)*x0/2)),1);
 end
 if x0 >=0.5
    x1 = mod ((r*x0*(1-x0) + ((4-r)*(1-x0)/2)) ,1);
 end	
end

function img = encr(image,flag)
c0 = image;

% reading image's pixel in c
% c0 = imread('cat_64.jpg');
%c0 = imread('Brain2.jpg');
%c0 = squeeze(c0(:,:,3));
% get the dimensions of the image
[M,N] = size(c0);
cd = double(c0);

if flag == 1
  c1 = randi(M);
  c2 = randi(N);
  c0(c1,c2) = ~c0(c1,c2);
end


% random value insertion
R = zeros(M,N+1);
for i = 1:M
    for j = 1:N+1
        if j == 1
            R(i,j) = randi(i);
        else
            R(i,j) = cd(i,j-1);
        end
    end
end
B = zeros(M,N+1);
s1 = zeros(M,N+1);
s2 = zeros(N+1,M+1);
s3 = zeros(M+1,N+2);
s4 = zeros(N+2,M+2);

% user defined values
% values of r should be between 0 and 4.
% value of s0 should be between 0 and 1.
s0 = 0.87;
r0 = 1.5;
r1 = 1.3;
r2 = 1.2;
r3 = 1.1;
r4 = 1.3;


% 1-D substitution 
% first round of the encryption
for i = 1:M
    for j = 1:N+1
        if (i==1) && (j==1)
            s1(i,j) = alt(r0,s0);
        elseif (i>1) && (j == 1)
            s1(i,j) = alt(r0,s1(i-1,1));
        else    
            s1(i,j) = alt(r1,s1(i,j-1));
        end
        if j > 1    
            s = floor(mod(s1(i,j)* 10^10, 256));
            B(i,j) = bitxor(bitxor(B(i,j-1),R(i,j)),s);     
        end
    end
end
E = rot90(B);


% second round
% random value insertion
R = randi(255,N+1,1);
B = [R E];
R = B;
for i = 1:N+1
    for j = 1:M+1
        if (i==1) && (j==1)
            s2(i,j) = alt(r0,s1(1,N));
        elseif (i>1) && (j == 1)
            s2(i,j) = alt(r0,s2(i-1,1));
        else    
            s2(i,j) = alt(r2,s2(i,j-1));
        end
        if j > 1
            s = floor(mod(s2(i,j)* 10^10, 256));
            B(i,j) = bitxor(bitxor(B(i,j-1),R(i,j)),s);
        else
            B(i,j) = R(i,j);
        end
    end
end
E = rot90(B);


%third round 
% random value insertion
R = randi(255,M+1,1);
B = [R E];
R = B;
for i = 1:M+1
    for j = 1:N+2
        if (i==1) && (j==1)
            s3(i,j) = alt(r0,s2(N,1));
        elseif (i>1) && (j == 1)
            s3(i,j) = alt(r0,s3(i-1,1));
        else    
            s3(i,j) = alt(r3,s3(i,j-1));
        end
        if j > 1
            s = floor(mod(s3(i,j)* 10^10, 256));
            B(i,j) = bitxor(bitxor(B(i,j-1),R(i,j)),s);
        else
            B(i,j) = R(i,j);
        end
    end
end
E = rot90(B);


% fourth round
% random value insertion
R = randi(255,N+2,1);
B = [R E];
R = B;
for i = 1:N+2
    for j = 1:M+2
        if (i==1) && (j==1)
            s4(i,j) = alt(r0,s3(1,N));
        elseif (i>1) && (j == 1)
            s4(i,j) = alt(r0,s4(i-1,1));
        else    
            s4(i,j) = alt(r4,s4(i,j-1));
        end
        if j > 1
            s = floor(mod(s4(i,j)* 10^10, 256));
            B(i,j) = bitxor(bitxor(B(i,j-1),R(i,j)),s);     
        else
            B(i,j) = R(i,j);
        end
    end
end
E = rot90(B);

E = uint8(E); 
img = E;

%subplot(2, 5, 1);
%imshow(c0);
%title("Original image");
%subplot(2,5,2);
%imshow(E);
%title("Encrypted image");

end
