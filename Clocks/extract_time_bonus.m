function [hours, minutes, seconds] = extract_time_bonus(clock)
% odredjivanje sata i minuta pomocu extraxt_time
[hours, minutes] = extract_time(clock);
% odredjivanje sekundare
clock = im2double(rgb2gray(clock));                    
[N, M] = size(clock);
n = floor(3*N/8);
m = floor(3*M/8);
clock_croped = clock(n:N-n, m:M-m);
F = fspecial('Gaussian',[3,3],3);
clock_croped = imfilter(clock_croped,F,'replicate','same');
% stavljamo visok prag da ne bismo detektovali sekundaru
E1 = edge(clock_croped, 'canny',[0.75, 0.76]);
edges_croped1 = zeros(N,M);
edges_croped1(n:N-n, m:M-m) = E1;
% stavljamo nizak prag da bismo detektovali i sekundaru
E2 = edge(clock_croped, 'canny',[0.1, 0.2]); 
edges_croped2 = zeros(N,M);
edges_croped2(n:N-n, m:M-m) = E2;
% oduzimamo sliku sa svim kazaljkama od one na kojoj su samo kazaljke koje
% pokazuju na sate i minute
[H,theta,ro] = hough(edges_croped2 - edges_croped1);
num_of_lines = 1; % hocemo samo jednu liniju (sekunndaru)
peaks = houghpeaks(H, num_of_lines, 'Threshold', 0.2*max(H(:)));
handle_seconds = houghlines(edges_croped2 - edges_croped1, theta, ro, peaks,'FillGap',max(size(H)));
if isempty(handle_seconds)
    seconds = -1;
else
    if (norm(handle_seconds.point1 - [M/2,N/2]) > norm(handle_seconds.point2 - [M/2,N/2]))
    farthest = handle_seconds.point1;
    else
        farthest = handle_seconds.point2;
    end
    % odredjivanje ugla u odnosu na vertikalnu pravu koja prolazi kroz 6h i
    % 12h
    seconds_angle = theta_to_angle(handle_seconds.theta, farthest,N,M);
    seconds = round(seconds_angle/6); 
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Lokalna Funkcija : theta_to_angle
%
function angle = theta_to_angle(theta, farthest,N,M)
%
% Konvertuje ugao theta u ugao koji se meri u odnosu na vertikalnu osu koja
% prolazi kroz 6h i 12h (clockwise)
%
if (theta >= 0) % ili je 1 ili 3 kvadrant
    if(norm(farthest - [M,1]) < norm([N/2,M/2]-[1,M])) % 1. kvadrant
        angle = theta;
    else % 3. kvadrant
        angle = 180 + theta;
    end
else
    if(norm(farthest - [1,1]) < norm([N/2,M/2]-[1,1])) % 2. kvadrant
        angle = 360 + theta;
    else % 4. kvadrant
        angle = 180 + theta;
    end
end
end