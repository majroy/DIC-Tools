%VIC_curvebuilder.m
%   Demonstration script which tabulates frame (load) data and 2D DIC data 
%   as processed by VIC-2D to generate flow stress curves.
%
%   Requires inpoly.m to allow for segmentation.
%   
%   Copyright 2016-2017 M. J. Roy
%   $Revision: 1.1$  $Date: 2017/11/23$
close all
clear all

clc

inputdir=pwd;
files=dir(inputdir);

%bring in load information
loads=csvread('HiSpeedDualGauge3Dnov23rd.csv',1,4);


i=1; %counter for frame number array
for j=1:length(files)
    if length(files(j).name)>3 %make sure that this is actually a file
        if strcmp(files(j).name(end-5:end),'_0.csv') %find all files that end with '_0.csv'
            frameNo(i)=str2num(files(j).name(end-9:end-6)); %store the frame number in each of these files
            i=i+1;
        end
    end
end


i=1;
for j=[1:350:3900] %loop over the entire series or a subseries of frames
    %bring in everything else
    %headers: "x_c",  "y_c",  "u_c",  "v_c",  "x",  "y",  "u",  "v",  "exx",  "eyy",  "exy",  "e1",  "e2",  "gamma",  "e_vonmises",  "sigma"
    [N,TXT,RAW]=xlsread(sprintf('%s\\HiSpeedDualGauge3Dnov23rd-%04d_0.csv',inputdir,frameNo(j)));

    fprintf('reading HiSpeedDualGauge3Dnov23rd-%04d_0.csv\n',frameNo(j))
    %assign local variables to store info from frame
    x_c=N(:,1); y_c=N(:,2); eyy = N(:,10); 
    %get all strain values between boundaries
    testVec=zeros(1,length(x_c));
    %here use inpoly or something similar to index areas that one cares about 
    in=inpoly([x_c y_c],[-2.5 -10; -2.5 10; 2.5 10; 2.5 -10]);
    %take the mean strain of the subset
    currStrain(i)=mean(eyy(in));
    %get true stress based on true strain
    currStress(i)=(loads(j)*1000*(currStrain(i)+1))/(7.5*2);
    i=i+1;

end

%plot stress vs. strain
hFig = figure('Color','w');
plot(currStrain,currStress,'b.');
drawnow

pause;
path=pwd;
je = javax.swing.JEditorPane('text/html', sprintf('<html><img src="file:/%s\\200.gif"/></html>',path));
[hj, hc] =  javacomponent(je,[],hFig);
set(hc, 'pos', [10,10,242,200])
