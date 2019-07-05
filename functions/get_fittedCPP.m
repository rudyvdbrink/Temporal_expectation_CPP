function [CPP] = get_fittedCPP(params,times)

onset = params(1);
slope = params(2);

times = times-onset;

CPP(times<=0) = 0;
CPP(times>0) = times(times>0).*slope;

