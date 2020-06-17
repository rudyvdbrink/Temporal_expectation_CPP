function wsplot(indata,mc,cols)
% WSPLOT(indata,mc,cols) plots the data in N x C data matrix indata. N is 
% the number of cases in the data, C is the number of conditions.
%
% If mc is true, prior to plotting, the data are mean-centered with respect 
% to the grand-average. 
% 
% Error bars in the plot show the within-participant standard error of the 
% mean. 
%
%  Input:
%   indata: an N X C matrix.
%   mc:     mean center the data (1, default) or not (0)
%   cols:   an C x 3 matrix of color values used to plot the individual
%           conditions. If cols is left empty it defaults to the jet color
%           map.
% 
% RL van den Brink, 2020

%% check input
if ~exist('mc','var')
    mc = 1;
end

if isempty(mc)
   mc = 1;
end

mc = double(mc);

if ~exist('cols','var')
    cols = jet(size(indata,2));
end

if isempty(cols)
    cols = jet(size(indata,2));
end

if size(cols,1) ~= size(indata,2) || size(cols,2) ~= 3
    error('Variable cols should be N x 3')
end

%% get variables
n  = size(indata,1); %number of subjects
nc = size(indata,2); %number of conditions
m  = nanmean(indata); %overall mean
eb = wse(indata); %within-subject SEM
subcols = repmat(linspace(0.2,0.9,n)',1, 3); %colors for the individual subjects
subdata = nan(size(indata)); %mean-centered subjectwise data

%% plot individual subjects
hold on
for si = 1:n
    sm = squeeze(nanmean(indata(si,:))); %condition-mean of this subject  
    subdata(si,:) = indata(si,:)-(sm*mc) + (m*mc);    
    plot(subdata(si,:),'o-','MarkerFaceColor',subcols(si,:),'MarkerEdgeColor','w', 'Color',subcols(si,:))
end
cm = nanmean(subdata); %average (mean centered) data
%% plot condition-wise means
for ci = 1:nc    
    plot(ci-0.1,nanmean(subdata(:,ci)),'wo','MarkerFaceColor',cols(ci,:), 'MarkerSize',10)
    plot([ci ci]-0.1,[cm(ci)-eb(ci) cm(ci)+eb(ci)],'color', cols(ci,:), 'linewidth',2)
end

%% format
xlim([0 nc+1])
set(gca,'tickdir','out','box','off')