function [dices_blue, dices_red] = extract_dice_score_bonus(dice)
%extract_dice_score_bonus function takes an image of blue and red dices and
%returns the sum of the numbers on each dice.
%


dice_hsv = rgb2hsv(dice);
% Izdvajanje i CRVENIH i PLAVIH segmenata sa SVIH kocki koristeci saturaciju
saturation = dice_hsv(:,:,2);
T1 = 0.5;
S1 = saturation > T1;
% otvaranje
s1 = strel('disk',4);
S2 = imopen(S1,s1);
% erozija
s2 = strel('disk',1,4);
S3 = imerode(S2,s2);

% Izdvajanje CRVENIH segmenata koristeci hue
hue = dice_hsv(:,:,1);
H1 = hue > 0.93;
% otvaranje (koristimo iste strukturne elemente kao malopre)
H2 = imopen(H1,s1);
% erozija
H3 = imerode(H2,s2);

% CENTROIDE ZA SVE KOCKE
centroids_all = centroids_of_segments(S3);

% CENTROIDE ZA CRVENE KOCKE
centroids_red = centroids_of_segments(H3);

% ODREDJIVANJE SUME BROJEVA NA SVIM KOCKAMA POJEDINACNO
dices_all = count_centroids_of_same_class(centroids_all);

% ODREDJIVANJE SUME BROJEVA NA CRVENIM KOCKAMA POJEDINACNO
dices_red = count_centroids_of_same_class(centroids_red);

% ODREDJIVANJE SUME BROJEVA NA PLAVIM KOCKAMA POJEDINACNO
are_red = ismember(dices_all, dices_red); 
dices_blue = dices_all(~are_red);

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : centroids_of_segemnts
%
function centroids = centroids_of_segments(segmented_image)
% function centroids_of_segments returns centroids of segments in
% segmented_image. If centroids are close it puts them in the same class.
% OUTPUT:
%  size(centroids) = (numberOFsegments, 3) - first 2 cloumns are centroid
%  coordinates and the 3rd column is class which centroids belongs to.
%


stats = regionprops(segmented_image);
if isempty(stats)
    centroids = [];
else
    centroids = zeros(length(stats),3); % incijalizacija matrice
    % Svakoj centroidi je dodeljena razlicita kocka (1..length(stats))
    centroids(:,3) = 1:length(stats); 
    for i = 1:length(stats)
        centroids(i,1:2) = round(stats(i).Centroid);
    end
    % iteriramo kroz sve kocke i ako su centroide blizu svrstavamo ih u istu
    % kocku
    for i = 1:length(stats)-1
        for j = i+1:length(stats)
            if(norm(centroids(i,1:2)-centroids(j,1:2))) < 35 % ako su centroide blizu
                centroids(j,3) = centroids(i,3);
            end
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : count_centroids_of_same_class
%
function count = count_centroids_of_same_class(centroids)
% function count_centroids_of_same_class returns the count of centroids
% that belong to the same class
%
count = [];
for i = 1:size(centroids,1)
    number = sum(centroids(:,3)==i);
    if number~=0
        count = [count, number];
    end
end
end
end
