clc
clear all


i0 = imread('ct_brain.png');

i1 = encr(i0,0);
i2 = encr(i0,1);

if size(i1) ~= size(i2)
  disp('images are different');
else
[m,n] = size(i1);
count = 0;
for i = 1:m
  for j = 1:n
    if i1(i,j) == i2(i,j)
    %isequal(i1,i2)
      count = count+1;
     end
   end
 end
 display (count)
 percentage_matched = [count/(m*n)]*100;
 display (percentage_matched)
end




function x = pwlcm(x,n)
% x = (0,1) and n = (0,0.5)
if 0.5 < x && x <= 1
		x = pwlcm(1-x,n);
end
if 0 <= x && x < n
		x = x/n;
end
if n <= x && x <= 0.5
		x = (x-n)/(0.5-n);
end
end

function img = encr(image,flag)
c0 = image;

% reading image's pixel in c
%c0 = imread('tank.png');
%c0 = squeeze(c0(:,:,3));
% get the dimensions of the image
[M,N] = size(c0);
cd = double(c0);

% extracting all bit one by one
% from 1st to 8th in variable
% from c1 to c8 respectively
c1 = mod(cd, 2);
c2 = mod(floor(cd/2), 2);
c3 = mod(floor(cd/4), 2);
c4 = mod(floor(cd/8), 2);
c5 = mod(floor(cd/16), 2);
c6 = mod(floor(cd/32), 2);
c7 = mod(floor(cd/64), 2);
c8 = mod(floor(cd/128), 2);

% creating A1 and A2 matrices containing the bitplane
A1 = [c1 c2 c3 c4 ];
A2 = [c5 c6 c7 c8 ];
L = 4*M*N;
X = zeros(1,M*N);

% key for diffusion phase
x0 = 0.3;
n0 = 0.2;
% key for confusion phase
y0 = 0.3;
u0 = 0.2;

if flag == 1
  x0 = x0 + 0.0000001;
end

X(1) = x0;
for i= 1:M*N-1
    X(i+1)=pwlcm(X(i),n0);
end
X = mod(floor(X*10^14),256);

x1 = mod(X, 2);
x2 = mod(floor(X/2), 2);
x3 = mod(floor(X/4), 2);
x4 = mod(floor(X/8), 2);
x5 = mod(floor(X/16), 2);
x6 = mod(floor(X/32), 2);
x7 = mod(floor(X/64), 2);
x8 = mod(floor(X/128), 2);

b1 = [x1 x2 x3 x4];
b2 = [x5 x6 x7 x8];
% initiating the encryption
% Diffusion phase
% sum calculates the sum of each column then calling sum to calculate the overall
% calling sum twice because A2 is a matrix
sum1 = sum(sum(A2));

% circle shift the matrix to the right by the value in sum1
A11 = circshift(A1,sum1(1),2);
% Initializing B1
B1 = zeros(L,1);
B1(1) = xor(xor(xor(A11(1),A11(L)),A2(1)),b1(1));

for i = 2:L
   B1(i) = xor(xor(xor(A11(i),A11(i-1)),A2(i)),b1(i));
end

% Calling sum on B1 only once since B1 is an array.
sum2 = sum(B1);

A22 = circshift(A2,sum2,2);
%A22 = [1,1,0,0,0];
% Initializing B2
B2 = zeros(L,1);
B2(1) = xor(xor(xor(A22(1),A22(L)),B1(1)),b2(1));

for i = 2:L
  B2(i) = xor(xor(xor(A22(i),A22(i-1)),B1(i)),b2(i));
end

% confusion phase
% using randi in place of key from chaotic maps
% generates a random numbers from 1 to L.
% length of the Y and Z is L
%Y = [1:L];
%Z = [1:L];

% Y = randi(1,L);
% Z = randi(1,L);
% key for confusion phase
y0 = 0.2;
u0 = 0.4;

if flag == 1
  y0 = y0 + 0.0000001;
end

sum3 = sum2 + sum(B2); 
s0 = mod(y0+sum3/L,1);
S = zeros(1,2*L);
S(1) = s0;
% for i = 1:2*L-1
%    S(i+1) = pwlcm(s0,u0);
% end

for i=1:2*L-1
    if S(i)>=0 && S(i)<u0
        S(i+1)=S(i)/u0;
    end
    if S(i)>=u0 && S(i)<0.5
        S(i+1)=(S(i)-u0)/(0.5-u0);
    end
    if S(i)>=0.5 && S(i)<1-u0
        S(i+1)=(1-u0-S(i))/(0.5-u0);
    end
    if S(i)>=1-u0 && S(i)<1
        S(i+1)=(1-S(i))/u0;
    end    
end

s1 = S(1:L);
s2 = S(L+1:2*L);

Y = mod(floor(s1 * 10^14),L) + 1;
Z = mod(floor(s2 * 10^14),L) + 1;

for i = 1:L
  [B2(Y(i)),B1(i)] = deal(B1(i),B2(Y(i)));
end

for j = 1:L
  [B1(Z(j)),B2(j)] = deal(B2(j),B1(Z(j)));
end

% I have not implemented the number of rounds
% simplicity sake we can assume n=1. However, to implement n rounds,
% we would have to loop the diffusion and confusion phase.

% converting the array C1  and C2 into matrices
E1 = reshape(B1,[M,4*N]);
E2 = reshape(B2,[M,4*N]);

% splitting the matrices into bitplanes
E11 = mat2cell(E1,M,[N N N N]);
E22 = mat2cell(E2,M,[N N N N]);

% extracting bitplances from E11 and E22
e1 = cell2mat(E11(1));
e2 = cell2mat(E11(2));
e3 = cell2mat(E11(3));
e4 = cell2mat(E11(4));
e5 = cell2mat(E22(1));
e6 = cell2mat(E22(2));
e7 = cell2mat(E22(3));
e8 = cell2mat(E22(4));

% combining bitplanes again to form the encrypted image
ee = (2 * (2 * (2 * (2 * (2 * (2 * (2 * e8 + e7) + e6) + e5) + e4) + e3) + e2) + e1);
img = uint8(ee);

% plotting original image in first subplot
subplot(2, 5, 1);
imshow(c0);
title('Original Image');

% plotting recombined image in second subplot
subplot(2,5,3);
imshow(uint8(ee));
title('Encrypted Image');
%imwrite(ee,'encrypted.png','BitDepth',16);

end
