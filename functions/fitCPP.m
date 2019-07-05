% Function for single-trial CPP fitting
%
% params(1) = onset
% params(2) = slope
%
% data(:,1) = times
% data(:,2) = cpp

function ssr = fitCPP(params,data)

onset = params(1);
slope = params(2);

times = data(1,:)-onset;  % computing times vector centered on onset

pred(times<=0) = 0;  % computing predicted CPP
pred(times>0) = times(times>0).*slope;

ssr = sum((data(2,:)-pred).^2);  % computing sum of squared residuals
