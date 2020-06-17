%% clear contents and add current folder with subfolders
clear
close all
clc

homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))


%% load the data

% File data.mat contains the following variables:
% cpp: example EEG trace of the CPP on a trial
% time: vector that keeps track of time relative to stimulus onset
% RT: response time for the current trial

load data.mat

%% set fitting options

%see help optimset function for a detailed explanation
options = optimset('MaxIter',5000,'MaxFunEvals',5000,'TolFun',1e-5,'TolX',1e-5);

%% fit a two-part line segment to the CPP

%get indices and data of window for fitting (here, ranging from -200 ms until the RT)
[~,idx(1)]=min(abs(time--200)); %start of fitting window
[~,idx(2)]=min(abs(time -RT )); %end of fitting window
cdata = [time(idx(1):idx(2)); cpp(idx(1):idx(2))']; %data used for fitting (so only time and the part of the CPP that falls within the window)

%Actually fit the data, using bounded nonlinear minimization.
%Here, onset is constrained between stimulus onset and 600 ms, and slope
%can vary between 0 and infinity (so slope cannot be negative). Onset is
%returned in the same units as the time vector, and slope is returned in
%units of the CPP signal per time sample (in this case, microvolts per
%meter square per time sample). In case the estimated value falls outside
%of the bounds, the returned value is the bound itself. 
params_out = fminsearchbnd(@(params) fitCPP(params,cdata),[0.1 0.5],[0 0],[600 inf],options);  % running minimisation routine
onset = params_out(1); %this is estimated CPP onset
slope = params_out(2); %this is estimated CPP slope
fitted_cpp = get_fittedCPP(params_out,cdata(1,:)); %get the fitted line segment

%% plot the result
figure
hold on
plot([0 0],[-10 20],'k--','linewidth',2) %plot time of stimulus onset
plot([-400 800],[0 0],'k--','linewidth',2) %plot a line at baseline
plot(time,cpp,'linewidth',3) %plot the CPP itself
plot(cdata(1,:),fitted_cpp,'r','linewidth',2) %plot the fitted line segment
plot([onset onset],[-10 20],'--', 'color',[1 1 1]*.5) %plot line at onset
plot([onset onset],[0 0],'ro', 'MarkerFaceColor','r','LineWidth',4) %plot red dot at onset
plot([RT RT],[-10 20],'--', 'color',[1 1 1]*.5) %plot line at RT
xlim([-400 800])
set(gca,'fontsize',18,'tickdir','out')
xlabel('Peri-stimulus time (ms)')
ylabel('Amplitude (\muV / m^2)')