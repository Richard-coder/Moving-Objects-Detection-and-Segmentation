% =========================================================================
% simple_gaussian.m
% This m file is part of my final year project 'Moving Objects Detection  
% and Segmentation' using simple gaussian method.
% Simple gaussian method is actually a background subtraction method that
% chooses the temporal mean of each pixel as background and detects the 
% foreground where its pixel intensity exceeds the range of mean-k*standard
% deviation to mean+k*standard deviation.k=3 is a common choose.This method
% lies on the assumption that if there is no moving object, the noise
% should follow gaussian distribution.
% (C) copyright 2017 by Wen Xu
% created: 5/4/2017
% =========================================================================

clear all;close all;clc;

Max_Intensity = 255; % 8-bit images
k = 2.5; %set the value of k accordingly by yourself
alpha = 0.05; %learning rate
FirstNFrames = 50;
obj = VideoReader('001-cl-01-090.avi');
video = read(obj);

video_height = size(video, 1); %height of each frame
video_width = size(video, 2); %width of each frame
video_channel = size(video, 3); %number of channels
video_frame = size(video, 4); %number of frames
video_out = video;

Th = ones(video_height, video_width)*k; % Threshold matrix
vid(1:video_frame)= struct('cdata', zeros(video_height, video_width, 3,...
    'uint8'), 'colormap', []); 

% Create mean and variance matrices for each channel
ch_Means = cell(1, video_channel);
ch_Variances = cell(1, video_channel);
ch_Thresholds = cell(1, video_channel);


% Evaluate initial(first N frames) means and variances for each channel
for c=1:video_channel
    ch_Means{c} = zeros(video_height, video_width);
    ch_Variances{c} = zeros(video_height, video_width);
    for h=1:video_height
        for w=1:video_width
            ch_Means{c}(h,w) = mean(single(video(h,w,c,1:FirstNFrames)));
            ch_Variances{c}(h,w) = var(single(video(h,w,c,1:FirstNFrames)));
        end
    end
end

%  Update means and variances for each channel from FirstNFrames to end
for f=FirstNFrames+1:video_frame
    for c=1:video_channel
        ch_Means{c} = alpha * single(video(:,:,c,f)) + (1-alpha) * ch_Means{c};
        ch_Variances{c} = alpha * power(single(video(:,:,c,f)) -ch_Means{c}...
            , 2)+ (1-alpha) * ch_Variances{c};
    end
end
%get thresholds according to variances
for c=1:video_channel
    ch_Thresholds{c} = k * sqrt(ch_Variances{c});
end
% conduct background subtraction
for f=1:video_frame
    for c=1:video_channel
        video_out(:, :, c, f) = ...
            uint8((abs(single(video(:, :, c, f)) - ch_Means{c}) > ...
            ch_Thresholds{c}) * Max_Intensity);
    end
    vid(f).cdata = video_out(:, :, :, f);
end

hf = figure;
set(hf, 'position', [0 300 video_width video_height]);
movie(hf, vid, 1, obj.FrameRate);

% save results to a new .avi file
video_name = sprintf('001-cl-01-090-simplegaussian-k%s.avi',num2str(k));
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
