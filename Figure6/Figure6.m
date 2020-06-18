clear
close all
clc

%add functions
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

% The matrix 'bhvdat' has 18 columns:
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

%The variables rtime and stime keep track of time relative to response and
%relative to stimulus onset, respectively.
%ta_slopes and ta_onsets are the slopes and onsets, computed on
%trial-average waveforms.
%st_slopes and st_onsets are the average slopes and onsets computed at the 
%single trial level.
%st_onsetvar contains the cross-trial variability in onset
%The slope/onset variables are all of size participants by conditions,
%where conditions go from 1 through 8 in the order as described above (but
%without separation of stimulus locking or response locking)
%Plotcolors contains a matrix with color values for plotting 

%Permdist contains the permuted null distributions that are used to compute
%p-values for individual statistical tests. It has size test (N) by
%iteration (10000). The tests that are conducted are as follows:

%1) Trial-average onset: valid versus invalid
%2) Trial-average slope: valid versus invalid
%3) Trial-average onset: easy versus difficult
%4) Trial-average slope: easy versus difficult
%5) Mean single-trial onset: valid versus invalid
%6) Mean single-trial onset variability: valid versus invalid
%7) Mean single-trial slope: valid versus invalid
%8) Mean single-trial slope: easy versus difficult

load data.mat

%% plotting options

cols = [0 0 0; 1 0 0];
mc = 1;

%% Plot trial-average CPP for valid and invalid conditions (stimulus locked)

figure
subplot(2,2,1)
hold on
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-200 800],[0 0],'k--','linewidth',2) 

ci = 1; %this keeps track of the number of lines that have been plotted
for condi = [9 11] %loop over stimulus locked conditions   
%     plot(stime, squeeze(mean(mean(CPP(:,condi:condi+1,:)))),'color',plotcolors(ci,:),'linewidth',3);
    m  = squeeze(mean(mean(CPP(:,condi:condi+1,:))));
    eb = squeeze(std(mean(CPP(:,condi:condi+1,:),2))) ./sqrt(size(CPP,1));
    shadedErrorBar(stime,m,eb ,{'color',plotcolors(ci,:),'linewidth',3});
    ci = ci+1;
end

xlim([-200 800])
ylim([-10 30])
xlabel('Peri-stimulus time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
ylabel('Amplitude (\muV/m^2)')
title('Effect of cue validity (short CTI)')


%plot onsets (individual subjects)
indata = [squeeze(mean(ta_onsets(:,1:2),2)) squeeze(mean(ta_onsets(:,3:4),2))];
subcols = repmat(linspace(0.2,0.9,size(indata,1))',1, 3); %colors for the individual subjects
for si = 1:size(indata,1)
    plot(indata(si,:)-(squeeze(nanmean(indata(si,:)))*mc) + (nanmean(indata)*mc),[-7 -3],'o-','MarkerFaceColor',subcols(si,:),'MarkerEdgeColor','w', 'Color',subcols(si,:))
end

%plot the average estimated CPP onsets 
plot(squeeze(mean(mean(ta_onsets(:,1:2)))),-7,'ko','markerfacecolor','k')
plot([squeeze(mean(mean(ta_onsets(:,1:2))))-std(squeeze(mean(ta_onsets(:,1:2),2)))./sqrt(size(ta_onsets,1)) squeeze(mean(mean(ta_onsets(:,1:2))))+std(squeeze(mean(ta_onsets(:,1:2),2)))./sqrt(size(ta_onsets,1))],[0 0]-7,'k','linewidth',3)
plot(squeeze(mean(mean(ta_onsets(:,3:4)))),-3,'ro','markerfacecolor','r')
plot([squeeze(mean(mean(ta_onsets(:,3:4))))-std(squeeze(mean(ta_onsets(:,3:4),2)))./sqrt(size(ta_onsets,1)) squeeze(mean(mean(ta_onsets(:,3:4))))+std(squeeze(mean(ta_onsets(:,3:4),2)))./sqrt(size(ta_onsets,1))],[0 0]-3,'r','linewidth',3)

%plot average RT as dotted lines
plot([squeeze(mean(mean(bhvdat(:,1:2)))) squeeze(mean(mean(bhvdat(:,1:2))))], [-10 30],'k--')
plot([squeeze(mean(mean(bhvdat(:,3:4)))) squeeze(mean(mean(bhvdat(:,3:4))))], [-10 30],'r--')

%run statistics
diff = mean(mean(ta_onsets(:,1:2),2)) - mean(mean(ta_onsets(:,3:4),2)); %the observed value
p = sum(diff >= permdist(1,:)) / size(permdist,2); %compute p value
text(300,-5,['p = ' num2str(p)],'fontsize',18)

%% Plot trial-average CPP for valid and invalid conditions (response locked)

%plot the CPP for a channel, stimulus locked, and for the short interval
subplot(2,4,3)
hold on
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-400 100],[0 0],'k--','linewidth',2) 

ci = 1; %this keeps track of the number of lines that have been plotted
for condi = [1 3] %loop over stimulus locked conditions
    m  = squeeze(mean(mean(CPP(:,condi:condi+1,:))));
    eb = squeeze(std(mean(CPP(:,condi:condi+1,:),2))) ./sqrt(size(CPP,1));
    shadedErrorBar(rtime,m,eb ,{'color',plotcolors(ci,:),'linewidth',3});    
    ci = ci+1;
end

% title('response locked: short interval')
xlim([-400 100])
xlabel('Peri-response time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
ylim([-10 30])

%test if CPP peak latency deviates significantly from time of response
vdat = squeeze(mean(CPP(:,1:2,:),2)); %response-locked CPP on valid trials
[~, peaktimes(:,1)] = max(vdat,[],2); %get index of peak
idat = squeeze(mean(CPP(:,3:4,:),2)); %response-locked CPP on valid trials
[~, peaktimes(:,2)]  = max(idat,[],2); %get index of peak

%convert to ms (instead of index)
for subi = 1:size(vdat,1)
    peaktimes(subi,1) = rtime(peaktimes(subi,1));
    peaktimes(subi,2) = rtime(peaktimes(subi,2));
end

%compare the peak latency for valid and invalid trials
[~, p] = permtest(peaktimes(:,1),peaktimes(:,2),10000);
[~, ~, ~, stats] = ttest(peaktimes(:,1),peaktimes(:,2)); %get t-statistic to get bayes factor
bf = t1smpbf(stats.tstat,21);
disp(['Response-locked CPP peak latency comparison of valid versus invalid trials: p = ' num2str(p) ', BF = ' num2str(bf)]) 

%% plot the trial-average estimated CPP slopes (valid versus invalid)

%plot the estimated CPP slopes
subplot(2,5,5)
hold on
indata = [mean(ta_slopes(:,1:2),2) mean(ta_slopes(:,3:4),2)];
wsplot(indata,mc,cols)
set(gca,'xtick',[],'tickdir','out')
ylabel('Slope (\muV / m^2 / T_s)')
set(gca,'fontsize',18)

%get the observed difference between conditions, and compare it to the
%permuted null distribution
diff = mean(mean(ta_slopes(:,1:2),2)) - mean(mean(ta_slopes(:,3:4),2)); %the observed value
p = sum(diff <= permdist(2,:)) / size(permdist,2); %compute p value
title(['p = ' num2str(p)])

%% Plot trial-average CPP for easy and difficult conditions (stimulus locked)

%plot the CPP for a channel, stimulus locked, and for the short interval
subplot(2,2,3)
hold on
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-200 800],[0 0],'k--','linewidth',2) 

ci = 1; %this keeps track of the number of lines that have been plotted
for condi = [9 10] %loop over stimulus locked conditions   
    m  = squeeze(mean(mean(CPP(:,condi:2:condi+6,:))));
    eb = squeeze(std(mean(CPP(:,condi:2:condi+6,:),2))) ./sqrt(size(CPP,1));
    shadedErrorBar(stime,m,eb ,{'color',plotcolors(ci,:),'linewidth',3});    
    ci = ci+1;
end

xlim([-200 800])
ylim([-10 30])
xlabel('Peri-stimulus time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
ylabel('Amplitude (\muV/m^2)')
title('Effect of difficulty')

%plot onsets (individual subjects)
indata = [squeeze(mean(ta_onsets(:,1:2:7),2)) squeeze(mean(ta_onsets(:,2:2:8),2))];
subcols = repmat(linspace(0.2,0.9,size(indata,1))',1, 3); %colors for the individual subjects
for si = 1:size(indata,1)
    plot(indata(si,:)-(squeeze(nanmean(indata(si,:)))*mc) + (nanmean(indata)*mc),[-7 -3],'o-','MarkerFaceColor',subcols(si,:),'MarkerEdgeColor','w', 'Color',subcols(si,:))
end

%plot the average estimated CPP onsets 
plot(squeeze(mean(mean(ta_onsets(:,1:2:7)))),-7,'ko','markerfacecolor','k')
plot([squeeze(mean(mean(ta_onsets(:,1:2:7))))-std(squeeze(mean(ta_onsets(:,1:2:7),2)))./sqrt(size(ta_onsets,1)) squeeze(mean(mean(ta_onsets(:,1:2:7))))+std(squeeze(mean(ta_onsets(:,1:2:7),2)))./sqrt(size(ta_onsets,1))],[0 0]-7,'k','linewidth',3)
plot(squeeze(mean(mean(ta_onsets(:,2:2:8)))),-3,'ro','markerfacecolor','r')
plot([squeeze(mean(mean(ta_onsets(:,2:2:8))))-std(squeeze(mean(ta_onsets(:,2:2:8),2)))./sqrt(size(ta_onsets,1)) squeeze(mean(mean(ta_onsets(:,2:2:8))))+std(squeeze(mean(ta_onsets(:,2:2:8),2)))./sqrt(size(ta_onsets,1))],[0 0]-3,'r','linewidth',3)

%plot average RT as dotted lines
plot([squeeze(mean(mean(bhvdat(:,1:2:8)))) squeeze(mean(mean(bhvdat(:,1:2:8))))], [-10 30],'k--')
plot([squeeze(mean(mean(bhvdat(:,2:2:8)))) squeeze(mean(mean(bhvdat(:,2:2:8))))], [-10 30],'r--')

%run statistics
diff = mean(mean(ta_onsets(:,1:2:7),2)) - mean(mean(ta_onsets(:,2:2:8),2)); %the observed value
p = sum(diff <= permdist(3,:)) / size(permdist,2); %compute p value
text(300,-5,['p = ' num2str(p)],'fontsize',18)

%% Plot trial-average CPP for easy and difficult conditions (response locked)

%plot the CPP for a channel, stimulus locked, and for the short interval
subplot(2,4,7)
hold on
plot([0 0],[-10 30],'k--','linewidth',2) 
plot([-400 100],[0 0],'k--','linewidth',2) 

ci = 1; %this keeps track of the number of lines that have been plotted
for condi = [1 3] %loop over stimulus locked conditions
%     plot(rtime, squeeze(mean(mean(CPP(:,condi:2:condi+6,:)))),'color',plotcolors(ci,:),'linewidth',3);
    m  = squeeze(mean(mean(CPP(:,condi:2:condi+6,:))));
    eb = squeeze(std(mean(CPP(:,condi:2:condi+6,:),2))) ./sqrt(size(CPP,1));
    shadedErrorBar(rtime,m,eb ,{'color',plotcolors(ci,:),'linewidth',3});    
    ci = ci+1;
end

% title('response locked: short interval')
xlim([-400 100])
xlabel('Peri-response time (ms)','fontsize',18)
set(gca,'tickdir','out','fontsize',18,'linewidth',1) 
ylim([-10 30])

%% plot the trial-average estimated CPP slopes (easy versus difficult)

%plot the estimated CPP slopes
subplot(2,5,10)
hold on

% bar(1,mean(mean(ta_slopes(:,1:2:7),2)),'FaceColor','k','EdgeColor','none')
% bar(2,mean(mean(ta_slopes(:,2:2:8),2)),'FaceColor','r','EdgeColor','none')
% wse([mean(ta_slopes(:,1:2:7),2) mean(ta_slopes(:,2:2:8),2)],1); %plot error bars
% ylim([0.05 0.11])
indata = [mean(ta_slopes(:,1:2:7),2) mean(ta_slopes(:,2:2:8),2)];
wsplot(indata,mc,cols)

set(gca,'xtick',[],'tickdir','out')
ylabel('Slope (\muV / m^2 / T_s)')
set(gca,'fontsize',18)

%get the observed difference between conditions, and compare it to the
%permuted null distribution
diff = mean(mean(ta_slopes(:,1:2:7),2)) - mean(mean(ta_slopes(:,2:2:8),2)); %the observed value
p = sum(diff <= permdist(4,:)) / size(permdist,2); %compute p value
title(['p = ' num2str(p)])


%% bar plots of onset, onset variability, and slope, computed at the single trial level

figure

%effect of cue validity on onset
subplot(2,4,1)
% hold on
% bar(1,mean(mean(st_onsets(:,1:2),2)),'FaceColor','k','EdgeColor','none');
% bar(2,mean(mean(st_onsets(:,3:4),2)),'FaceColor','r','EdgeColor','none');
% wse([mean(st_onsets(:,1:2),2) mean(st_onsets(:,3:4),2)],1); 
indata = [mean(st_onsets(:,1:2),2) mean(st_onsets(:,3:4),2)];
wsplot(indata,mc,cols)
% ylim([100 130])
diff = mean(mean(st_onsets(:,1:2),2) - mean(st_onsets(:,3:4),2)); %the observed value
p = sum(diff >= permdist(5,:)) / size(permdist,2); %compute p value
title([{'Effect of cue validity '} {['on onset p=' num2str(p)]}])
set(gca,'tickdir','out','xtick',1:2,'xticklabel',{'Valid', 'Invalid'})
box off
ylabel('Onset (ms)')
set(gca,'fontsize',18)


%effect of cue validity on onset variability
subplot(2,4,2)
hold on
% bar(1,mean(mean(st_onsetvar(:,1:2),2)),'FaceColor','k','EdgeColor','none');
% bar(2,mean(mean(st_onsetvar(:,3:4),2)),'FaceColor','r','EdgeColor','none');
% wse([mean(st_onsetvar(:,1:2),2) mean(st_onsetvar(:,3:4),2)],1);
% ylim([100 130])
indata = [mean(st_onsetvar(:,1:2),2) mean(st_onsetvar(:,3:4),2)];
wsplot(indata,mc,cols)
diff = mean(mean(st_onsetvar(:,1:2),2) - mean(st_onsetvar(:,3:4),2)); %the observed value
p = sum(diff >= permdist(6,:)) / size(permdist,2); %compute p value
title([{'Effect of cue validity '} {['on onset variability p=' num2str(p)]}])
set(gca,'tickdir','out','xtick',1:2,'xticklabel',{'Valid', 'Invalid'} )
box off
ylabel('Onset variability (ms)')
set(gca,'fontsize',18)


%effect of cue validity on slope
subplot(2,4,3)
hold on
% bar(1,mean(mean(st_slopes(:,1:2),2)),'FaceColor','k','EdgeColor','none');
% bar(2,mean(mean(st_slopes(:,3:4),2)),'FaceColor','r','EdgeColor','none');
% wse([mean(st_slopes(:,1:2),2) mean(st_slopes(:,3:4),2)],1); 
% ylim([0.05 .09])
indata = [mean(st_slopes(:,1:2),2) mean(st_slopes(:,3:4),2)];
wsplot(indata,mc,cols)
diff = mean(mean(st_slopes(:,1:2),2) - mean(st_slopes(:,3:4),2)); %the observed value
p = sum(diff <= permdist(7,:)) / size(permdist,2); %compute p value
title([{'Effect of cue validity '} {['on slope p=' num2str(p)]}])
set(gca,'tickdir','out','xtick',1:2,'xticklabel',{'Valid', 'Invalid'})
box off
ylabel('Slope (\muV / m^2 / T_s)')
set(gca,'fontsize',18)


%effect of difficulty on slope
subplot(2,4,4)
hold on
% bar(1,mean(mean(st_slopes(:,1:2:7),2)),'FaceColor','k','EdgeColor','none');
% bar(2,mean(mean(st_slopes(:,2:2:8),2)),'FaceColor','r','EdgeColor','none');
% wse([mean(st_slopes(:,1:2:7),2) mean(st_slopes(:,2:2:8),2)],1); 
% ylim([0.05 .09])
indata = [mean(st_slopes(:,1:2:7),2) mean(st_slopes(:,2:2:8),2)];
wsplot(indata,mc,cols)
diff = mean(mean(st_slopes(:,1:2:7),2) - mean(st_slopes(:,2:2:8),2)); %the observed value
p = sum(diff <= permdist(8,:)) / size(permdist,2); %compute p value
title([{'Effect of difficulty'} {['on slope p=' num2str(p)]}])
set(gca,'tickdir','out','xtick',1:2,'xticklabel',{'Easy', 'Difficult'})
box off
ylabel('Slope (\muV / m^2 / T_s)')
set(gca,'fontsize',18)
