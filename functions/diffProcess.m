function [resp]=diffProcess(varargin)
%Simulation of the diffusion process - Variability across trials, plus
%other types of variability (variability of nondecision time, variability
%of starting point). This model will work with one or two barriers. If you 
%want one barrier, just input b = -inf;
%
%This is a general purpose model. It can be used with different kinds
%of diffusion processes (one/two boundaries, variability across trials,
%and other kinds of variability).
%
%This function is used for generating data. No plots are shown during the 
%process.
%
%CLEAN: This is a clean version for the blog/MATLAB file exchange.
%https://biscionevalerio.wordpress.com
%
%Usage:
%   resp = diffProcess('key',value)     
%
%   Input: 
%     numTr: number of trials (iteration of the simulation, default = 1500)
%     a: upper threshold (default = 0.16)
%     b: lower threshold (default = 0)
%     z: starting point (default = a/2)
%     v: drift rate (default = 0.3)
%     Ter: non decision time (default = 0.26)
%     st: variability in non decision time (default = 0)
%     eta: variability in drift rate across trials (default = 0)
%     sz: variability in starting point (default = 0)
%     c: std within trial (default = 0.1)
%     tau: step (default = 0.0001)
%
%   Output: 
%     resp is a matrix (n by 2), the first column contains RT (in 
%     seconds), the second contains 1 for correct (upper threshold), 0 for 
%     incorrect (lower threshold). RT is NAN if the process did not 
%     terminate.
%
%Original by: Valerio Biscione.
%18/12/2014.
%Modified by: RL van den Brink
%08/07/2019.

p=inputParser;
addParameter(p, 'numTr', 1500); %number of trials (iteration of the simulation)
addParameter(p, 'a',0.16 ); %upper threshold
addParameter(p, 'b', []); %lower threshold. If []. b=0
addParameter(p, 'z', []); %starting point, if [] then z=a/2
addParameter(p, 'v', 0.3); %drift rate within trial
addParameter(p, 'Ter', .26);  %Non decision time
addParameter(p, 'st', 0); %variability in the non decision time
addParameter(p, 'eta', 0);  %variability in drift rate across trial
addParameter(p, 'sz', 0);  %variability in starting point
addParameter(p, 'c', 0.1); %std within trial, put [] is you want it to calculate for you
addParameter(p, 'tau', 0.0001); %step
addParameter(p, 'maxWalk', 2500); %the number of points for each trunck of cumsum
parse(p,varargin{:}); numTrials=p.Results.numTr; a=p.Results.a; b=p.Results.b; z=p.Results.z;
v=p.Results.v;  Ter=p.Results.Ter; st=p.Results.st; eta=p.Results.eta; sz=p.Results.sz; tau=p.Results.tau; c=p.Results.c;
maxWalk=p.Results.maxWalk;   resp=zeros(numTrials,2);



if isempty(z),    z=a/2;end

for xx=1:numTrials
    zz=unifrnd(z-sz/2,z+sz/2,1,1); %real starting point for this trial;    
    upB=a-zz;
    if isempty(b); lowB=-zz; else; lowB=b-zz; end 
    %we uniform everything such that the starting point is always 0. 
    zz=0;
    startPoint=zz;
    vm=normrnd(v,eta,1,1);
    % vm=unifrnd(v-eta/2,v+eta/2,1,1); %maybe you want to use a different
    % drift rate distribution?
    
    index=1;
    for ii=1:100
        timeseriesSUM=cumsum([startPoint; normrnd(vm*tau,c*sqrt(tau),maxWalk,1)]);
        firstPassA=find(timeseriesSUM(2:end)>=upB,1); firstPassB=find(timeseriesSUM(2:end)<=lowB,1);
        i=min([firstPassA firstPassB]);
        if isempty(i)
            startPoint(1)=timeseriesSUM(end);
            continue;
        else
            index=i+1+((ii-1)*maxWalk);
            break;
        end
    end
    
    %if the process DOES NOT terminate
    if isempty(firstPassB) && isempty(firstPassA)
        resp(xx,1)=-1;
        resp(xx,2)=3;
    else
        %if it DOES terminate, we want to now which was the first passage
        %point.
        resp(xx,1)=(index*tau)+unifrnd(Ter-st/2,Ter+st/2,1,1); %CORRECT
        if isempty(firstPassB) && ~isempty(firstPassA)
            resp(xx,2)=1;
        elseif ~isempty(firstPassB) && isempty(firstPassA)
            resp(xx,2)=0;
        elseif (~isempty(firstPassB) && ~isempty(firstPassA) && firstPassA<firstPassB)
            resp(xx,2)=1;
        elseif (~isempty(firstPassB) && ~isempty(firstPassA) && firstPassA>firstPassB)
            resp(xx,2)=0;
        else
        end
    end
end


%rt =0 means that it reached the deadline without response. We set this
%values to NaN.
resp(resp(:,1)==0,:)=NaN;
end
