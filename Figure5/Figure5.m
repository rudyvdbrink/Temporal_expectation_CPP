%% clear contents
clear
close all
clc

%add functions
homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load data:

%The variable CPP contains the trial-average CPP per participant, and is of
%size 21 (participants) by 667 (time points).
%The variable t tracks time across the CPP.
%
%The variable M contains subject-wise indices of CPP peaks (first column),
%and peak amplitudes (second column). 
%
%The variable modeldata contains 21 rows (participants) by 6 columns:
%         1: non-decision time, valid 
%         2: non-decision time, invalid 
%         3: drift rate, valid, easy
%         4: drift rate, valid, difficult
%         5: drift rate, invalid, easy
%         6: drift rate, invalid, difficult
%
%The variables onsets and slopes are vectors (length of the number of
%participants) and contain the metrics of interest (computed from
%amplitude-normalized CPP).
%
%The variable mRT contains condition-average RTs of the participants.
%
%Peaktime contains the subject-wise CPP peak latencies.

load data.mat

%% Fit and plot CPP per participant

options = optimset('MaxIter',5000,'MaxFunEvals',5000,'TolFun',1e-5,'TolX',1e-5);  %  set Simplex options to perform rigorous search
times_s = [-400 900]; %time range to plot
c       = linspace(0,1,21); %colors for individual subject

for subi = 1:size(CPP,1)
    
    subplot(3,7,subi)
    hold on
    
    %plot CPP
    plot(t,   CPP(subi,:) , 'color',[c(subi), 0.5 , 1-c(subi)],'LineWidth',4) %plot the CPP of this subject    
    plot([0 0],[-10 50],'k--','linewidth',1) %time zero
    plot([-400 800],[0 0],'k--','linewidth',1) %amplitude zero    
    
    %fit the CPP    
    %get indices and data of window for fitting (here, ranging from -200 ms until the RT)
    [~,idx(1)]= min(abs(t--200)); %start of fitting window
    idx(2)    = M(subi,1); %end of fitting window
    cdata = [t(idx(1):idx(2)); CPP(subi,idx(1):idx(2))]; %data used for fitting (so only time and the part of the CPP that falls within the window)      
    params_out = fminsearchbnd(@(params) fitCPP(params,cdata),[0.1 0.5],[0 0],[600 inf],options);  % running minimisation routine
    onset = params_out(1); %this is estimated CPP onset
    fitted_CPP = get_fittedCPP(params_out,cdata(1,:)); %get the fitted line segment    
    plot(cdata(1,:),fitted_CPP,'r-','linewidth',2) %plot the fitted line segment
    plot([onset onset],[-10 50],'r--') %plot estimated onset
    
    %plot formatting
    xlim([-400 700])
    ylim([-10 50])
    set(gca,'tickdir','out','xtick',[-400 0 700],'XTickLabel',[-400 0 700],'ytick',[0 25 50],'FontSize',12)
    
    if subi < 15
        set(gca,'xtick',[])
    end
    
    if ~any(subi == [1 8 15])
        set(gca,'ytick',[])
    end    
end

%% CPP onsets - Ter

% average across conditions and convert to ms
Ter = squeeze(mean(modeldata(:,1:2),2));
v   = squeeze(mean(modeldata(:,3:6),2));
Ter = Ter*1000;

figure

subplot(1,5,1)
[r, p] = permcorr(onsets',Ter,10000,'right');
plot(onsets,Ter,'wo','MarkerFaceColor','k')
axis square
box off
lsline
ylabel('T_{er} (ms)')
xlabel('CPP onsets latency (ms)')
a = lsline;
a.Color = [0 0 0];
title(['r = ' num2str(r) ', p = ' num2str(p)])
hold on
for subi = 1:size(v,1)
    plot(onsets(subi),Ter(subi), 'o','color', [c(subi), 0.5 , 1-c(subi)], 'markerfacecolor',[c(subi), 0.5 , 1-c(subi)],'LineWidth',3)
end
set(gca,'tickdir','out','fontsize',12,'linewidth',1)

%% CPP slope - v

subplot(1,5,2)
[r, p] = permcorr(slopes',v,10000,'right');
plot(slopes,v,'wo','MarkerFaceColor','k')
axis square
box off
title(['r = ' num2str(r) ', p = ' num2str(p)])
a = lsline;
a.Color = [0 0 0];
ylabel('v (a.u.)')
xlabel('CPP slope (\muV / m^2 / T_s)')
hold on
for subi = 1:size(v,1)
    plot(slopes(subi),v(subi), 'o','color', [c(subi), 0.5 , 1-c(subi)], 'markerfacecolor',[c(subi), 0.5 , 1-c(subi)],'LineWidth',3)
end
set(gca,'tickdir','out','xtick',0.05:0.075:0.2,'ytick',.5:2:4.5,'fontsize',12,'linewidth',1)
ylim([0.5 4.5])
xlim([0.05 0.2])

%% CPP onsets latency - RT

subplot(1,5,3)
plot(onsets,mRT,'ko')
lsline
axis square
box off
set(gca,'tickdir','out')
[r, p] = permcorr(onsets,mRT,100000,'right');
title(['r = ' num2str(r) ', p = ' num2str(p)])
ylabel('RT (ms)')
xlabel('CPP onset latency (ms)')
hold on
for subi = 1:length(onsets)
    plot(onsets(subi),mRT(subi), 'o', 'color',[c(subi), 0.5 , 1-c(subi)],'LineWidth',3,'MarkerFaceColor',[c(subi), 0.5 , 1-c(subi)] )
end
set(gca,'tickdir','out','fontsize',12,'ytick',300:200:700,'linewidth',1) 
ylim([300 700])

%% slope - RT

subplot(1,5,4)
[r, p] = permcorr(slopes,mRT,100000,'left');
plot(slopes,mRT,'ko')
lsline
axis square
box off
set(gca,'tickdir','out')
title(['r = ' num2str(r) ', p = ' num2str(p)])
ylabel('RT (ms)')
xlabel('CPP slope (\muV / m^2 / T_s)')
xlim([0.05 0.2])
hold on
for subi = 1:length(onsets)
    plot(slopes(subi),mRT(subi), 'o', 'color',[c(subi), 0.5 , 1-c(subi)],'LineWidth',3,'MarkerFaceColor',[c(subi), 0.5 , 1-c(subi)] )
end
set(gca,'tickdir','out','xtick',0.05:0.075:2,'ytick',300:200:700,'fontsize',12,'linewidth',1) 
ylim([300 700])

%% CPP peak time - RT

subplot(1,5,5)
[r, p] = permcorr(peaktime',mRT,100000,'right');
plot(peaktime,mRT,'ko')
lsline
axis square
box off
set(gca,'tickdir','out')
title(['r = ' num2str(r) ', p = ' num2str(p)])
xlabel('CPP peak latency (ms)')
ylabel('RT (ms)')
hold on
for subi = 1:length(onsets)
    plot(peaktime(subi),mRT(subi), 'o', 'color',[c(subi), 0.5 , 1-c(subi)],'LineWidth',3,'MarkerFaceColor',[c(subi), 0.5 , 1-c(subi)] )
end
xlim([300 700])
ylim([300 700])
set(gca,'tickdir','out','xtick',300:200:700,'ytick',300:200:700,'fontsize',12,'linewidth',1) 


