function J = canny_edge_detection(I, sigma, Tl, Th)
%canny_edge_detection function uses Canny's algorithm to detect edges on an
%image
% Input image I is type double in range of [0,1].
% Parameter sigma is the standard deviation of the Gaussian filter used in
% the DRoG operator. 
% Tl and Th are the absolut values of the low and high
% thresholds used to distinguish weak and strong edges.
% Output image J is binary (0,1), and it only contains edges. 
% 
% J = canny_edge_detection(I, sigma) uses the default values for Tl = 0.02,
% and for Th = 0.5.
% J = canny_edge_detection(I) uses the default values for sigma = sqrt(2),
% Tl = 0.02, and for Th = 0.5.
%
% 
%See also edge

% --- Argument verification --- %
if (nargin < 1) || (nargin>4) 
    error('Error: Number of parameters sent to the function ''canny_edge_detection'' exceeds expected range');
elseif nargin == 3 
    error('Error: Function ''canny_edge_detection'' recieved only 1 threshold');
elseif nargin == 2
    Tl = 0.2;
    Th = 0.4*Tl;
elseif nargin == 1
    Tl = 0.2;
    Th = 0.4*Tl;
    sigma = sqrt(2);
end
% Checking a pixel value format of parameter I
if (~isa(I,'double')) 
    error('Error: Input argument I in ''canny_edge_detection'' function has to be a type double');
end
% Checking a if value of parameter limit exceeds demanded range
if (min(I(:))<0 || max(I(:))>1) 
    error('Error: Input argument I in ''canny_edge_detection'' function has to be in range of [0,1]');
end

% 1. i 2. KORAK: Filtriranje ulazne slike Gausovom funkcijom i odredjivanje
% horizontalnih i vertikalnih gradijenata
[I_dx, I_dy] = DRoG(I, sigma);

% 3. KORAK: Odredjivanje magnitude i ugla gradijenta
[Id_magnitude, Id_angle] = magnitude_and_angle(I_dx, I_dy);

% 4. KORAK: Kvantizacija gradijenta
Id_angle = gradient_quantization(Id_angle);

% 5. KORAK: Potiskivanje vrednosti gradijenta koji ne predstavljaju
% lokalne maksimume
window_size = 3;
J = non_max_supression(Id_magnitude, Id_angle, window_size);

% 6. KORAK: Odredjivanja mapa jakih i slabih ivica
weak = 50/250;
strong = 1;
[J, ~, ~] = threshold(J, Tl, Th, weak, strong);

% 7. KORAK: Povezivanje slabih ivica sa jakim
window_size = 3;
J = hysteresis(J, window_size, weak, strong);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Lokalna Funkcija : DRoG
%
function [I_dx, I_dy] = DRoG(I, sigma)
% 
% Primenjuje DRoG operator na ulaznu sliku I.
% Gausova funkcija operatora ima standradnu devijaciju sigma,
% a dimenzija prozora je prvi neparan ceo broj veci ili jednak 6*sigma
% 
% OUTPUTS:
%   I_dx: Parcijalni gradijent slike u x pravcu
%   I_dy: Parcijalni gradijent slike u y pravcu

% definisanje dimenzije prozora 
kernel_size = ceil(6*sigma);
if (mod(kernel_size, 2) == 0)
    kernel_size = kernel_size + 1;
end
if kernel_size < 3 % minimalna velicina kernela je 3
    kernel_size = 3;
end
% pravljenje Gausovog filtra 
Gauss_filter  = fspecial('gaussian', kernel_size, sigma);
% numericki gradijent
[Hx, Hy] = gradient(Gauss_filter); 
Hx = Hx/sum(sum(abs(Hx)));
Hy = Hy/sum(sum(abs(Hy)));
% filtriranje (primena operatora)
I_dx = imfilter(I, Hx, 'replicate', 'same');
I_dy = imfilter(I, Hy, 'replicate', 'same'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local function : magnitude_and_angle
%
function [Id_magnitude, Id_angle] = magnitude_and_angle(I_dx, I_dy)
%
%   Funkcija koja racuna magnitudu i ugao gradijenta
%

Id_magnitude = sqrt(I_dx.^2 + I_dy.^2);
Id_angle = atan(I_dy./I_dx); 
Id_angle(Id_magnitude == 0) = 0; 
Id_angle = Id_angle*360/2/pi; % konverzija iz radijana u stepene
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local function : gradient_quantization
%
function Id_angle = gradient_quantization(Id_angle)
%
%   Kvantizuje gradijent na 4 nivoa: -45, 0, 45, 90
%

Id_angle(Id_angle > -67.5 & Id_angle < -22.5) = -45;
Id_angle(Id_angle >= -22.5 & Id_angle <=22.5) = 0;
Id_angle(Id_angle > 22.5 & Id_angle < 67.5) = 45;
Id_angle(Id_angle >= 67.5 & Id_angle <= 90) = 90;
Id_angle(Id_angle >= -90 & Id_angle <= -67.5) = 90;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local function: non_max_supression
%
function J = non_max_supression(Id_magnitude,Id_angle, window_size)
%
%   Potiskivanje vrednosti gradijenata koji ne predstavljaju lokalne maksimume
%

[N, M] = size(Id_magnitude);
half = (window_size-1)/2; % pola dimenzije prozora
J = Id_magnitude; % incijalizacija izlazne slike 
Id_magnitude = padarray(Id_magnitude, [half, half], 'replicate');

for i = 1+half:N+half
    for j = 1+half:M+half
        switch Id_angle(i-half,j-half)
            case 45
                window = Id_magnitude(i-half:i+half,j-half:j+half).*[1 0 0;...
                                                                     0 1 0;...
                                                                     0 0 1];
            case 90
                window = Id_magnitude(i-half:i+half,j-half:j+half).*[0 1 0;...
                                                                     0 1 0;...
                                                                     0 1 0];
            case -45
                window = Id_magnitude(i-half:i+half,j-half:j+half).*[0 0 1;...
                                                                     0 1 0;...
                                                                     1 0 0];
            case 0
                window = Id_magnitude(i-half:i+half,j-half:j+half).*[0 0 0;...
                                                                     1 1 1;...
                                                                     0 0 0];
        end

        max_ind = find(window == max(window(:))); 
        if(max_ind ~= (window_size^2-1)/2+1) % ako pixel sa max vrednoscu nije u sredini prozora
                J(i-half,j-half) = 0; % ne sme da bude inplace
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local function: threshold
%
function [J, Weak_edges, Strong_edges] = threshold(I, Tl, Th, weak, strong)
%
%   Odredjivanje mapa jakih i slabih ivica na osnovu pragova
%
%   INPUTS:
%       J: magnituda gradijenta
%       Tl: apsolutna vrednost donjeg praga
%       Th: apsolutna vrednost gornjeg praga
%       weak: intenzitet piksela koji ce biti dodeljen slabim ivicama
%       strong: intenzitet piksela koji ce biti dodeljen jakim ivicama
%   OUTPUTS:
%       J: mapa ivica koja sadrzi i jake i slabe ivice
%       Weak_edges: mapa ivica koja sadrzi samo slabe ivice
%       Strong_edges: mapa ivica koja sadrzi samo jake ivice
%
J = I;
J(J >= Th) = strong;
J(J > Tl & J < Th) = weak;
J(J <= Tl) = 0;
Weak_edges = J;
Weak_edges(J == weak) = 1;
Weak_edges(J == strong) = 0;
Strong_edges = J;
Strong_edges(J == weak) = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local function: hysteresis
%
function J = hysteresis(I, window_size, weak, strong)
%
%   Svi pikseli koji u svom susedstvu imaju bar jednu jaku ivicu
%   proglasavaju se ivicnim pikselom
%
J = I; % incijalizacija izlazne matrice
[N, M] = size(J);
half = (window_size-1)/2;
changed = true;
while changed 
    changed = false;
    Edges = padarray(J, [half, half], 'replicate'); % posle prolaska kroz sve piksele update-uj ivice
    for i = 1+half:N+half % u ove dve petlje prodji kroz sve piksele jednom
        for j = 1+half:M+half
            if Edges(i, j) == weak % ako je ivica slaba
                window = Edges(i-half:i+half, j-half:j+half); % okolina oko slabe ivice
                if ~isempty(find(window == strong)) % ako u okolini ima bar jedan 'jak' piksel
                    J(i-half, j-half) = strong; % ne sme biti inplace
                    changed = true;
                end
            end          
        end
    end
end
J(J == weak) = 0; % ivice koju su ostale slabe stavi na 0
end

    
