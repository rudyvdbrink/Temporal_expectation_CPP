function [Press1,RT1,Press2,RT2] = present_trial(delaytime,stimtime,keyCodes,BIOSEMI,condition,direction,coh,q,freq,rsize,rwith,tsize)
 
global practice
global subnum
global task_version
global window
global xCenter;
global yCenter;
global fsize
global iti

Screen('DrawDots', window, [xCenter yCenter],fsize,[1 1 1],[0 0],1);
Screen('Flip', window);
WaitSecs(iti)

%fill the audio playback buffer with the audio data (the auditory cue):
pahandle = PsychPortAudio('Open', [], [], 0, freq, 2);
PsychPortAudio('FillBuffer', pahandle, q);

%present the stimulus
[~,~,Press1,RT1,Press2,RT2] = drawbox(delaytime,stimtime,[],keyCodes, BIOSEMI, condition,direction,coh, pahandle);  %Draw the stimulus and record a response; returns RT

%clear the screen and audio port
PsychPortAudio('Close', pahandle);
