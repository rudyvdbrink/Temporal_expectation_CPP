clear
close all
clc

%add functions
%in addition to these functions you'll need EEGLAB
homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load data

%Variable tfr contains the power values. It has a size of 21 (participants)
%by 4 (conditions, see below) by frequency (1-30 Hz), by time points (see
%variable 't'). All data are stimulus-locked

%Conditions are:
%1) Short intrval, validly cued, easy
%2) Short intrval, validly cued, difficult
%1) Short intrval, invalidly cued, easy
%2) Short intrval, invalidly cued, difficult

%Variable t keeps track of time of the tfr
%Variable f keeps track of frequency of the tfr
%Variable f_fft keeps track of the frequencies for FFT-related plots
%Variable ampspect contains the amplitude spectrum for each participant
%Variable binRT contains RT values binned by alpha power
%Variable binonsets contains CPP onset values binned by alpha power
%Variable binslopes contains CPP slope values binned by alpha power
%Variable cpp_t keeps track of time for the CPP
%Variable CPP contains CPP values binned by alpha power

%Permdist contains the permuted null distributions that are used to compute
%p-values for individual statistical tests. It has size test (N) by
%iteration (10000). The tests that are conducted are as follows:

%1) RT for low alpha power bin versus RT high alpha power bin
%2) Onset for low alpha power bin versus onset high alpha power bin
%3) Slope for low alpha power bin versus slope high alpha power bin

load data.mat


%% analysis setting

f2plot = 9:12; %the alpha band
npermutes = 10000; %number of iterations for permutation test

%% Plot amplitude spectrum and topographical plot of alpha power

%amplitude spectrum
figure
plot(fft_f,mean(ampspect),'linewidth',2); 
xlabel('Frequency (Hz)')
ylabel('Amplitude (% of total)')
set(gca,'tickdir','out')
xlim([1 30])
box off

%topographical plot
figure
topoplot(squeeze(mean(topopower)),chanlocs,'style','map','electrodes','off');
set(gca,'clim',[min(squeeze(mean(topopower))) max(squeeze(mean(topopower)))])

%% Plot time-frequency comparison of valid versus invalid trials

figure

%set up time indexing
y_axis_freq_skip=3;
times_skip = 8;
x_axis_limit=[ -600 800 ];
[~,timeidx(1)]=min(abs(t-x_axis_limit(1)));
[~,timeidx(2)]=min(abs(t-x_axis_limit(2)));
%plot the contour map
contourf(squeeze(mean( mean(tfr(:,1:2,:,:),2)  - mean(tfr(:,3:4,:,:),2))),300,'linecolor','none')
set(gca,'ytick',0:5:length(f),'yticklabel',round(f(1:5:end))-1,'xtick',1:times_skip:length(t),'xticklabel',t(1:times_skip:end),'xlim',timeidx,'tickdir','out','clim',[-15 15],'fontsize',18);
hold on 
plot([find(t==0) find(t==0)],[0 f(end)],'k--')
box off
colorbar
colormap jet
ylim([5 20])
ylabel('Frequency (Hz)')
xlabel('Peri-stimulus time (ms)')

% [~, p] = permtestn(squeeze(mean(tfr(:,1:2,:,:),2)),squeeze(mean(tfr(:,3:4,:,:),2)),10000,0.05,'left');
% h = fdr(p,0.05);
% hold on
% contour(h,1,'linecolor','k')

%% Make line plot of alpha power in the individual conditions

figure

hold on
box off
plot(t,squeeze(mean(squeeze(mean(mean(tfr(:,1:2,f2plot,:),2),3)))),'k') %plot valid condition
plot(t,squeeze(mean(squeeze(mean(mean(tfr(:,3:4,f2plot,:),2),3)))),'r') %plot invalid condition
h = permtestn(squeeze(mean(mean(tfr(:,1:2,f2plot,:),2),3)),squeeze(mean(mean(tfr(:,3:4,f2plot,:),2),3)),10000,0.05,'left');
plot(t(h),140,'k.')
set(gca,'tickdir','out','fontsize',18)
xlim([-600 800])
plot([0 0],[120 180],'k--')
ylabel('\alpha Power (% change)')
xlabel('Peri-stimulus time (ms)')

%% plot CPP binned by alpha power

figure
hold on
for bini = 1:nbins
    plot(t_cpp*1000,squeeze(mean(CPP(:,bini,:)))','color',plotcolors(bini,:))
end
plot([-200 800],[0 0],'k--')
plot([0 0],[-10 30],'k--')
xlim([-200 800])
set(gca,'tickdir','out')
box off
set(gca,'FontSize',18)
xlabel('Peri-stimulus time (ms)')
ylabel('Amplitude (\muV / m^2)')


%% Make bar plots of RT and CPP parameters binned by alpha power

figure

%RT binned by alpha power
subplot(1,3,1)
hold on
for bini = 1:nbins
    bar(bini,mean(binRT(:,bini)),'EdgeColor','none','FaceColor',plotcolors(bini,:))
end
wse(binRT,1);
xlabel('Alpha bin')
ylabel('Response time (ms)')
ylim([0.45 0.465]*1000)
box off
set(gca,'tickdir','out','xtick',1:3,'FontSize',18,'YTick',450:5:465)
diff = mean(mean(binRT(:,1)) - mean(binRT(:,end))); %the observed value
p = sum(diff >= permdist(1,:)) / size(permdist,2); %compute p value
title(['RT: p = ' num2str(p)])

%Onset binned by alpha power
subplot(1,3,2)
hold on
for bini = 1:nbins
    bar(bini,mean(binonsets(:,bini)),'EdgeColor','none','FaceColor',plotcolors(bini,:))
end
wse(binonsets,1);
xlabel('Alpha bin')
ylabel('Onset (ms)')
ylim([100 140])
box off
set(gca,'tickdir','out','xtick',1:3,'FontSize',18)
diff = mean(mean(binonsets(:,1)) - mean(binonsets(:,end))); %the observed value
p = sum(diff >= permdist(2,:)) / size(permdist,2); %compute p value
title(['Onset: p = ' num2str(p)])

%Slope binned by alpha power
subplot(1,3,3)
hold on
for bini = 1:nbins
    bar(bini,mean(binslopes(:,bini)),'EdgeColor','none','FaceColor',plotcolors(bini,:))
end
wse(binslopes,1);
xlabel('Alpha bin')
ylabel('Slope (\muV / m^2 / T_s)')
ylim([0.04 0.052])
box off
set(gca,'tickdir','out','xtick',1:3,'FontSize',18,'FontSize',18,'YTick',0.04:0.004:0.052)
diff = mean(mean(binslopes(:,1)) - mean(binslopes(:,end))); %the observed value
p = sum(diff <= permdist(3,:)) / size(permdist,2); %compute p value
title(['Slope: p = ' num2str(p)])


