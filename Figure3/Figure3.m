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

%'modeldata' contains the model parameters of the individual participants.
%this variable has N rows (participants) and 7 columns (parameters). The
%parameters are as follows:
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

%'qd' contains the real data quantile values for the quantile probability 
%plot. It is of size N (participants) by 4 (conditions) by 5 (quantiles).
%For condition labels, see variable 'conditions'. 

%'nd' contains the cumulative RT probability per quantile scaled by accuracy
%(real data) and is of the same dimensionality as qd.

load data.mat

%% Simulate behavioral data using the model parameters (this can take a few minutes)

c       = 1.0;
numtr   = 25000;
simdata = zeros(size(modeldata,1),2,2);
qm      = zeros(size(modeldata,1),4,5); % quintile values
nm       = zeros(size(qm)); % cumulative probability
for subi = 1:size(modeldata,1)
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,3),'Ter',modeldata(subi,1));
    simdata(subi,1,1) = squeeze(mean(resp(resp(:,2)==1 ,1))); %valid, easy 
    qm(subi,1,:) = quantile(resp(resp(:,2)==1 ,1),0.1:0.2:0.9);  %get quantile (valid, easy)
    nm(subi,1,:)  = (0.1:0.2:0.9) .* mean(resp(:,2)==1); %scale cumulative probability by accuracy
    
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,4),'Ter',modeldata(subi,1));
    simdata(subi,1,2) = squeeze(mean(resp(resp(:,2)==1 ,1))); %valid, difficult   
    qm(subi,2,:) = quantile(resp(resp(:,2)==1 ,1),0.1:0.2:0.9); %get quantile (valid, difficult)
    nm(subi,2,:) = (0.1:0.2:0.9).* mean(resp(:,2)==1); %scale cumulative probability by accuracy
    
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,5),'Ter',modeldata(subi,2));
    simdata(subi,2,1) = squeeze(mean(resp(resp(:,2)==1 ,1))); %invalid, easy 
    qm(subi,3,:)  = quantile(resp(resp(:,2)==1 ,1),0.1:0.2:0.9); %get quantile (invalid, easy)
    nm(subi,3,:)  = (0.1:0.2:0.9).* mean(resp(:,2)==1); %scale cumulative probability by accuracy
    
    resp = diffProcess('numTr',numtr,'c',c,'a',modeldata(subi,end),'v',modeldata(subi,6),'Ter',modeldata(subi,2));
    simdata(subi,2,2) = squeeze(mean(resp(resp(:,2)==1 ,1))); %invalid, difficult
    qm(subi,4,:)  = quantile(resp(resp(:,2)==1 ,1),0.1:0.2:0.9); %get quantile (invalid, difficult)
    nm(subi,4,:)  = (0.1:0.2:0.9).* mean(resp(:,2)==1); %scale cumulative probability by accuracy    
end
simdata = simdata * 1000; %scale to ms (instead of seconds)

%% make defective cumulative quantile probability plot
figure
subplot(2,3,1)

plotcolors = parula(4);

qm = qm * 1000; %scale to ms
qd = qd * 1000; %scale to ms
for condi = 1:4
    plot(squeeze(mean(qm(:,condi,:))), squeeze(mean(nm(:,condi,:))), 'o','color',plotcolors(condi,:),'MarkerSize',10, 'LineWidth',2)
    hold on
    
    plot(squeeze(mean(qd(:,condi,:))), squeeze(mean(nd(:,condi,:))), '--','color',plotcolors(condi,:),'MarkerSize',10, 'LineWidth',2)    
    
    %plot sem for cumulative probability (y axis)
    m   = squeeze(mean(nd(:,condi,:))); 
    sem = squeeze(std(nd(:,condi,:)))./sqrt(size(modeldata,1));    
    plot([squeeze(mean(qd(:,condi,:))) squeeze(mean(qd(:,condi,:)))]' , [m-sem m+sem]','color',plotcolors(condi,:),'LineWidth',2)
    
    %plot sem for quintiles (x axis)
    m   = squeeze(mean(qd(:,condi,:))); 
    sem = squeeze(std(qd(:,condi,:)))./sqrt(size(modeldata,1));    
    plot([m-sem m+sem]' , [squeeze(mean(nd(:,condi,:))) squeeze(mean(nd(:,condi,:)))]','color',plotcolors(condi,:),'LineWidth',2)
    
end

box off
xlabel('RT (ms)')
ylabel('Cumulative probability')
set(gca,'tickdir','out','ytick',0:.2:1,'ylim',[0 1],'fontsize',18,'linewidth',1)



%% Make scatter plot of model and data (mean RT)

subplot(2,3,2)

r = zeros(4,1);
p = zeros(size(r));
for condi = 1:4    
    plot(squeeze(simdata(:,condi)),bhvdat(:,condi),'wo','MarkerFaceColor',plotcolors(condi,:),'markersize',10)
    hold on
    [r(condi), p(condi)] = corr(squeeze(simdata(:,condi)),bhvdat(:,condi)); %correlate data and model RT    
    disp(['Correlation between model and data for ' conditions{condi} ' trials: r = ' num2str(r(condi)) ', p = ' num2str(p(condi))])
    P = polyfit(squeeze(simdata(:,condi)),bhvdat(:,condi),1);
    y = squeeze(simdata(:,condi)).*P(1) + P(2); %least squares regression line
    plot(squeeze(simdata(:,condi)),y,'-','color',plotcolors(condi,:),'LineWidth',2)        
end

xeb = std(simdata(:,:))./sqrt(size(simdata,1)); %error bar for the model
yeb = std(bhvdat(:,1:4))./sqrt(size(simdata,1));%error bar for the data
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


%% Plot correlation between model effect of validity on Ter, and real effect of validity on RT

a = (modeldata(:,2)-modeldata(:,1))*1000; %invalid versus valid Ter
b = mean(bhvdat(:,3:4),2)-mean(bhvdat(:,1:2),2); %invalid versus valid RT

%plot model versus data (scatter plot)
subplot(2,3,3)
plot(a,b,'wo','MarkerFaceColor','k','markersize',10)
hold on

%get least squares regression line and plot
P = polyfit(a,b,1);
y = a.*P(1) + P(2); %least squares regression line
plot(a,y,'-','color',[1 1 1]*.5,'LineWidth',2)

%formatting
xlim([-10 90])
ylim([-10 90])
box off
set(gca,'tickdir','out','fontsize',18,'ytick',-10:20:90,'xtick',-10:20:90)
shg
hold on
plot([-10 90],[-10 90],'k--')
axis square
xlabel('T_{er}: invalid - valid (ms)')
ylabel('RT: invalid - valid (ms)')

%correlate and get bayes factor for difference between conditions
[~, ~, ~, stats] = ttest(a,b);
bf = t1smpbf(stats.tstat,21);
[r, p] = corr(a,b);
title(['r = ' num2str(round(r*1000)/1000) ', p ' num2str(round(p*1000)/1000) ', BF = ' num2str(round(bf*1000)/1000)])

%test if the 95% confidence interval of a bootstrapped slope of the least
%squares regression line overlaps with 1 (i.e. if the slope of the real 
%regression line is close to that of the identity line)
nboots = 10000; %number of iterations for bootstrapping
cdat = [a b]; %the data for bootstrapping
P_null = zeros(nboots,2); %reserve some memory
for bi = 1:nboots   
    cdat_null    = cdat(randsample(1:size(cdat,1),size(cdat,1),1),:); %bootstrapped data (sampled with replacement)
    P_null(bi,:) = polyfit(cdat_null(:,1),cdat_null(:,2),1); %fitted least squares regression line   
end
h = 1 > prctile(P_null(:,1),5) && 1 < prctile(P_null(:,1),95); %test if the 95% confidence interval overlaps with 1

if h
    disp(['95% CI of least squares regression line (slope = ' num2str(P(1)) ') overlaps with slope of the identity line'])
end

% %make a plot of the null distribution and its 95% CI, and value of identity line
% [n, x] = hist(P_null(:,1),100);
% figure
% bar(x,n/sum(n)*100,'EdgeColor','none')
% hold on
% plot([1 1] , [0 8],'k--')
% plot([prctile(P_null(:,1),5)  prctile(P_null(:,1),5) ] , [0 8],'r--')
% plot([prctile(P_null(:,1),95) prctile(P_null(:,1),95)] , [0 8],'r--') 


%% correlate effect of difficulty and validity on drift rate

a = squeeze(mean(modeldata(:,[4 6]),2)) -  squeeze(mean(modeldata(:,[3 5]),2));
b = mean(bhvdat(:,[2 4]),2)-mean(bhvdat(:,[1 3]),2); %invalid versus valid RT
[r, p] = corr(a,b);
disp(['Correlation between effect of difficulty on v, and on RT: r = ' num2str(r) ', p ' num2str(p) ])

a = squeeze(mean(modeldata(:,3:4),2)) -  squeeze(mean(modeldata(:,1:2),2));
b = mean(bhvdat(:,3:4),2)-mean(bhvdat(:,1:2),2); %invalid versus valid RT
[r, p] = corr(a,b);
disp(['Correlation between effect of cue validity on v, and on RT: r = ' num2str(r) ', p ' num2str(p) ])  
 
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

x  = 0.2:0.001:0.4; %range for histogram (this is in seconds)

pd = fitdist(tvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x*1000,y,[0 0.8 0],'edgecolor','none','facealpha',alpha) %plot the data in ms (i.e. multiply by 1000)
hold on
plot([mean(squeeze(modeldata(:,1))) mean(squeeze(modeldata(:,1)))]*1000, [0 max(y)], '--', 'color', [0 0.8 0],'linewidth',2)

pd = fitdist(tinvalid,'kernel');
y  = pdf(pd,x); y = y/sum(y) * 100;
patch(x*1000,y,[0 0.4 0],'edgecolor','none','facealpha',alpha)
hold on
plot([mean(squeeze(modeldata(:,2))) mean(squeeze(modeldata(:,2)))]*1000, [0 max(y)], '--', 'color', [0 0.4 0],'linewidth',2)

xlim([0.23 0.33]*1000)
title('T_{er}')
set(gca,'tickdir','out','fontsize',18,'linewidth',1)
xlabel('Parameter estimate (ms)')
ylabel('Frequency of occurrence (%)')

%validity effect on non-decision time
p = sum(tvalid > tinvalid) / length(tvalid);
text(275, 7, ['p = ' num2str(round(p*1000)/1000)],'FontSize',15)

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
ylabel('Frequency of occurrence (%)')


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

    
