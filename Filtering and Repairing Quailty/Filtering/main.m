%% 1 'girl_ht.tif'

clear all; close all; clc;
% loading the image
origImage = im2double(imread('girl_ht.tif'));
figure(1); 
imshow(origImage);
set(gcf,'Name','Original image');
% FFT
[M, N] = size(origImage);
P = 2*M-1;
Q = 2*N-1;
F = fftshift(fft2(origImage, P, Q)); 
figure(2); % log spectre
imshow(log(1+abs(F)),[]);
set(gcf,'Name','Original');

% Low pass filtering
Hlp=lpfilter('gaussian', P, Q, 100); 
Hlp=fftshift(Hlp);
Flp = F.*Hlp;
figure(3); % log spectre after filtering
imshow(log(1+abs(Flp)),[]);
set(gcf,'Name','After LP filtering');
% image after LP filtering
g = ifft2(ifftshift(Flp)); 
imageLP = g(1:M, 1:N); 
figure(4); 
imshow(imageLP, []);
% filtering with cnotch filter
C = [2480 908; 2480 1054; 2178 1054; 2178 1200; 2178 1346];
Hcn = cnotch('gaussian', 'reject', Q, P, C, 30);
Hcn = Hcn';
figure(5); imshow(log(1 + abs(fftshift(Hcn))),[]);
Fcn = fftshift(Hcn).*Flp;
figure(6); imshow(log(1 + abs(Fcn)),[]);
% image after cnotch filtering
g = ifft2(ifftshift(Fcn));
imageCN = g(1:M, 1:N); 
figure(7); 
imshow(imageCN, []); 
set(gcf,'Name','After cnotch filtering');
% upisivanje u fajlove 

%% 2 'lena_noise.tif'

clear all; close all; clc;
% finding true variance of noise
lena_noise = im2double(imread('lena_noise.tif'));
lena = im2double(imread('lena.tif'));
noise = lena_noise - lena;
real_var = var(noise(:));
figure(1)
imshow(noise);
set(gcf,'Name', 'Noise');
% estimation of noise using local averegein

Haverage = fspecial('average', [9 9]);
mean = imfilter(lena_noise, Haverage, 'replicate');
meanSQR = imfilter(lena_noise.^2, Haverage, 'replicate');
variance = meanSQR - mean.^2;
variance=reshape(variance,1,numel(variance));

figure(2);
hist(variance,256);
set(gcf,'Name', 'Histogram of variance');
variance
% estimation of the noise using roipoly function (second way)
figure(3);
R = roipoly(lena_noise);
var_roipoly = var(lena_noise(R));

%% 3 'etf_blur.tif'

clear all; close all; clc;
% loading the image and the kernel 
bluredImage=im2double(imread('etf_blur.tif'));
figure(1)
imshow(bluredImage);
set(gcf,'Name','Original image');
kernel = im2double(imread('kernel.tif'));
figure(2);
imshow(kernel);
set(gcf,'Name','Kernel');

% FFT
[M,N]=size(bluredImage);
P=2*M-1;
Q=2*N-1;
F=fftshift(fft2(bluredImage,P,Q));
H=fftshift(fft2(kernel,P,Q));
% Wiener's filter
W = (abs(H).^2)./(abs(H).^2 + 5);
Funblured=(F./H).*W;
% IFFT
f = ifft2(ifftshift(Funblured));
unbluredImage = f(1:M-29, 1:N-29);
figure(3);
imshow(unbluredImage,[]);
set(gcf,'Name','Unblured image');
% Scaling the mean value
meanBlured = mean(bluredImage(:)); % mean value of the distorted image
meanUnblured = mean(unbluredImage(:)); % mean value after filtering
% We want mean value of the image to be preserved
unbluredImage = unbluredImage.*meanBlured./meanUnblured;
figure(4);
imshow(unbluredImage, []);
set(gcf,'Name','Unblured image after mean scaling');

%% 4 Testing function dos_non_local_means()

clear all; close all; clc
original = im2double(imread('lena.tif'));
I=im2double(imread('lena_noise.tif'));
tic
J=dos_non_local_means(I,3,33,0.007,0.05);
toc
figure(1)
imshow(I);
figure(2)
imshow(J);
imwrite(J,'4 zadatak 3 i 33.tif');
%%
noise = J-original;
variance = var(noise(:));
PSNR = 10*log10((max(J(:))-min(J(:)))^2/variance);






