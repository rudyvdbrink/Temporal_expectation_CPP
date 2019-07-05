function [stampStim1,stampStim2,Press1,RT1,Press2,RT2] = drawbox(duration1,duration2,dont_clear, specific_keys, BIOSEMI, Condition,direction,coh,pahandle)



global rootdir
global ioObj;
global address;
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

imagesdir   =   [rootdir '\images\feedback\'];

%%

faimg = imread([imagesdir '\false_alarm.JPG'], 'jpg');
imTex = Screen('MakeTexture',window,faimg);

stampStim1 = [];
stampStim2 = [];

duration1 = (duration1)/1000;
duration2 = (duration2)/1000;


keyIsDown = 0;
keyCode1 = [];
keyCode2 = [];
pressed = 0;
Press1 = [];
Press2 = [];
RT1 = 0;
RT2 = 0;
fa = 0;

%determine target position
centeredTarg     = CenterRectOnPointd(target, xCenter-((rsize/2-rwith/2)*direction), yCenter);

% Draw the square to the screen. For information on the command used in
% this line see Screen FillRect?
Screen('FillRect', window, rectColor, centeredBaseRect);
Screen('FillRect', window, [0 0 0], centeredCentRect);
Screen('DrawDots', window, [xCenter yCenter],fsize,[1 1 1],[0 0],1);

% draw stimulus
Screen('Flip', window);

start_time1 = GetSecs;
played = 0;
started = 0;
while GetSecs - start_time1 < duration1 % dsiplay box for duration1
    
    %play cue tone
    if GetSecs - start_time1 > 1.5 && played == 0
        %play the cue
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        played = 1;
        %CUE MARKER
        if BIOSEMI; io64(ioObj,address,6);
            WaitSecs(0.005); io64(ioObj,address,0);
        end
    end
    
    % sending stimulus message to EEG
    if started==0
        % sending condition trigger to start trial
        %BOX ONSET MARKER
        if BIOSEMI
            io64(ioObj,address,Condition+30);
            WaitSecs(0.005);
            io64(ioObj,address,0);
            
        end  %%%%%%%%            BIOSEMI TRIGGER
        timeS = GetSecs;        % Remember time dots started
        started = 1;
    end
    
    [keyIsDown, secs, keyCode1] = KbCheck; %record key-presses during first display
    if sum(logical(keyCode1)) > 1; keyCode1(find(keyCode1,1)) = 0; end
    
    if pressed == 1
        if keyIsDown == 0
            pressed = 0; % once a key has been pressed, listen for release and mark it
        end       
        
        %draw false alarm screan
        Screen('DrawTexture', window, imTex); % put image on screen
        Screen('Flip',window); % now visible on screen
        WaitSecs(1); %wait one second
        stampStim2 = [];
        fa = 1; %this is a false alarm trial
        
        break
    end
    
    % break out is escape is pressed
    if keyCode1(KbName('ESCAPE')); memory; sca ; end
    
    if ~isempty(find( keyCode1==1,1)) % if the press matches one of the possible responses, and this is the first onset of the press
        
        if ~isempty(find(specific_keys == (find( keyCode1==1,1)))) && pressed == 0 % only record a new press if first press has been released
            pressed = 1;
            if isempty(Press1) %if first press has not been recorded record this as the first press and log RT
                if BIOSEMI; io64(ioObj,address,7);
                    WaitSecs(0.005); io64(ioObj,address,0);
                end  %%%%%%%%            BIOSEMI TRIGGER for first response
                RT1      = secs-start_time1;
                Press1   = keyCode1;
                
            elseif isempty(Press2) %if first press has ALREADY been recorded (and key was released) then record this as the second press and log RT
                if BIOSEMI; io64(ioObj,address,7);
                    WaitSecs(0.005); io64(ioObj,address,0);
                end  %%%%%%%%            BIOSEMI TRIGGER for first response
                RT2      = secs - start_time1;
                Press2   = keyCode1;
                NetStation('Event', 'Error');
            end
        end
    end
    
end


%%
if ~fa %if tis is not a false alarm trial
    Screen('FillRect', window, rectColor, centeredBaseRect); %base box
    Screen('FillRect', window, [0 0 0], centeredCentRect); %center box
    Screen('FillRect', window, coh, centeredTarg); %target
    Screen('DrawDots', window, [xCenter yCenter],fsize,[1 1 1],[0 0],1); %fixation    
    Screen('Flip', window);   
    
    start_time2 = GetSecs;
    while GetSecs - start_time2 < duration2
        
        % sending stimulus message to EEG
        if started==1
            %TARGET MOTION ONSET MARKER
            if BIOSEMI; io64(ioObj,address,Condition);
                WaitSecs(0.005); io64(ioObj,address,0);
            end  %%%%%%%%            BIOSEMI TRIGGER
            timeS = GetSecs;        % Remember time dots started
            started = 2;
        end
        
        
        
        %% GET a Response
        
        [keyIsDown, secs, keyCode2] = KbCheck; %record key-presses during first display
        if sum(logical(keyCode2)) > 1; keyCode2(find(keyCode2,1)) = 0; end
        
        if pressed == 1
            if keyIsDown == 0
                pressed = 0; % once a key has been pressed, listen for release and mark it
            end
            
            %catch trial
            if Condition == 10
                %draw false alarm screan
                Screen('DrawTexture', window, imTex); % put image on screen
                Screen('Flip',window); % now visible on screen
                WaitSecs(1); %wait one second
                stampStim2 = [];
                fa = 1; %this is a false alarm trial
                break
            end
        end
        
        % break out is escape is pressed
        if keyCode1(KbName('ESCAPE')); sca ; end
        
        if ~isempty(find(keyCode2==1,1)) % if the press matches one of the possible responses, and this is the first onset of the press
            if ~isempty(find(specific_keys==(find( keyCode2==1,1)))) && pressed == 0
                pressed = 1;
                if isempty(Press1) %if first press has not been recorded record this as the first press and log RT
                    if BIOSEMI
                        io64(ioObj,address,7);
                        WaitSecs(0.005); io64(ioObj,address,0);
                    end  %%%%%%%%            BIOSEMI TRIGGER for first response
                    RT1      = secs-start_time1;
                    Press1   = keyCode2;
                elseif isempty(Press2) %if first press has ALREADY been recorded (and key was released) then record this as the second press and log RT
                    if BIOSEMI; io64(ioObj,address,7);
                        WaitSecs(0.005); io64(ioObj,address,0);
                    end %%%%%%%%            BIOSEMI TRIGGER for first response
                    RT2      = secs-start_time1; % if second response in second epoch, then measure RT from moment of onset of second epoch;
                    Press2   = keyCode2;
                end
            end
        end
        
        
    end %end while loop
end %end if FA loop

Screen('DrawingFinished',window,1);



end