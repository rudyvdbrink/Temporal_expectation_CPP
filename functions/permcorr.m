function [r, p, ci, r_null] = permcorr(a,b,varargin)
% PERMCORR computes correlation statistics using permutation testing. This
% allows you to specifiy an a-priori expected direct of a correlation. 
%
% Usage:
%     [r p ci r_null] = permcorr(a,b)                         
%     [r p ci r_null] = permcorr(a,b,npermutes,tail,CI)
%
%     a:          distribution 1
%     b:          distribution 2
%     npermutes:  (optional) the number of permutations. default: 1000
%     tail:       (optional) test one-tailed (specify 'right' or 'left') or two-tailed (specify 'both'). default: two-tailed
%                   if there is no a priori expectation, then use 'tail' = 'both'
%                   if the a priori expectation is that r > 0, then use 'tail' = 'right'
%                   if the a priori expectation is that r < 0, then use 'tail' = 'left'
%     CI:         confidence interval percentile to report back
%
%   Output:
%     r:          Pearson correlation coefficient
%     pval:       p-value of permutation test. Discard H0 if pval is small.
%     ci:         confidence interval around the correlation coefficient
%     diff_null:  the permuted null distribution
%
% RL van den Brink, 2020

%% check input
if nargin < 2
    error('not enough input arguments') 
elseif nargin == 2
    npermutes = 1000;
    tail = 'both';
    CI = 95;
elseif nargin == 3
    npermutes = varargin{1};
    tail = 'both';
    CI = 95;
elseif nargin == 4
    npermutes = varargin{1};
    tail = varargin{2};
    CI = 95;
elseif nargin == 5
    npermutes = varargin{1};
    tail = varargin{2};
    CI = varargin{3};
elseif nargin > 5
    error('too many input arguments')
end

if (length(a) ~= length(b)) 
    error('Vectors a and be must be the same size')
end

%make sure the input distributions are row vectors
if size(a,2) > size(a,1); a = a'; end
if size(b,2) > size(b,1); b = b'; end


%% correlate

r = corr(a,b);
r_null = zeros(npermutes,1);

for permi = 1:npermutes
   r_null(permi) = corr(a,randsample(b,length(b))); 
end

%get confidence interval around empirical correlation
ci(1) = prctile(r_null,100-CI);
ci(2) = prctile(r_null,CI);
ci = ci+r;

%calculate p-value
if strcmpi(tail,'both')    
    p = 1-sum(abs(r)>abs(r_null))/npermutes;
elseif strcmpi(tail,'right')
    p = 1-sum(r>r_null)/npermutes;
elseif strcmpi(tail,'left')
    p = 1-sum(r<r_null)/npermutes;
end


end