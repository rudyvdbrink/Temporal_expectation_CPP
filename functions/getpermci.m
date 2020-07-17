function ci = getpermci(d,dn,pc)
% CI = GETPERMCI(diff,diff_null,interval) gets the permutation-test derived
% confidence interval specified in interval around the empirical difference
% between conditions diff, going by the null distribution diff_null. 
%
% Usage:
%     CI = getpermci(diff,diff_null)
%     CI = getpermci(diff,diff_null,interval)     
%
%   Input:
%     diff:       empirical difference between conditions
%     diff_null:  permuted null distribution
%     interval:   (optional) scalar or a vector of percent values (default:
%                 5% and 95%)
%     
%   Output:
%     CI:         confidence interval around diff

%% check input
if ~exist('pc','var')
    pc = [5 95];
end

if isempty(pc)
    pc = [5 95];
end

% get interval
ci = d+prctile(dn,pc);