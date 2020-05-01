clear all;close all;clc;
% testing 'lena.tif' image
lena = imread('lena.tif');
figure(1);
imshow(lena);

I = double(lena)/255;
J = canny_edge_detection(I, 1, 0.1, 0.2);
figure(2)
imshow(J);
% testing 'house.tif' image
house = imread('house.tif');
figure(3);
imshow(house);
I = double(house)/255;
J = canny_edge_detection(I, 1, 0.01, 0.05); 
figure(4);
imshow(J);
% testing 'camerman.tif' image
camerman = imread('camerman.tif');
figure(5);
imshow(camerman);
I = double(camerman)/255;
J = canny_edge_detection(I, 1.5, 0.06, 0.12); 
figure(6);
imshow(J);
% testing 'van.tif' image
van = imread('van.tif');
figure(7);
imshow(van);
I = double(van)/255;
J = canny_edge_detection(I, 2, 0.01, 0.065);
figure(8);
imshow(J);



