% =========================================================================
% frame_difference.m
% This m file is part of my final year project 'Moving Objects Detection  
% and Segmentation' using frame difference method.
% Frame difference method is about doing differential operation to every 
% two adjacent images of a sequence of video images to obtain moving
% objects contour.
% (C) copyright 2017 by Wen Xu
% created: 5/4/2017
% =========================================================================

clear all;close all;clc;

Max_Intensity = 255; % 8-bit images
Threshold = 50; %set the value of threshold accordingly by yourself

obj = VideoReader('001-cl-01-090.avi');
video = read(obj);

video_height = size(video, 1); %height of each frame
video_width = size(video, 2); %width of each frame
video_channel = size(video, 3); % number of channels
video_frame = size(video, 4); %number of frames
video_out = video;

Th = ones(video_height, video_width)*Threshold; % Threshold matrix
vid(1:video_frame)= struct('cdata', zeros(video_height, video_width, 3,...
    'uint8'), 'colormap', []); 

for f=2:video_frame
    for c=1:video_channel
        video_out(:, :, c, f) = ...
            uint8((abs(video(:, :, c, f) - video(:, :, c, f-1)) > Th) * ...
        Max_Intensity);
    end
    vid(f).cdata = video_out(:, :, :, f);
end

hf = figure;
set(hf, 'position', [400 400 video_width video_height]);
movie(hf, vid, 1, obj.FrameRate);

% save results to a new .avi file
video_name = sprintf('001-cl-01-090-framedifference-threshold%d.avi',Threshold);
if(exist('videoName','file'))  
    delete videoName.avi  
end  
avi_obj=VideoWriter(video_name); 
avi_obj.FrameRate=obj.FrameRate;
open(avi_obj);%Open file for writing video data  
for i=2:video_frame    
    writeVideo(avi_obj,vid(i).cdata);  
end  
close(avi_obj);%Close file  
