function [hours, minutes] = extract_time(clock)
%
%
clock = im2double(rgb2gray(clock)); 
% uzimamo samo centralni deo slike dimenzija (N/4 x M/4)
[N, M] = size(clock);
n = floor(3*N/8);
m = floor(3*M/8);
clock_croped = clock(n:N-n, m:M-m);
% filtriranje slike Gausovim filtrom
F = fspecial('Gaussian', [3,3], 3);
clock_croped = imfilter(clock_croped, F, 'replicate','same');
% izdvajanje ivica na isecenoj slici
% uzimamo visoke pragove da bismo isfiltrirali sekundaru 
E1 = edge(clock_croped, 'canny',[0.75, 0.76]);
edges_croped = zeros(N,M);
edges_croped(n:N-n, m:M-m) = E1;
% primenjujemo Hafovu transformaciju na isecenoj slici da bismo nasli ugao kazaljki
[H,theta,ro] = hough(edges_croped);
num_of_lines = 2; % hocemo da nadjemo tacno 2 linije (FillGap nam to obezbedjuje)
peaks = houghpeaks(H, num_of_lines, 'Threshold', 0.2*max(H(:)));
handles_croped = houghlines(edges_croped, theta, ro, peaks, 'FillGap', max(size(H)));
% izdvajanje ivica na celoj slici
clock = imfilter(clock,F,'replicate','same'); % filtriranje istim Gausovim filtrom
E2 = edge(clock, 'canny',[0.5, 0.6]); % spustamo malo prag (nije bitno sad da li cemo odbaciti sekundaru)
% primenjujemo Hafovu transformaciju na celoj slici 
% ideja je da nadjemo dosta linija, pa da ostavimo samo one ciji se ugao
% poklapa sa uglom na isecenoj slici
[H2,theta2,ro2] = hough(E2);
num_of_lines = 90;
peaks2 = houghpeaks(H2, num_of_lines, 'Threshold', 0.2*max(H2(:)));
handles = houghlines(E2, theta2, ro2, peaks2, 'FillGap', 9);
% poredimo uglove na isecenoj i na celoj slici 
handles_matched = find_matched_lines(handles_croped, handles);
% ako imamo vise istih linija, zadrzavamo samo jednu
handles_matched = delete_same_lines(handles_matched);
% ostavljamo samo one linije cija se bar jedna tacka nalazi blizu centra
handles_centered = lines_in_area(handles_matched,N,M,n,m);
% duzu liniju proglasavamo za kazaljku koja pokazuje na minute, a kracu
% za kazaljku koja pokazuje na sate
if(length(handles_centered)>2)
    error('Algorithm detected more than 2 handles ###SOMETHING IS WRONG###');
end
if(length(handles_centered) == 1) % ako se kazaljke poklapaju
    hours_handle = handles_centered;
    minutes_handle = handles_centered;
else
    length1 = norm(handles_centered(1).point1-handles_centered(1).point2);
    length2 = norm(handles_centered(2).point1-handles_centered(2).point2);
    if(length1 < length2) % ako je prva kazaljka kraca
        hours_handle = handles_centered(1);
        minutes_handle = handles_centered(2);
    else % ako je prva kazaljka duza
        hours_handle = handles_centered(2);
        minutes_handle = handles_centered(1);
    end
end

hours_and_minutes = [hours_handle, minutes_handle];
farthest = zeros(2,length(hours_handle.point1));
angle = zeros(2,1);
for i = 1:2
    % trazenje tacke dalje od centra da bismo odredili smer kazaljke
    if (norm(hours_and_minutes(i).point1 - [M/2,N/2]) > norm(hours_and_minutes(i).point2 - [M/2,N/2]))
        farthest(i,:) = hours_and_minutes(i).point1;
    else
        farthest(i,:) = hours_and_minutes(i).point2;
    end
    % odredjivanje ugla u odnosu na vertikalnu osu koja prolazi kroz 6h i
    % 12h (clockwise)
    angle(i) = theta_to_angle(hours_and_minutes(i).theta, farthest(i,:),N,M);
end
hours_angle = angle(1);
minutes_angle = angle(2);
hours = floor(hours_angle/30);
minutes = round(minutes_angle/6);  
if hours == 0
    hours = 12;
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Lokalna Funkcija : find_matched_lines
%
function lines_matched = find_matched_lines(lines1, lines2)
%
% Ako su linije jednake (sa nekom tolerancijom) smestaju se u izlaz
%
lines_matched = [];
for i = 1:length(lines1)
    for j = 1:length(lines2)
        if(abs(lines2(j).theta - lines1(i).theta) < 2 && abs(lines2(j).rho - lines1(i).rho) < 10)
            lines_matched = [lines_matched, lines2(j)];
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%n%%%%%%%%%%%%%%
%
%   Lokalna Funkcija : delete_same_lines
%
function not_deleted = delete_same_lines(lines)
%
%Od svih linija sa istim vrednostima tacke1 i tacke2 ostavljamo samo jednu
%
len = length(lines);
i=1;
j=1;
while i < len
    j = i+1;
    while j < len
        if(lines(i).point1 == lines(j).point1 &...
           lines(i).point2 == lines(j).point2)
            lines(j) = [];
            len = len-1;
        else
            j = j+1;
        end
    end
    i = i+1;
end
not_deleted = lines;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Lokalna Funkcija : lines_in_area
%
function handles_centered = lines_in_area(lines,N,M,n,m)
%
% Ako su linije jednake (sa nekom tolerancijom) smestaju se u izlaz
%
handles_centered = [];
for i = 1:length(lines)
    if (lines(i).point1 > [m,n] & lines(i).point1 < [M-m,N-n] |...
        lines(i).point2 > [m,n] & lines(i).point2 < [M-m,N-n])
        handles_centered = [handles_centered, lines(i)];
    end
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
