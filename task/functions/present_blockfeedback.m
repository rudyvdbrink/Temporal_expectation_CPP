function present_blockfeedback(rt,acc,farate,nblocks,blocknum,npblocks,pblocknum)

global window
global lspace

%if practice isn't over yet
if blocknum < nblocks && pblocknum ~= npblocks    
    
[nx, ny] = DrawFormattedText(window, ['Practice block ' num2str(pblocknum) ' out of ' num2str(npblocks) '\n\n' ...
                                      'Response time: ' num2str(rt) ' seconds \n' ...
                                      'Accuracy: ' num2str(acc) '% \n'   ...
                                      'FA rate: ' num2str(farate) '%'
                                                                ] ...
                                      , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
        
        [nx, ny] = DrawFormattedText(window, 'Remember to always look at the dot,\n and to use the cues \n to respond as fast as possible!\n High tone: short delay,\n low tone: long delay. \n\n Ready to continue?'  ...
        , 'center', 'center', 1,[0 0 0]);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
        
%if the practice is over, but the real task hasn't yet started
elseif blocknum == 0 && pblocknum == npblocks
    
    [nx, ny] = DrawFormattedText(window, ['Practice block ' num2str(pblocknum) ' out of ' num2str(npblocks) '\n\n' ...
                                      'Response time: ' num2str(rt) ' seconds \n' ...
                                      'Accuracy: ' num2str(acc) '% \n'   ...
                                      'FA rate: ' num2str(farate) '%'
                                                                ] ...
                                      , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
        
        [nx, ny] = DrawFormattedText(window, 'Remember to always look at the dot,\n and to use the cues \n to respond as fast as possible!\n High tone: short delay,\n low tone: long delay. \n\n Ready for the real task?'  ...
        , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
        
%if the real task has started, but it's not over yet
elseif pblocknum == npblocks && blocknum ~= nblocks
    [nx, ny] = DrawFormattedText(window, ['Block ' num2str(blocknum) ' out of ' num2str(nblocks) '\n\n' ...
                                      'Response time: ' num2str(rt) ' seconds \n' ...
                                      'Accuracy: ' num2str(acc) '% \n'   ...
                                      'FA rate: ' num2str(farate) '%'
                                                                ] ...
                                      , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
        
        [nx, ny] = DrawFormattedText(window, 'Remember to always look at the dot,\n and to use the cues \n to respond as fast as possible!\n High tone: short delay,\n low tone: long delay. \n\n Ready to continue?'  ...
        , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
%if this was the last block
elseif  pblocknum == npblocks && blocknum == nblocks
[nx, ny] = DrawFormattedText(window, ['Block ' num2str(blocknum) ' out of ' num2str(nblocks) '\n\n' ...
                                      'Response time: ' num2str(rt) ' seconds \n' ...
                                      'Accuracy: ' num2str(acc) '% \n'   ...
                                      'FA rate: ' num2str(farate) '%'
                                                                ] ...
                                      , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
        
        [nx, ny] = DrawFormattedText(window, 'Thank you for participating!'  ...
        , 'center', 'center', 1,[0 0 0],[],[],lspace);
        Screen('DrawText', window, ' ', nx, ny, [255, 0, 0, 255]);
        Screen('Flip',window);
                
        KbStrokeWait; %wait for a button press
end
        

end





