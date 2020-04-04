function [blue, red] = extract_dice_score(dice)
%extract_dice_score function takes an image of blue and red dices and
%returns the sum of the numbers on blue dices and on red dices.
% 

dice_hsv = rgb2hsv(dice);
% Odredjivanje ukupnog broja segmenata sa SVIH kocki koristeci saturaciju
saturation = dice_hsv(:,:,2);
T1 = 0.5;
S1 = saturation > T1;
% otvaranje
s1 = strel('disk',4);
S2 = imopen(S1,s1);
% erozija
s2 = strel('disk',1,4);
S3 = imerode(S2,s2);
% labeliranje svih segmenata
L_all = bwlabel(S3,8);
% odredjivanje broja svih segmenata
all = max(L_all(:));

% Oredjivanje broja CRVENIH segmenata koristeci hue
hue = dice_hsv(:,:,1);
H1 = hue > 0.93;
% otvaranje (koristimo iste strukturne elemente kao malopre)
H2 = imopen(H1,s1);
% erozija
H3 = imerode(H2,s2);
% labeliranje crvenih segmenata
L_red = bwlabel(H3,8);
% odredjivanje broja crvenih segmenata
red = max(L_red(:));

% Odredjivanje broja PLAVIH segmenata
blue = all - red;
end