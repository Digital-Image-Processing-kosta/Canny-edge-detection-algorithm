clear all;close all;clc;

directory = '.\dices'; % full path of folder with pictures
filenames = dir(fullfile(directory, '*.jpg')); % read all images with jpg extesnsion
if isempty(filenames)
    error('###Wrong directory###');
end
total_images = numel(filenames);    % total number of images
dices_score = zeros(total_images,2);
for i = 1:total_images
    full_name = fullfile(directory, filenames(i).name); % specify image name with full path and extension       
    dice = imread(full_name);
    [blue, red] = extract_dice_score(dice);
    dices_score(i,:) = [blue, red];
    figure(i)
    imshow(dice);
    title(['Blue: ',num2str(blue),'   Red: ',num2str(red)]);
    pause(3);
    [dices_blue, dices_red] = extract_dice_score_bonus(dice);
    disp(['###KOCKA ',num2str(i),':']);
    disp(['plave: ',num2str(dices_blue)]);
    disp(['crvene: ',num2str(dices_red)]);
end
