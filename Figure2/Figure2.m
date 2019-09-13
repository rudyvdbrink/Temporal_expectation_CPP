clear
close all
clc

%add functions
%in addition to these functions you'll need EEGLAB
homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir)); %folder with supporting functions
addpath(genpath(homedir(1:end-7))); %folder where this script is stored
%% load data

%Modeldata contains the model parameters of the individual participants.
%this variable has N rows (participants) and 9 columns (variables). The
%variables are as follows:
%1) v (drift rate) on catch trials
%2) v (drift rate) on valid easy trials
%3) v (drift rate) on valid difficult trials
%4) v (drift rate) on invalid easy trials
%5) v (drift rate) on invalid difficult trials
%6) Ter (non decision time) on catch trials
%7) Ter (non decision time) on valid trials
%8) Ter (non decision time) on invalid trials
%9) Threshold

%1) Ter (non decision time) on valid trials
%2) Ter (non decision time) on invalid trials
%3) v (drift rate) on valid easy trials
%4) v (drift rate) on valid difficult trials
%5) v (drift rate) on invalid easy trials
%6) v (drift rate) on invalid difficult trials
%7) a (threshold)

%The matrix 'bhvdat' contains the behavioral data, and has N rows 
%(participants) and 18 columns:
%1) RT on short interval, validly cued, easy
%2) RT on short interval, validly cued, difficult
%3) RT on short interval, invalidly cued, easy
%4) RT on short interval, invalidly cued, difficult
%5) RT on long interval, validly cued, easy
%6) RT on long interval, validly cued, difficult
%7) RT on long interval, invalidly cued, easy
%8) RT on long interval, invalidly cued, difficult
%9)  Accuracy on short interval, validly cued, easy
%10) Accuracy on short interval, validly cued, difficult
%11) Accuracy on short interval, invalidly cued, easy
%12) Accuracy on short interval, invalidly cued, difficult
%13) Accuracy on long interval, validly cued, easy
%14) Accuracy on long interval, validly cued, difficult
%15) Accuracy on long interval, invalidly cued, easy
%16) Accuracy on long interval, invalidly cued, difficult
%17) False alarm rate on non-catch trials
%18) False alarm rate on catch trials 

% Each row in the bhvdat matrix is a participant.

load data.mat

%% Simulate behavioral data using the model parameters (this can take a few minutes)


%1) Ter (non decision time) on valid trials
%2) Ter (non decision time) on invalid trials
%3) v (drift rate) on valid easy trials
%4) v (drift rate) on valid difficult trials
%5) v (drift rate) on invalid easy trials
%6) v (drift rate) on invalid difficult trials
%7) a (threshold)

c       = 1.0;
numtr   = 10000;
simdata = zeros(size(modeldata,1),2,2);
for subi = 1:size(modeldata,1)
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,3),'Ter',modeldata(subi,1));
    simdata(subi,1,1) = squeeze(mean(resp(resp(:,2)==1 & resp(:,1) < maxrt,1))); %valid, easy    
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,4),'Ter',modeldata(subi,1));
    simdata(subi,1,2) = squeeze(mean(resp(resp(:,2)==1 & resp(:,1) < maxrt,1))); %valid, difficult    
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,5),'Ter',modeldata(subi,2));
    simdata(subi,2,1) = squeeze(mean(resp(resp(:,2)==1 & resp(:,1) < maxrt,1))); %invalid, easy    
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,6),'Ter',modeldata(subi,2));
    simdata(subi,2,2) = squeeze(mean(resp(resp(:,2)==1 & resp(:,1) < maxrt,1))); %invalid, difficult
end
simdata = simdata * 1000; %scale to ms (instead of seconds)

%% Make scatter plot of model and data

figure
subplot(2,3,3)

plotcolors = parula(4);
r = zeros(4,1);
p = zeros(size(r));
for condi = 1:4    
    plot(squeeze(simdata(:,condi)),bhvdat(:,condi),'o','color',plotcolors(condi,:),'MarkerFaceColor',plotcolors(condi,:))
    hold on
    [r(condi), p(condi)] = corr(squeeze(simdata(:,condi)),bhvdat(:,condi)); %correlate data and model RT    
    disp(['Correlation between model and data for ' conditions{condi} ' trials: r = ' num2str(r(condi)) ', p = ' num2str(p(condi))])
    P = polyfit(squeeze(simdata(:,condi)),bhvdat(:,condi),1);
    y = squeeze(simdata(:,condi)).*P(1) + P(2); %least squares regression line
    plot(squeeze(simdata(:,condi)),y,'-','color',plotcolors(condi,:),'LineWidth',2)        
end

xeb = std(simdata(:,:))./sqrt(size(simdata,1)); %error bar for the model
yeb = std(bhvdat(:,1:4))./sqrt(size(simdata,1));%error bar for the real data
for condi = 1:4
    plot(squeeze(mean(simdata(:,condi))),squeeze(mean(bhvdat(:,condi))),'ko','MarkerFaceColor',plotcolors(condi,:),'markersize',10) %plot mean
    plot([squeeze(mean(simdata(:,condi))) squeeze(mean(simdata(:,condi)))], [squeeze(mean(bhvdat(:,condi)))-yeb(condi) squeeze(mean(bhvdat(:,condi)))+yeb(condi)],'k','LineWidth',2) %plot error bar (for real data)
    plot([squeeze(mean(simdata(:,condi)))-xeb(condi) squeeze(mean(simdata(:,condi)))+xeb(condi)], [squeeze(mean(bhvdat(:,condi))) squeeze(mean(bhvdat(:,condi)))],'k','LineWidth',2) %plot error bar (for model)
end

ylim([300 700])
xlim([300 700])
axis square
set(gca,'tickdir','out','fontsize',18,'linewidth',1)
box off
xlabel('RT model (ms)')
ylabel('RT data (ms)')
  
%% load the posteriors, make histograms, and calculate p-values

alpha = 0.5; %transparancy of the histograms

%load the posterior distributions
tvalid       = dlmread('tvalid.csv'); %non-decision time on valid trials
tinvalid     = dlmread('tinvalid.csv'); %non-decision time on invalid trials
veasyvalid   = dlmread('veasyvalid.csv'); %drift rate on valid easy trials
veasyinvalid = dlmread('veasyinvalid.csv'); %drift rate on invalid easy trials
vhardvalid   = dlmread('vhardvalid.csv'); %drift rate on valid difficult trials
vhardinvalid = dlmread('vhardinvalid.csv'); %drift rate on invalid difficult trials

% plot non-decision time
subplot(2,2,3)
hold on

x  = 0.2:0.001:0.4; %range for histogram

pd = fitdist(tvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x,y,[0 0.8 0],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,1))) mean(squeeze(modeldata(:,1)))], [0 max(y)], '--', 'color', [0 0.8 0],'linewidth',2)
% plot(modeldata(:,7),-0.4,'wo', 'MarkerFaceColor',[0 0.8 0])

pd = fitdist(tinvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x,y,[0 0.4 0],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,2))) mean(squeeze(modeldata(:,2)))], [0 max(y)], '--', 'color', [0 0.4 0],'linewidth',2)
% plot(modeldata(:,8),-0.6,'wo', 'MarkerFaceColor',[0 0.4 0])

xlim([0.23 0.33])
title('T_{er}')
set(gca,'tickdir','out','fontsize',18,'linewidth',1)
xlabel('Parameter estimate (a.u.)')
ylabel('Frequency of occurance (%)')

%validity effect on non-decision time
p = sum(tvalid > tinvalid) / length(tvalid);
text(0.275, 7, ['p = ' num2str(round(p*1000)/1000)],'FontSize',15)

%plot drift rate
subplot(2,2,4)
hold on

x  = 1:0.001:5; %range for histogram

pd = fitdist(veasyvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x,y,[0 0 0.8],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,3))) mean(squeeze(modeldata(:,3)))], [0 max(y)], '--', 'color', [0 0 0.8],'linewidth',2)

pd = fitdist(vhardvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x,y,[0.8 0 0],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,4))) mean(squeeze(modeldata(:,4)))], [0 max(y)], '--', 'color', [0.8 0 0],'linewidth',2)

pd = fitdist(veasyinvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x,y,[0 0 0.4],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,5))) mean(squeeze(modeldata(:,5)))], [0 max(y)], '--', 'color', [0 0 0.4],'linewidth',2)

pd = fitdist(vhardinvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x,y,[0.4 0 0],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,6))) mean(squeeze(modeldata(:,6)))], [0 max(y)], '--', 'color', [0.4 0 0],'linewidth',2)

xlim([1.5 3.5])
ylim([0 0.4])
set(gca,'tickdir','out','fontsize',18,'linewidth',1)
title('v')
xlabel('Parameter estimate (a.u.)')
ylabel('Frequency of occurance (%)')


%validity effect on drift rate, collapsed across difficulty conditions (not
%used for plotting, but p-value is reported in the paper)
% p = sum([vhardinvalid; veasyinvalid] > [vhardvalid; veasyvalid]) / (length(vhardvalid)*2);

%difficulty effect on drift rate, collapsed across validity conditions
p = sum([vhardinvalid; vhardvalid] > [veasyinvalid; veasyvalid]) / (length(vhardvalid)*2);
text(2.4, 0.35, ['p = ' num2str(round(p*1000)/1000)],'FontSize',15)

%validity effect on drift rate (difficult trials only) 
p = sum(vhardinvalid > vhardvalid) / length(vhardvalid);
text(2, 0.29, ['p = ' num2str(round(p*1000)/1000)],'FontSize',15)

%validity effect on drift rate (easy trials only) 
p = sum(veasyinvalid > veasyvalid) / length(veasyvalid);
text(2.7, 0.29, ['p = ' num2str(round(p*1000)/1000)],'FontSize',15)

    