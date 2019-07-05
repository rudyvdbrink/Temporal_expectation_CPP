clear
close all
clc

%add functions
%in addition to these functions you'll need EEGLAB
homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load the data

%The variable CPP contains the subject-level data, and is of size 21
%(participants) by 16 (conditions) by time. The conditions are as follows:

%1) Response-locked, short interval, validly cued, easy
%2) Response-locked, short interval, validly cued, difficult
%3) Response-locked, short interval, invalidly cued, easy
%4) Response-locked, short interval, invalidly cued, difficult
%5) Response-locked, long interval, validly cued, easy
%6) Response-locked, long interval, validly cued, difficult
%7) Response-locked, long interval, invalidly cued, easy
%8) Response-locked, long interval, invalidly cued, difficult
%9) Stimulus-locked, short interval, validly cued, easy
%10) Stimulus-locked, short interval, validly cued, difficult
%11) Stimulus-locked, short interval, invalidly cued, easy
%12) Stimulus-locked, short interval, invalidly cued, difficult
%13) Stimulus-locked, long interval, validly cued, easy
%14) Stimulus-locked, long interval, validly cued, difficult
%15) Stimulus-locked, long interval, invalidly cued, easy
%16) Stimulus-locked, long interval, invalidly cued, difficult


%The variables rtime and stime keep track of time relative to response and
%relative to stimulus onset, respectively.
%The variable cpp_chans contains the CPP channels, and the variable
%chanlocs contains location information for all EEG channels. 
%Topo_cpp contains values for each channel at response onset, to plot the
%topographical distribution of the data
%RTs contains the response time per subject, condition (see above, 
%condition 1 through 8), and RT bin 
%Plotcolors contains a matrix with color values for plotting 

load data.mat

%% options for statistics

%number of iterations for permutation testing
npermutes = 10000;

%% Stimulus locked CPP

figure

%plot CPP (stimulus locked)
subplot(2,2,1)
hold on
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-200 800],[0 0],'k--','linewidth',2) 

shadedErrorBar(stime, squeeze(mean(mean(CPP(:,9:end,:)))),squeeze(std(mean(CPP(:,9:end,:),2)))./sqrt(size(CPP,1)),'k');
xlim([-200 800])
ylim([-10 30])
xlabel('Peri-stimulus time (ms)','fontsize',18)
ylabel('Amplitude (\muV/m^2)')
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
box off

%compare each sample to zero across participants with permutation testing
[~, p] = permtestn(squeeze(mean(CPP(:,9:end,:),2)),0,npermutes);
h = fdr(p,0.05); %FDR correct
plot(stime(logical(h)),ones(sum(h),1)*-5,'k.')

%% Response locked CPP

%plot CPP (response locked)
subplot(2,4,3)
hold on
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-400 100],[0 0],'k--','linewidth',2) 

shadedErrorBar(rtime, squeeze(mean(mean(CPP(:,1:8,:)))),squeeze(std(mean(CPP(:,1:8,:),2)))./sqrt(size(CPP,1)),'k');
xlim([-400 100])
ylim([-10 30])
xlabel('Peri-response time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
box off

%compare each sample to zero across participants with permutation testing
[~, p] = permtestn(squeeze(mean(CPP(:,1:8,:),2)),0,npermutes);
h = fdr(p,0.05); %FDR correct
plot(rtime(logical(h)),ones(sum(h),1)*-5,'k.')

%% Topographical plot

subplot(2,4,4) %make a sub pannel in which to plot
topoplot(topo_cpp,chanlocs,'style','map','electrodes','off'); %make the topographical plot (this is an EEGLAB function)
set(gca,'clim',[-30 30]) %set the color limit
title(num2str('Respnse onset')) %make a title that shows the time point that's plotted

%% Plot the CPP, binned by response time
   
%stimulus locked
subplot(2,2,3)
hold on
xlabel('Peri-stimulus time (ms)','fontsize',18)
ylabel('Amplitude (\muV/m^2)')
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
box off
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-200 800],[0 0],'k--','linewidth',2) 

for bini = 1:3
    plot([squeeze(mean(mean(RTs(:,:,bini)))) squeeze(mean(mean(RTs(:,:,bini))))]*1000,[-10 30],'color',plotcolors(bini,:),'linestyle','--')
    plot(stime, squeeze(mean(mean(CPP_RT(:,9:end,:,bini),1),2)),'color',plotcolors(bini,:),'linewidth',3)    
end
xlim([-200 800])
ylim([-10 30])

%response locked
subplot(2,4,7)
hold on
xlabel('Peri-response time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
box off
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-400 100],[0 0],'k--','linewidth',2) 

for bini = 1:3
    plot(rtime, squeeze(mean(mean(CPP_RT(:,1:8,:,bini),1),2)),'color',plotcolors(bini,:),'linewidth',3)    
end
xlim([-400 100])
ylim([-10 30])

%% box plot of RT

%boxplot of the RTs
subplot(2,4,8)
boxplot(squeeze(mean(RTs,2)),'color',plotcolors)
set(gca,'tickdir','out','xtick',1:3,'xticklabel',{'fast','medium','slow'},'fontsize',18)
box off
ylabel('Response time (s)')

set(gcf,'color','w')


