%% Temporal cueing paradigm 
% RL van den Brink, 2016

%% Data output information: 
%Behavioral data are saved per individual block as a tab separated text
%file, and with all blocks concatinated as a matlab .mat file. 

%Output matrix 'data' has 10 columns, with the following variables:
%1)  trial number within block
%2)  block number
%3)  condition (see below)
%4)  target position (1, left; -1, right)
%5)  stimulus difficulty
%6)  RT in seconds
%7)  response code
%8)  accuracy (correct or incorrect, 1 or 0)
%9)  false alarm (yes or no, 1 or 0)
%10) time on block
%11) cue number (1 = low, 2 = high)

%condition information: First number (short/long); Second number (valid/invalid); Third number (easy/difficult)
% 10 = catch

% 100 = short interval, validly cued, easy
% 101 = short interval, validly cued, difficult
% 110 = short interval, invalidly cued, easy
% 111 = short interval, invalidly cued, difficult

% 200 = long interval, validly cued, easy
% 201 = long interval, validly cued, difficult
% 210 = long interval, invalidly cued, easy
% 211 = long interval, invalidly cued, difficult


%EEG trigger information:

%stimulus markers:
%  trial start is indicated by trigger same as condition+30 (see above)
%  6: cue onset
%  target onset is indicated by trigger condition (see above)

%response marker:
%  7: key press

%feedback triggers:
%   1: hit trial
%   2: miss tiral
%   3: false alarm on catch trial
%   4: false alarm on non-cath trial
%   5: correct reject trial

%block markers:
% 60: start of real task

%% clear contents
close all
clear 
clc
Screen('CloseAll')

p = pathdef;
addpath(p)
%% set some globals 
global task_version
global rootdir
global nblocks
global npblocks
global blocknum
global pblocknum
global subnum
global ioObj 
global status 
global address
global window
global centeredBaseRect;
global centeredCentRect;
global target;
global xCenter;
global yCenter;
global fsize
global rsize
global rwith
global rectColor
global iti
global lspace

%% task settings 
% task_version = 1; % (1 = detection, 2 = discrimination), this is set via the input dialog
nblocks      = 8; %number of blocks    
npblocks     = 2; %number of practice blocks
cueval       = 80; %cue validity in percent
nperccatch   = 13; %percentage of catch trials
ntrials      = 115; %number of trials per block
nptrials     = 24; %number of practice trials per practice block
qdelay       = 1500; %time between stimulus onset and cue presentation in ms
qttimes      = [1350 2700]; %cue-target intervals in ms (short and long)
stimdur      = 1000; %target duration in ms
iti          = 0.05; %inter trial interval (only fixation visible)

%stimulus properties
difficulty   = [0.72 0.8]; %brightness of target: easy (first number) and difficult (second number) conditions, higher number = more difficult 
rsize        = 60;
rwith        = 8;
tsize        = 10;
fsize        = 8; %size of fixation dot
rectColor    = [1 1 1];

%line spacing for instructions and feedback
lspace       = 1.2; 

%% folder information

rootdir = pwd; %the current folder (where the file task.m is saved)
rootdir = rootdir(1:end-8); %one folder up from the current folder
datadir = [rootdir '\data\'];  % folder for saving behaviour 
cuedir  = [rootdir '\cues\'];  % folder where the cues (sound files) are saved
addpath(genpath([rootdir '\functions'])); %add the folder with sub functions to matlab's path 

%% pop-up input dialog with participant information and task
prompt = {'Participant number','Task',        'EEG',   'Age','Gender','Screen width','Viewing distance'}; %the variables in the input dialog
def    = {'0',                 '1',           '1',     '0',  'F',     '37.5',          '90'}; %the default settings
answer = inputdlg(prompt, 'Experimental setup information',1,def); %show the input dialog
         [subnum,               task_version, BIOSEMI, age,  gender,  width,         distance] = deal(answer{:});
         
%convert string variables to numbers         
subnum       = str2double(subnum);
task_version = str2double(task_version);
width        = str2double(width);
distance     = str2double(distance);
BIOSEMI      = str2double(BIOSEMI);

if task_version == 1; task_name = 'detection'; 
elseif task_version == 2; task_name = 'discrimination'; 
end

%initialize EEG 
if BIOSEMI
    ioObj = io64; 
    status = io64(ioObj);
    address = hex2dec('C010');
    io64(ioObj,address,0);
end

%% some general settings
if task_version == 1
    keyCodes = [32 32]; %space bar
    keyLabels = ['L' 'R'];
elseif task_version == 2
    keyCodes = [162 163]; %left and right control keys
    keyLabels = ['L' 'R'];
end
data = []; pdata = [];
blocknum = 0;

% set beep off (annoying)
beep off
warning('off','MATLAB:dispatcher:InexactMatch')
% set keys same for windows or mac
KbName('UnifyKeyNames')

%% load sound stimuli (and counterbalance)

%load cues
[q2,    ~] = audioread([cuedir 'Cue1.wav']);
[q1, freq] = audioread([cuedir 'Cue2.wav']);

%stack the cues so that we have two-channel audio
q1 = [q1'; q1']; 
q2 = [q2'; q2']; 
InitializePsychSound

%% initialize the display settings

Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%font settings for feedback and instruction
Screen('TextFont',window, 'Geneva');
Screen('TextSize',window, 40);
Screen('TextStyle', window, 0);

%% generate visual stimuli

baseRect = [0 0 rsize rsize];
centRect = [0 0 rsize-rwith*2 rsize-rwith*2];
target   = [0 0 rwith tsize];
centeredBaseRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
centeredCentRect = CenterRectOnPointd(centRect, xCenter, yCenter);

%% run practice 

%first, present instructions
present_instructions(q1,q2,freq);
for pblocknum = 1:npblocks       
    
    %the function below loops across trials within a block
    pblockdat = present_block(qdelay,qttimes,stimdur,nptrials,100,0,difficulty,pblocknum,keyCodes,BIOSEMI,q1,q2,freq,rsize,rwith,tsize);
    pdata = cat(1,pdata,pblockdat);
    
    %save data at the end of the block
    C=clock;
    dlmwrite([datadir '\' task_name '\TESD_Practice_' num2str(subnum) '_block_' num2str(pblocknum) '_' date '_' num2str(C(4)) '_' num2str(C(5)) '.txt'],pblockdat,'\t');

    %compute performance measures for the practice block
    blockacc = round(sum(pblockdat(:,8))/size(pblockdat,1)*100); %the accuracy on this block in percent
    blockcrt = round(mean(nonzeros(pblockdat(logical(pblockdat(:,8)),6)))*100)/100; %the average correct RT in seconds
    blockfar = round(sum(pblockdat(:,9))/size(pblockdat,1)*100); %the false alarm rate on this block in percent
    
    %present performance feedback at the end of the block
    present_blockfeedback(blockcrt,blockacc,blockfar,nblocks,blocknum,npblocks,pblocknum);
end


%% run the full task

%send marker to signal the start of the real task
if BIOSEMI; io64(ioObj,address,60);
    WaitSecs(0.005); io64(ioObj,address,0);
end

try
    for blocknum = 1:nblocks
        
        %the function below loops across trials within a block
        blockdat = present_block(qdelay,qttimes,stimdur,ntrials,cueval,nperccatch,difficulty,blocknum,keyCodes,BIOSEMI,q1,q2,freq,rsize,rwith,tsize);
        data = cat(1,data,blockdat);
        
        %save data at the end of the block
        C=clock;
        dlmwrite([datadir '\' task_name '\TESD_' num2str(subnum) '_block_' num2str(blocknum) '_' date '_' num2str(C(4)) '_' num2str(C(5)) '.txt'],blockdat,'\t');
        
        %compute performance measures for this block
        blockacc = round(sum(blockdat(:,8))/size(blockdat,1)*100); %the accuracy on this block in percent
        blockcrt = round(mean(nonzeros(blockdat(logical(blockdat(:,8)),6)))*100)/100; %the average correct RT in seconds
        blockfar = round(sum(blockdat(:,9))/size(blockdat,1)*100); %the false alarm rate on this block in percent
        
        %present performance feedback at the end of the block
        present_blockfeedback(blockcrt,blockacc,blockfar,nblocks,blocknum,npblocks,pblocknum);
    end
catch ME
    %save final data
    C=clock;
    dlmwrite([datadir '\' task_name '\TESD_' num2str(subnum) '_alldata_' date '_' num2str(C(4)) '_' num2str(C(5)) '.txt'],data,'\t');
    save([datadir '\' task_name '\TESD_' num2str(subnum) '_alldata_' date '_' num2str(C(4)) '_' num2str(C(5)) '.mat'],'data','task_name','age','gender');
    sca
end

C=clock;
save([datadir '\' task_name '\TESD_' num2str(subnum) '_alldata_' date '_' num2str(C(4)) '_' num2str(C(5)) '.mat'],'data','task_name','age','gender');
dlmwrite([datadir '\' task_name '\TESD_' num2str(subnum) '_alldata_' date '_' num2str(C(4)) '_' num2str(C(5)) '.txt'],data,'\t');

%% clear the screen
sca



