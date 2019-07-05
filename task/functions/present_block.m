function data = present_block(qdelay,qttimes,stimdur,ntrials,cueval,nperccatch,brightnesses,blocknum,keyCodes,BIOSEMI,q1,q2,freq,rsize,rwith,tsize)

% trial number
% block number
% condition
% motion direction (1, left; 2, right)
% stimulus brierence in percent
% RT in seconds
% response code
% accuracy (correct or incorrect, 1 or 0)
% false alarm (yes or no, 1 or 0)
% time on block

global task_version
global rootdir
global ioObj;
% global status;
global address;
global target
global xCenter
global yCenter
global fsize

imagesdir   =   [rootdir '\images\feedback\' ];



%compute the number of catch trials
ncatch = round(ntrials*(nperccatch/100)); %the number of catch trials

%now determine the rest of the trials
nremtrials = ntrials - ncatch; %the number of remaining (non-catch) trials

n_short_val_eas = round((nremtrials/2) * (cueval / 100) * .5); %the number short interval trials that are validly cued and easy
n_short_val_dif = round((nremtrials/2) * (cueval / 100) * .5); %the number short interval trials that are validly cued and difficult
n_short_inval_eas = round((nremtrials/2) * (1-cueval / 100) * .5); %the number short interval trials that are invalidly cued and easy
n_short_inval_dif = round((nremtrials/2) * (1-cueval / 100) * .5); %the number short interval trials that are invalidly cued and difficult

n_long_val_eas = round((nremtrials/2) * (cueval / 100) * .5); %the number long interval trials that are validly cued and easy
n_long_val_dif = round((nremtrials/2) * (cueval / 100) * .5); %the number long interval trials that are validly cued and difficult
n_long_inval_eas = round((nremtrials/2) * (1-cueval / 100) * .5); %the number long interval trials that are invalidly cued and easy
n_long_inval_dif = round((nremtrials/2) * (1-cueval / 100) * .5); %the number long interval trials that are invalidly cued and difficult

conditions = ones(n_short_val_eas,1)*100;
conditions = [conditions; ones(n_short_val_dif,1)*101];
conditions = [conditions; ones(n_short_inval_eas,1)*110];
conditions = [conditions; ones(n_short_inval_dif,1)*111];

conditions = [conditions; ones(n_long_val_eas,1)*200];
conditions = [conditions; ones(n_long_val_dif,1)*201];
conditions = [conditions; ones(n_long_inval_eas,1)*210];
conditions = [conditions; ones(n_long_inval_dif,1)*211];

%in case the percentage cue validity won't round off to a whole number of
%trials, adjust the total number of trials to accomodate
if length(conditions) ~= ntrials - ncatch 
    data = zeros(ncatch+length(conditions),10);
    warning(['total number of trials (' num2str(ntrials) ') per block adjusted (' num2str(size(data,1)) ') to accomodate cue validity'])
    ntrials = size(data,1);
end

%initialize the data matrix
data = zeros(ntrials,11);

%enter block number
data(:,2) = zeros(size(data,1),1)+blocknum;
% enter the conditions
data(1:ncatch,3) = 10; data(ncatch+1:end,3) = conditions;
%enter direction
data(round(1:size(data,1)/2),4) = -2; data(:,4) = data(:,4) + 1;
data(:,4) = data(randsample(1:ntrials,ntrials),4); %shuffle target position


%shuffle trials so that the order is randomized
data = data(randsample(1:ntrials,ntrials),:);
data = data(randsample(1:ntrials,ntrials),:);
data = data(randsample(1:ntrials,ntrials),:);

%enter trial numbers
data(:,1) = 1:size(data,1);

%condition information: First number (short/long) Second number (valid/invalid) Third number (easy/difficult)
% 10 = catch

% 100 = short interval, validly cued, easy
% 101 = short interval, validly cued, difficult
% 110 = short interval, invalidly cued, easy
% 111 = short interval, invalidly cued, difficult

% 200 = long interval, validly cued, easy
% 201 = long interval, validly cued, difficult
% 210 = long interval, invalidly cued, easy
% 211 = long interval, invalidly cued, difficult

blockstart = GetSecs;
% loop over trials
for triali = 1:size(data,1)
      
    condition = data(triali,3);
    direction = data(triali,4);
    
    %trial settings
        switch condition
        case 10
            delaytime = max(qttimes) + qdelay; %the total time it takes for the target to come on
            if rand(1) > 0.5
                q = q1;
                qnum = 1;
            else
                q = q2;
                qnum = 2;
            end
            bri = 1;
            
        %short interval trials
        case 100 %short interval, validly cued, easy
            delaytime = min(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q1;
            qnum = 1;
            bri = min(brightnesses);
        case 101 %short interval, validly cued, difficult
            delaytime = min(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q1;
            qnum = 1;
            bri = max(brightnesses);
        case 110 %short interval, invalidly cued, easy
            delaytime = min(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q2;
            qnum = 2;
            bri = min(brightnesses);
        case 111 %short interval, invalidly cued, difficult
            delaytime = min(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q2;
            qnum = 2;
            bri = max(brightnesses);
        %long interval trials    
        case 200 %long interval, validly cued, easy
            delaytime = max(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q2;
            qnum = 2;
            bri = min(brightnesses);
        case 201 %long interval, validly cued, difficult
            delaytime = max(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q2;
            qnum = 2;
            bri = max(brightnesses);
        case 210 %long interval, invalidly cued, easy
            delaytime = max(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q1;
            qnum = 1;
            bri = min(brightnesses);
        case 211 %long interval, invalidly cued, difficult
            delaytime = max(qttimes) + qdelay; %the total time it takes for the target to come on
            q = q1;
            qnum = 1;
            bri = max(brightnesses);
    end
   
    
    %% run the trial
    [Press1,RT1,Press2,RT2] = present_trial(delaytime,stimdur,keyCodes,BIOSEMI,condition,direction,bri,q,freq,rsize,rwith,tsize);
    
    %% enter remaining variables into the data matrix
    data(triali,5) = bri;
    data(triali,11) = qnum;
    
    %get the RT
    if ~isempty(find(Press1,1))
        data(triali,6) = RT1;
        data(triali,7) = find(Press1,1);
    elseif (isempty(find(Press1,1)) && isempty(find(Press2,1))) 
        data(triali,6) = 0;
    elseif isempty(find(Press1,1)) && ~isempty(find(Press2,1))
        data(triali,6) = RT2;
        data(triali,7) = find(Press2,1);
    end
    %recode RT to be seconds relative to target onset (so negative RTs are
    %premature responses, i.e. false alarms)
    if data(triali,6) ~= 0
        data(triali,6) = data(triali,6)-(delaytime/1000);
    end
    
    %compute accuracy
    %if we're doing a detection task
    if task_version == 1        
        if data(triali,3) == 10 && data(triali,6) == 0 %if this is a catch trial and no response was given
            data(triali,8) = 1; %correct witheld response
        elseif data(triali,3) == 10 && data(triali,6) ~= 0 %catch trial but a response was given
            data(triali,9) = 1; %false alarm
        elseif data(triali,6) < 0 %if the participant responded before target onset
            data(triali,9) = 1; %false alarm
        elseif data(triali,3) ~= 1 && data(triali,6) > 0 %not a catch trial, and participant responded after stim onset
            data(triali,8) = 1; %correct response
        end
    %if we're doing a discrimination task
    elseif task_version == 2
        if data(triali,3) == 10 && data(triali,6) == 0 %if this is a catch trial and no response was given
            data(triali,8) = 1; %correct witheld response
        elseif data(triali,3) == 10 && data(triali,6) ~= 0 %catch trial but a response was given
            data(triali,9) = 1; %false alarm
        elseif data(triali,6) < 0 %if the participant responded before target onset
            data(triali,9) = 1; %false alarm            
        elseif data(triali,3) ~= 1 && data(triali,6) > 0 %not a catch trial, and participant responded after stim onset
            if keyCodes(data(triali,4)) ==  data(triali,7) %if the given response and the motion direction agree
                data(triali,8) = 1; %correct response
            end
        end
    end
    %enter time on block
    data(triali,10) = GetSecs-blockstart;
    if data(triali,8) == 1
        trialtype = ['correct, RT = ' num2str(data(triali,6)) 's'];
    elseif data(triali,8) == 0 && data(triali,9) == 0
        trialtype = 'error';
    elseif data(triali,9) == 1
        trialtype = 'false alarm';
    end
    
    %display trial statistics on screen
    clc
    disp(['Block ' num2str(blocknum) ', trial ' num2str(triali) ': ' trialtype]);
    
    %% send feedback marker
    
    clear marker
    if (data(triali,8) == 1) && (condition ~= 10) %hit trial
        marker = 1;
    elseif (data(triali,8) == 0) && (condition ~= 10) && (data(triali,9) == 0) %miss trial
        marker = 2;
    elseif (data(triali,9) == 1) && (condition == 10) %catch false alarm
        marker = 3;
    elseif (data(triali,9) == 1) && (condition ~= 10) %non-catch false alarm
        marker = 4;
    elseif (data(triali,9) == 0) && (condition == 10) %correct rejection   
        marker = 5;
    end
        
    if BIOSEMI; io64(ioObj,address,marker);
        WaitSecs(0.005); io64(ioObj,address,0);
    end
       
end



