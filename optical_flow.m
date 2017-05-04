% =========================================================================
% optical_flow.m
% This m file is part of my final year project 'Moving Objects Detection  
% and Segmentation' using optical flow method.
% Optical flow method estimates the direction and speed of object motion 
% from one image to another or from one video frame to another using either
% the Horn-Schunck or the Lucas-Kanade method.
% We use Computer Vision System Toolbox.
% (C) copyright 2017 by Wen Xu
% created: 5/4/2017
% =========================================================================

hvfr = vision.VideoFileReader('001-cl-01-090.avi', ...
                              'ImageColorSpace', 'Intensity', ...
                              'VideoOutputDataType', 'uint8');
videoFWriter = vision.VideoFileWriter('001-cl-01-090-opticalflow.avi');                          
hidtc = vision.ImageDataTypeConverter; 
hof = vision.OpticalFlow('ReferenceFrameDelay', 1);
hof.OutputValue = 'Horizontal and vertical components in complex form';
hsi = vision.ShapeInserter('Shape','Lines','BorderColor','Custom', 'CustomBorderColor', 255);
hvp = vision.VideoPlayer('Name', 'Motion Vector');
while ~isDone(hvfr)
    frame = step(hvfr);
    im = step(hidtc, frame); % convert the image to 'single' precision
    of = step(hof, im);      % compute optical flow for the video
    lines = videooptflowlines(of, 20); % generate coordinate points 
    if ~isempty(lines)
      out =  step(hsi, im, lines); % draw lines to indicate flow
      step(hvp, out);           % view in video player 
    step(videoFWriter,out);
    end
    
end

release(videoFWriter);
release(hvp);
release(hvfr);