%% clear contents
clear
close all
clc

%add functions
%you will need the statistics toolbox to run this code
homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load data

% The matrix 'data' has 18 columns:
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

% Each row in the data matrix is a participant.

data = dlmread('data.txt');

%% display overall effects
clc

disp(['Average cueing effect on short interval trials: ' num2str(mean([(mean(data(:,3)-data(:,1))) (mean(data(:,4)-data(:,2))) ])) ' ms, SD ' num2str(std(mean([(data(:,3)-data(:,1)) (data(:,4)-data(:,2)) ],2)))])
disp(['Average cueing effect on long interval trials: ' num2str(mean([(mean(data(:,7)-data(:,5))) (mean(data(:,8)-data(:,6))) ])) ' ms, SD ' num2str(std(mean([(data(:,7)-data(:,5)) (data(:,8)-data(:,6)) ],2)))])
disp(['Average effect of difficulty on RT: ' num2str(mean([(mean(data(:,2)-data(:,1))) (mean(data(:,4)-data(:,3))) (mean(data(:,6)-data(:,5))) (mean(data(:,8)-data(:,7))) ])) ' ms, SD ' num2str(std(mean([(data(:,2)-data(:,1)) (data(:,4)-data(:,3)) (data(:,6)-data(:,5)) (data(:,8)-data(:,7)) ],2)))])
disp(['Average easy trials ' num2str(mean(mean(data(:,[1 3 5 7]+8)))) '% correct, difficult trials ' num2str(mean(mean(data(:,[2 4 6 8]+8)))) '% correct']);  

disp(['Average cueing effect for easy short interval trials: ' num2str(mean(data(:,3)-data(:,1))) 'ms'])
disp(['Average cueing effect for difficult short interval trials: ' num2str(mean(data(:,4)-data(:,2))) 'ms'])

disp(['Average cueing effect for easy long interval trials: ' num2str(mean(data(:,7)-data(:,5))) 'ms'])
disp(['Average cueing effect for difficult long interval trials: ' num2str(mean(data(:,8)-data(:,6))) 'ms'])

%% make figure

xo = 0.05; %x-offxet for plotting
figure

%RT
subplot(2,2,1)
hold on
title('Short interval trials')
boxplot(data(:,[1 3]),'plotstyle','compact', 'color','k', 'positions' ,[1 2]-xo, 'medianstyle','line')
boxplot(data(:,[2 4]),'plotstyle','compact', 'color',[.5 .5 .5], 'positions' ,[1 2]+xo, 'medianstyle','line')
plot([1 2]-xo,mean(data(:,[1 3])),'ko-','linewidth',3,'markerfacecolor','k')
plot([1 2]+xo,mean(data(:,[2 4])),'s--','linewidth',3,'markerfacecolor',[.5 .5 .5],'color',[.5 .5 .5])
xlim([0 3])
set(gca,'xtick',[1 2],'xticklabel', {'valid' , 'invalid'},'tickdir','out','fontsize',18,'linewidth',1)
xlabel('cue validity')
ylabel('RT (ms)')
 
axis square
ylim([300 700])
box off

subplot(2,2,2)
hold on
title('Long interval trials')
boxplot(data(:,[5 7]),'plotstyle','compact', 'color','k', 'positions' ,[1 2]-xo, 'medianstyle','line')
boxplot(data(:,[6 8]),'plotstyle','compact', 'color',[.5 .5 .5], 'positions' ,[1 2]+xo, 'medianstyle','line')
plot([1 2]-xo,mean(data(:,[5 7])),'ko-','linewidth',3,'markerfacecolor','k')
plot([1 2]+xo,mean(data(:,[6 8])),'s--','linewidth',3,'markerfacecolor',[.5 .5 .5],'color',[.5 .5 .5])
xlim([0 3])
set(gca,'xtick',[1 2],'xticklabel', {'valid' , 'invalid'},'tickdir','out','fontsize',18,'linewidth',1)
xlabel('cue validity')
ylabel('RT (ms)')

axis square
ylim([300 700])
box off

%accuracy
subplot(2,2,3)
hold on
title('Short interval trials')
boxplot(100-data(:,[1 3]+8),'plotstyle','compact', 'color','k', 'positions' ,[1 2]-xo, 'medianstyle','line')
boxplot(100-data(:,[2 4]+8),'plotstyle','compact', 'color',[.5 .5 .5], 'positions' ,[1 2]+xo, 'medianstyle','line')
plot([1 2]-xo,100-mean(data(:,[1 3]+8)),'ko-','linewidth',3,'markerfacecolor','k')
plot([1 2]+xo,100-mean(data(:,[2 4]+8)),'s--','linewidth',3,'markerfacecolor',[.5 .5 .5],'color',[.5 .5 .5])
xlim([0 3])
set(gca,'xtick',[1 2],'xticklabel', {'valid' , 'invalid'},'tickdir','out','fontsize',18,'linewidth',1)
xlabel('cue validity')
ylabel('Errors (%)')

axis square
ylim([0 25])
box off


subplot(2,2,4)
hold on
title('Long interval trials')
boxplot(100-data(:,[5 7]+8),'plotstyle','compact', 'color','k', 'positions' ,[1 2]-xo, 'medianstyle','line')
boxplot(100-data(:,[6 8]+8),'plotstyle','compact', 'color',[.5 .5 .5], 'positions' ,[1 2]+xo, 'medianstyle','line')
plot([1 2]-xo,100-mean(data(:,[5 7]+8)),'ko-','linewidth',3,'markerfacecolor','k')
plot([1 2]+xo,100-mean(data(:,[6 8]+8)),'s--','linewidth',3,'markerfacecolor',[.5 .5 .5],'color',[.5 .5 .5])
xlim([0 3])
set(gca,'xtick',[1 2],'xticklabel', {'valid' , 'invalid'},'tickdir','out','fontsize',18,'linewidth',1)
xlabel('cue validity')
ylabel('Errors (%)')

axis square
ylim([0 25])
box off

%% test significance of cueing effect and difficulty effect

disp(' ')
[~, p, ~, stats] = ttest(mean([(data(:,3)-data(:,1)) (data(:,4)-data(:,2)) ],2),[],0.05,'right');
disp(['Cueing effect short interval significant? t(' num2str(stats.df) ') = ' num2str(stats.tstat) ', p = ' num2str(p)])

[~, p, ~, stats] = ttest(mean([(data(:,7)-data(:,5)) (data(:,8)-data(:,6)) ],2),[],0.05,'right');
disp(['Cueing effect long interval significant? t(' num2str(stats.df) ') = ' num2str(stats.tstat) ', p = ' num2str(p)])

[~, p, ~, stats] = ttest(mean([(data(:,2)-data(:,1)) (data(:,4)-data(:,3)) (data(:,6)-data(:,5)) (data(:,8)-data(:,7)) ],2),[],0.05,'right');
disp(['Difficulty effect significant? t(' num2str(stats.df) ') = ' num2str(stats.tstat) ', p = ' num2str(p)])

[~, p, ~, stats] = ttest(mean([(data(:,3)-data(:,1)) (data(:,4)-data(:,2)) ],2) , mean([(data(:,2)-data(:,1)) (data(:,4)-data(:,3)) (data(:,6)-data(:,5)) (data(:,8)-data(:,7)) ],2) );
BF = t1smpbf(stats.tstat,21); %compute Bayes factor
disp(['Cueing effect on short interval different from difficulty effect? t(' num2str(stats.df) ') = ' num2str(stats.tstat) ', p = ' num2str(p) ', BF = ' num2str(BF)])

