clear all;close all;clc;

directory = '.\clocks'; % full path of folder with pictures
filenames_jpg = dir(fullfile(directory, '*.jpg')); % read all images with jpg extesnsion
filenames_png = dir(fullfile(directory, '*.png')); % read all images with png extension
filenames = [filenames_jpg; filenames_png]; % combine them in one array
if isempty(filenames)
    error('###Wrong directory###');
end
total_images = numel(filenames);    % total number of images
for nc = 1:total_images
    full_name = fullfile(directory, filenames(nc).name);% specify image name with full path and extension       
    clock = imread(full_name);
    [hours, minutes] = extract_time(clock);
    [~, ~, seconds] = extract_time_bonus(clock);
    figure(nc);                                     
    imshow(clock); 
    title([num2str(hours),'h i ',num2str(minutes),'min i ',num2str(seconds),'sec']);
    pause(3);
end
