%% 'disney.png'

clear all;close all;clc;
% loading original image
disney_original=imread('./images/disney.png');
figure(1);
imshow(disney_original);
set(gcf, 'Name', 'Originalna slika');
% converting to HSV and log compressing contrast
disney_hsv=rgb2hsv(disney_original);
figure(2); % histogram
subplot(2,1,1);
bar(imhist(disney_hsv(:,:,3)));
u=disney_hsv(:,:,3);
k=10;
c=1/log(1+k*abs(max(u(:))));
disney_hsv(:,:,3)=c*log(1+k*abs(u));
figure(2); % histogram after log compression
subplot(2,1,2);
bar(imhist(disney_hsv(:,:,3)));
% converting to RGB format
disney_after_logcompr=hsv2rgb(disney_hsv);
figure(3);
imshow(disney_after_logcompr);
set(gcf, 'Name', 'Posle kompresije kontrasta log funkcijom');
figure(4);
imshow(rgb2gray(disney_after_logcompr));
set(gcf, 'Name', 'Siva obradjena slika');
% writing to files
% imwrite(disney_after_logcompr,'disney_logcompr.png');
% imwrite(rgb2gray(disney_after_logcompr),'disney_gray_logcompr.png');
%% 'bristolb.hdr'

clear all;close all;clc;
%loading the original image
bristolb_original=hdrread('./images/bristolb.hdr');
figure(1)
imshow(bristolb_original);
set(gcf, 'Name', 'Originalna slika');
% converting to sRGB
bristolb_sRGB=rgb2srgb(bristolb_original); 
figure(2);
imshow(bristolb_sRGB);
set(gcf, 'Name', 'U sRGB formatu');
% converting to HSV and adaptive equalization of histogram
bristolb_hsv=rgb2hsv(bristolb_sRGB);
figure(3); % ploting the histogram before equalization
subplot(2,1,1);
bar(imhist(bristolb_hsv(:,:,3)));
bristolb_hsv(:,:,3) = adapthisteq(bristolb_hsv(:,:,3), 'ClipLimit', 0.01,'NumTiles', [10 20]);
figure(3); % ploting the histogram after
subplot(2,1,2);
bar(imhist(bristolb_hsv(:,:,3)));
bristolb_after_adapthistHSV=hsv2rgb(bristolb_hsv);
figure(4);
imshow(bristolb_after_adapthistHSV);
set(gcf, 'Name', 'Posle adaptivne ekvalizacije histograma');
figure(5);
imshow(rgb2gray(bristolb_after_adapthistHSV));
set(gcf, 'Name', 'Posle adaptivne ekvalizacije histograma-gray');
% writing to files
% imwrite(bristolb_sRGB,'bristolb_sRGB.png');
% imwrite(bristolb_after_adapthistHSV,'bristolb_adapthisteq.png');
% imwrite(rgb2gray(bristolb_after_adapthistHSV),'bristolb_adapthisteq_gray.png');
%% 'giraff.jpg'

clear all;close all;clc;
giraff_original=imread('./images/giraff.jpg');
figure(1);
imshow(giraff_original);
set(gcf, 'Name', 'Originalna slika');
% ploting the histogram
figure(2);
bar(imhist(giraff_original));
set(gcf, 'Name', 'Histogram originalne slike');
% stretching the contrast with imadjust()
borders_in=stretchlim(double(giraff_original)/255,0.01);
giraff_after_imadjust=imadjust(giraff_original,borders_in,[0 255]/255,0.8);
figure(3);
imshow(giraff_after_imadjust);
set(gcf, 'Name', 'Posle razvlacenja kontrasta');
% histograma after imadjust.
figure(4); 
bar(imhist(giraff_after_imadjust));
set(gcf, 'Name', 'Histogram posle razvlacenja kontrasta');
% sharpening the image
kernel = fspecial('gaussian', [6 6], 2); % defining the space mask
LowPassImage = imfilter(giraff_after_imadjust, kernel, 'replicate'); % bluring the image
HighPassMask = giraff_after_imadjust - LowPassImage; 
giraff_sharpened = uint8(giraff_after_imadjust + HighPassMask);
figure(5); 
imshow(giraff_sharpened);
set(gcf, 'Name', 'Posle izostravanja');
% writing to files
% imwrite(giraff_after_imadjust,'giraffe_imadjust.png');
% imwrite(giraff_sharpened,'giraffe_sharpened.png');
%% 'enigma.png'

clear all;close all;clc;
% loading the original image
enigma_original=imread('./images/enigma.png');
figure(1);
imshow(enigma_original);
set(gcf, 'Name', 'Originalna slika');
% filtering the noise
I=enigma_original;
kernel_size=51;
padding_size=fix(kernel_size/2);
I=padarray(I,[padding_size, padding_size],'replicate');
[N,M]=size(I);
for i=padding_size+1:N-padding_size
    for j=padding_size+1:M-padding_size
        if(I(i,j)==0 || I(i,j)==255)
            window=I(i-padding_size:i+padding_size,j-padding_size:j+padding_size);
            I(i,j)= sum(window(:))/kernel_size^2;
        end
    end
end
enigma_after_filtering=I(padding_size+1:N-padding_size,padding_size+1:M-padding_size);
figure(2);
imshow(enigma_after_filtering);
set(gcf, 'Name', 'Posle usrednjavanja samo onih piksela sa vr 0 i 255');
% median filtering
enigma_after_median_filtering=medfilt2(enigma_original,[7 7]);
figure(3);
imshow(enigma_after_median_filtering);
set(gcf, 'Name', 'Posle filtriranja medijan filtrom');
% writing to files
% imwrite(enigma_after_filtering,'engima_filtered.png');
% imwrite(enigma_after_median_filtering,'engima_median.png');

%% Testing the function dos_clhe()

clear all;close all;clc;
% loading original images
einstein_original=imread('./images/einstein_lc.tif');
figure(1);
imshow(einstein_original);
set(gcf, 'Name', 'einstein originalna slika');
bristolb_orig=hdrread('./images/bristolb.hdr');
% converting to sRGB, then to gray
bristolb_sRGB=rgb2srgb(bristolb_orig);
figure(2);
imshow(bristolb_sRGB);
set(gcf, 'Name', 'bristolb originalna slika');

bristolb_HSV=rgb2hsv(bristolb_sRGB);
Vcomp=bristolb_HSV(:,:,3);
% applying dos_clhe function on einstein
i=3;
for limit=[0, 0.001, 0.01, 0.1, 1]
einstein_histeq=dos_clhe2(double(einstein_original)/255,8,limit);
figure(i);
imshow(einstein_histeq);
title(['limit = ' num2str(limit)]);
i=i+1;
end
% applying dos_clhe function on bristolb
i=8;
for limit=[0, 0.001, 0.01, 0.1, 1]
bristolb_HSV(:,:,3)=dos_clhe2(Vcomp,8,limit);
figure(i);
imshow(hsv2rgb(bristolb_HSV));
title(['limit = ' num2str(limit)]);
i=i+1;
end