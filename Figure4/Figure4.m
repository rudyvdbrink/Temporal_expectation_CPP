clear
close all
clc

eeglab,close

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
mc = 0;

%% fit a two-part line segment to the CPP, per subject and RT bin

binonset = zeros(size(CPP_RT,1),size(CPP_RT,4));
binslope = zeros(size(CPP_RT,1),size(CPP_RT,4));
for subi = 1:size(CPP_RT,1)
    for bini = 1:size(CPP_RT,4)
        subRT  = squeeze(mean(RTs(subi,:,bini),2))*1000;
        subCPP = squeeze(mean(CPP_RT(subi,9:end,:,bini),2));        
        %get indices and data of window for fitting (here, ranging from -200 ms until the peak CPP)
        [~,idx(1)] = min(abs(stime - -200)); %start of fitting window
        [~,idx(2)] = max(subCPP); %end of fitting window
        cdata = [stime(idx(1):idx(2)); subCPP(idx(1):idx(2))']; %data used for fitting (so only time and the part of the CPP that falls within the window)        
        params_out = fminsearchbnd(@(params) fitCPP(params,cdata),[0.1 0.5],[0 0],[600 inf],options);  % running minimisation routine
        binonset(subi,bini) = params_out(1); %this is estimated CPP onset (in ms)
        binslope(subi,bini) = params_out(2); %this is estimated CPP slope
    end
end

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
[~, p] = permtest(squeeze(mean(CPP(:,9:end,:),2)),0,npermutes);
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
[~, p] = permtest(squeeze(mean(CPP(:,1:8,:),2)),0,npermutes);
h = fdr(p,0.05); %FDR correct
plot(rtime(logical(h)),ones(sum(h),1)*-5,'k.')

%% Topographical plot

subplot(2,4,4) %make a sub pannel in which to plot
topoplot(topo_cpp,chanlocs,'style','map','headrad',0.5,'plotrad',0.55); %make the topographical plot (this is an EEGLAB function)
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

eb = zeros(size(CPP_RT,3),3);
for ti = 1:size(CPP_RT,3)
    eb(ti,:) = wse(squeeze(mean(CPP_RT(:,9:end,ti,:),2)));
end

for bini = 1:3
    m  = squeeze(mean(mean(CPP_RT(:,9:end,:,bini),1),2));
    shadedErrorBar(stime,m,eb(:,bini),{'color',plotcolors(bini,:),'linewidth',3});
end
xlim([-200 800])
ylim([-10 30])

%plot onsets (individual subjects)
indata = binonset;
subcols = repmat(linspace(0.2,0.9,size(indata,1))',1, 3); %colors for the individual subjects
for si = 1:size(indata,1)
    plot(indata(si,:)-(squeeze(nanmean(indata(si,:)))*mc) + (nanmean(indata)*mc),[-2 -5 -8 ],'o-','MarkerFaceColor',subcols(si,:),'MarkerEdgeColor','w', 'Color',subcols(si,:))
end

%plot onsets (group averages)
eb = std(binonset) / sqrt(size(binonset,1)); %get error bars
plot( squeeze(mean(binonset(:,1))) - eb(1) : squeeze(mean(binonset(:,1))) + eb(1), zeros(size(squeeze(mean(binonset(:,1))) - eb(1) : squeeze(mean(binonset(:,1))) + eb(1)))-2 , 'color',plotcolors(1,:),'LineWidth',2)
plot(squeeze(mean(binonset(:,1))),-2,'o','MarkerFaceColor',plotcolors(1,:))
plot( squeeze(mean(binonset(:,2))) - eb(2) : squeeze(mean(binonset(:,2))) + eb(2), zeros(size(squeeze(mean(binonset(:,2))) - eb(2) : squeeze(mean(binonset(:,2))) + eb(2)))-5 , 'color',plotcolors(2,:),'LineWidth',2)
plot(squeeze(mean(binonset(:,2))),-5,'o','MarkerFaceColor',plotcolors(2,:))
plot( squeeze(mean(binonset(:,3))) - eb(3) : squeeze(mean(binonset(:,3))) + eb(3), zeros(size(squeeze(mean(binonset(:,3))) - eb(3) : squeeze(mean(binonset(:,3))) + eb(3)))-8 , 'color',plotcolors(3,:),'LineWidth',2)
plot(squeeze(mean(binonset(:,3))),-8,'o','MarkerFaceColor',plotcolors(3,:))

%compare and report stats
[~, p] = permtest(binonset(:,1),binonset(:,2),npermutes);
disp(['Onset: fast RT vs medium RT bin, p = ' num2str(p) ])
[~, p] = permtest(binonset(:,1),binonset(:,3),npermutes);
disp(['Onset: fast RT vs slow RT bin, p = ' num2str(p) ])
text(250,-5,['p = ' num2str(p)])
[~, p] = permtest(binonset(:,2),binonset(:,3),npermutes);
disp(['Onset: medium RT vs slow RT bin, p = ' num2str(p) ])

%response locked
subplot(2,4,7)
hold on
xlabel('Peri-response time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
box off
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-400 100],[0 0],'k--','linewidth',2) 

eb = zeros(size(CPP_RT,3),3);
for ti = 1:size(CPP_RT,3)
    eb(ti,:) = wse(squeeze(mean(CPP_RT(:,1:8,ti,:),2)));
end

for bini = 1:3
    m  = squeeze(mean(mean(CPP_RT(:,1:8,:,bini),1),2));
    shadedErrorBar(rtime,m,eb(:,bini),{'color',plotcolors(bini,:),'linewidth',3});
end
xlim([-400 100])
ylim([-10 30])

%% plot of CPP onset
subplot(2,5,10)
hold on
wsplot(binslope,mc,plotcolors)
set(gca,'tickdir','out','xtick',[],'fontsize',18)
box off
ylabel('CPP slope (\muV / m^2 / T_s)')
set(gcf,'color','w')

%% compare and report stats
[~, p] = permtest(binslope(:,1),binslope(:,2),npermutes);
disp(['Slope: fast RT vs medium RT bin, p = ' num2str(p) ])
[~, p] = permtest(binslope(:,1),binslope(:,3),npermutes);
disp(['Slope: fast RT vs slow RT bin, p = ' num2str(p) ])
text(2,0.14,['p = ' num2str(p)])
[~, p] = permtest(binslope(:,2),binslope(:,3),npermutes);
disp(['Slope: medium RT vs slow RT bin, p = ' num2str(p) ])




