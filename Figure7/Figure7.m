%% clear contents and add current folder with subfolders
clear
close all
clc

eeglab,close

%add functions
%you will need the statistics toolbox to run this code
homedir = mfilename('fullpath');
funcdir = [homedir(1:end-15) 'functions'];
addpath(genpath(funcdir))

%% load the data

%Variable CPP contains the subject-wise CPP traces, and is of size 21 
%(participants) by 513 (time points). The variable t keeps track of time.
%
%The variable chanlocs is a structure with channel location information for 
%topographical plotting.
%
%The variable topo_CPP contains the channel-wise values of the CPP. 

load data.mat

%% plot CPP locked to expected target onset on invalidly cued long-interval trials (when no target actually appeared)

times2plot = [-200 800]; %define time relative to when the stim was expected

figure
subplot(2,2,1)
hold on
plot([times2plot(1) times2plot(2)],[0 0],'k--')
plot([0 0],[-10 30],'k--')
shadedErrorBar(t,squeeze(mean(CPP)),std(CPP)./sqrt(size(CPP,1)),'k');
xlim([times2plot(1) times2plot(2)])
ylim([-10 30])
box off
set(gca,'tickdir','out','xtick',times2plot(1):200:times2plot(2),'ytick',-10:10:30)

[~, p] = ttest(CPP);
h = fdr(p,0.05);
xlabel('Peri-expected stimulus time (ms)')
ylabel('Amplitude (\muV/m^2)')

%plot significant time points if there are any
if sum(h) > 0
    plot(t(find(h)),-5,'ro')
end
set(gca,'fontsize',18)

%% make topographical plot
subplot(2,2,2)
topoplot(topo_cpp,chanlocs(1:64),'style','map');
set(gca,'clim',[-30 30])

set(gcf,'color','w')
