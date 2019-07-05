function sem = wse(data,plotinfig)
% sem = WSE(data,plotinfig)
%
% compute and / or plot within-subject error bars
%
% input matrix data needs to be two-dimensional with the first dimension 
% being participants, and the seconds being conditions

if ~exist('plotinfig','var')
    plotinfig = 0;
end

nsubs = size(data,1);
ncondis = size(data,2);


%subtract across-condition mean from each participant and get SEM
nmdata = data-mean(data,2);
sem = std(nmdata,1)./sqrt(nsubs);

if plotinfig
    hold on    
    plot([1:ncondis; 1:ncondis] , [mean(data,1)-sem; mean(data,1)+sem],'color',[.5 .5 .5],'LineWidth',2)
end
    
    
