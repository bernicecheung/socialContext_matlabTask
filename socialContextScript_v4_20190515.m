close all;
clear all;

%% initialize trial info
nTraitPerRun = 64;
nRun = 4;
catchTrialPortion = 5;
nCatchPerRun = ceil(nTraitPerRun/catchTrialPortion);
nTrialPerRun = nTraitPerRun + nCatchPerRun;
traitDuration = 3;

%% initialize subject data input and output

% create input dialog window
prompt = {'Participant ID:', 'Order','Resume?','Initial run number:','fMRI trigger:'}; % "Resume?": 0- No; 1- Yes; "fMRI trigger": 0 - no trigger; 1- with trigger
tital = 'Input';
dims = [1 35]; 
definput = {'','','0', '1', '1'}; %the default settings for the inputs: no resume; run 1 is the initial run number and with fMRI trigger
dialAns = inputdlg(prompt, tital,dims,definput); %collecting responses

% store input information 
subID = str2num(dialAns{1});
order = str2num(dialAns{2});
resume = str2num(dialAns{3}); 
iRun = str2num(dialAns{4}); 
isfMRI = str2num(dialAns{5}); 

% initialize data output name
c = clock; 
baseName=[dialAns{1} '_socialContext_fMRI_' num2str(c(2))  num2str(c(3)) '_' num2str(c(4))  num2str(c(5)) '.csv'];

% initialize data output.
cHeader = {'subID' 'order' 'resume' 'runNum' 'isfMRI' 'taskPStart' 'currentContext' 'primePStart' 'waitTriggerPStart' 'syncPTime' 'syncDTime' 'triggerStartDTime'...
    'triggerStartPTime' 'initialItiPresentPTime' 'trialInRun' 'currentTrial' 'currentITILength' 'currentOnsetPTime' 'currentTraitIdx' 'currentTraitIdx'...
    'currentCatch' 'currentCatchTrait' 'traitPresentPTime' 'response' 'respTime' 'itiPresentPTime' 'endRunPTime'};
textHeader = strjoin(cHeader, ',');
respCell = cell(1,length(cHeader));
respCell(:) = {'NaN'}; % initialize and use NaN to occupy each column first
fileName = strcat(num2str(baseName)); %name of the file to be stored. 
fid = fopen(fileName,'a'); %open file 
fprintf(fid,'%s\n',textHeader); % generate headers

% store dialog input info
respCell([1:3,5]) = {num2str(subID), num2str(order),num2str(resume), num2str(isfMRI)};
respInput = strjoin(respCell, ','); 
fprintf(fid,'%s\n',respInput);


% %% setup screen
% 
% % setup screen
% screens = Screen('Screens');
% screenNum = max(screens); %use external monitor if it's connected
% Screen('Preference', 'SkipSyncTests', 1) %bypass sync issues if they exist
% % [window,screenRect]= Screen(screenNum,'OpenWindow', [], [0 0 640 480]);  % Open the screen
% 
% [window, screenRect]= PsychImaging('OpenWindow', screenNum);
% [width, height] = Screen('WindowSize',screenNum); %get dimensions
% xCenter = screenRect(3)/2; %set dimensions
% yCenter = screenRect(4)/2; %set dimensions
% HideCursor(); %hide cursor
% 
% % set up colors
% black = BlackIndex(window);
% white = WhiteIndex(window);
% grey = white / 2;
% orange = [255 128 0];

%% setup trial component 

% set randomized seed using participant ID
rng(subID);

% set up fixation cross
fixCrossDimPix = 40;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0]; %where on the x coordinate we want it(middle!)
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix]; %where on the y coordinate we want it (middle!)
allCoords = [xCoords; yCoords]; %adding the x and y coordinates together
lineWidthPix = 4; %the width of the cross

% load prime paragraph
[~,primeAns] = xlsread(strcat(num2str(subID),'_socialPilot.xlsx'));


% load the trait word list
[~,traitWords] = xlsread('selectTrait_64.xlsx','A2:A65');

% randomize the trait index matrix
traitIdxMatrix = zeros(nTraitPerRun,nRun);
for i = 1:nRun
    traitIdxMatrix(:,i) = randperm(nTraitPerRun);
end

% randomly select traits for catch trial and make a matrix of selected
% trait matrix
catchTraitMatrix= zeros(nTraitPerRun,nRun);
for i = 1:nRun
    selectIdx = randsample(nTraitPerRun,nCatchPerRun);
    catchTraitMatrix(selectIdx,i) = 1;
end

% loop through all traits, if it has a catch trial, append [0,1] to the
% catch cell Array, otherwise, append [0]

catchArray = {};

for j = 1:nRun
    catchVector = [];
    for i = 1:nTraitPerRun
        if catchTraitMatrix(i,j) == 0
            catchIdx = 0;
            catchVector = [catchVector,catchIdx];
        elseif catchTraitMatrix(i,j) == 1
            catchIdx = [0,1];
            catchVector = [catchVector,catchIdx];
        end
       
    end
    % bernice changed it
    if catchVector(1,77) == 1
        catchVector(1,76)=1;
        catchVector(1,77)=0;
    end
    
    catchArray{j} = catchVector;
end        

% specify context order and corresponding question and prime
friendQ = 'with your friends';
schoolQ = 'study at school';
friendPrimeQ = 'Please recall a typical scenario where you are hanging out with your close friends on a weekend.';
schoolPrimeQ = 'Please recall a typical scenario where you are studying at UCR(e.g., working on a paper or preparing for an exam).';
showQ = 'Please imagine how well does the trait below describe you when you are';
rateQ = 'Please rate how well does the trait below describe you when you are';


if order == 3
    context = {'friend','school','friend','school'};
    primeQ = {friendPrimeQ,schoolPrimeQ,friendPrimeQ,schoolPrimeQ};
    contextQ = {friendQ,schoolQ,friendQ,schoolQ};
    primeText = {primeAns{1,1},primeAns{2,1},primeAns{1,1},primeAns{2,1}};
       
elseif order == 4
    context = {'school','friend','school','friend'};
    primeQ = {schoolPrimeQ,friendPrimeQ,schoolPrimeQ,friendPrimeQ};
    contextQ = {schoolQ,friendQ,schoolQ,friendQ};
    primeText = {primeAns{2,1},primeAns{1,1},primeAns{2,1},primeAns{1,1}};
    
elseif order == 5
    context = {'friend','school','school','friend'};
    primeQ = {friendPrimeQ,schoolPrimeQ,schoolPrimeQ,friendPrimeQ};
    contextQ = {friendQ,schoolQ,schoolQ,friendQ};
    primeText = {primeAns{1,1},primeAns{2,1},primeAns{2,1},primeAns{1,1}};
    
elseif order == 6
    context = {'school','friend','friend','school',};
    primeQ = {schoolPrimeQ,friendPrimeQ,friendPrimeQ,schoolPrimeQ,};
    contextQ = {schoolQ,friendQ,friendQ,schoolQ,};
    primeText = {primeAns{2,1},primeAns{1,1},primeAns{1,1},primeAns{2,1}}; 
end

% generate a iti matrix (including the last iti, which is 5 seconds)
itiInx = (subID-1)*4;
itiRange = [1 itiInx nTrialPerRun-1 (itiInx+3)];
itiMiddle = csvread('iti_4.csv', 1, itiInx, itiRange);
itiLast = [5 5 5 5];
itiMatrix = [itiMiddle; itiLast];
itiInitialLength = 5;

% for i = 1:nRun
%     itiMatrix(1:nTrialPerRun-1,i) = itiVector(randperm(length(itiVector)));
% end

% specify the onset time for each trait since trigger start based on the
% iti and traitduration

onsetMatrix = ones(nTrialPerRun,nRun)*itiInitialLength; % the first onset time is after the inital iti duration
for j = 1:nRun
    for i = 1:nTrialPerRun 
        onsetMatrix(i+1,j) = itiInitialLength+sum(itiMatrix(1:i,j))+i*traitDuration; %start from the second onset
    end
end
% get rid of the last onset
onsetMatrix(end,:) = [];
%% initialize response
% set up keyboard when the scanner is not connected (i..e, isfMRI ==0)
if isfMRI == 0
    KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
    spaceKey=(KbName('space')); %defines space key
    keyOne = KbName('a');
    keyTwo = KbName('s');
    keyThree = KbName('d');
    keyFour = KbName('f');
    keyFive = KbName('j');
    keySix = KbName('k');
    keySeven = KbName('l');
    activeKeys = [spaceKey keyOne keyTwo keyThree keyFour keyFive keySix keySeven];
end

% set up datapixx when the scanner is connected (i.e., isfMRI ==1)
if isfMRI ==1
    Datapixx('Open'); %open datapixx
    Datapixx('StopAllSchedules'); %
    Datapixx('RegWrRd'); %
    Datapixx('EnableDinDebounce'); %
    % set din number for each button and the trigger
    theTrigger = 11; %
    keyOne = 2;
    keyTwo = 4;
    keyThree = 3;
    keyFour = 1;
    keyFive = 6;
    keySix = 8;
    keySeven = 9;
    targList = [keyOne keyTwo keyThree keyFour keyFive keySix keySeven]; %the target list is the yellow and red buttons
    % set space key for control room access 
    KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
    spaceKey=(KbName('space')); %defines space key
end

%% initialize task

% Task instructions
Screen('TextFont',window, 'Times New Roman'); 
Screen('TextSize',window, 35); 
Screen('TextStyle', window, 0); 
instruction = 'In this task, you are going to imagine yourself hanging out with your friends or studying at UCR,and read the paragraph you wrote about this context. Then, a sets of trait words will be presented on the screen one at the time. You will be asked to imagine how well each trait describes you when you are hanging out with your friends/studying at UCR. Each trait will be presented for 3 seconds. Please take the 3 seconds to think about how well that specific trait describes you when you are in that specific context. Occasionally, instead of a new trait, you will see the same trait appear again. When this happens, you will be asked to provide a rating on a scale from 1 to 7 on how well the trait on the screen describes you. Number 1 means the word doesn?t describe you well at all in that context, and number 7 means that the word describes you very well in that context.';
Screen(window,'FillRect',black);
DrawFormattedText(window,instruction,'center',height*0.15, white,85);
Screen('Flip',window);

% stare queue
devices = PsychHID('Devices');
deviceIdx = GetKeyboardIndices(); 
%KbQueueCreate(deviceIdx,activeKeys); %creates cue using defaults
KbQueueCreate
KbQueueStart;  %starts the cue

%Set up spacebar as a response option so that participants can move forward after reading the
%instructions. 
spacepressed=0;
while spacepressed==0 %
    [pressed, firstPress]=KbQueueCheck(); %looking to see if anything has been pressed
    spacepressed=firstPress(spaceKey); %if the space bar is pressed
    if (pressed && spacepressed) %keeps track of key-presses and draws text
        taskPStart=Screen('Flip',window); %task start psychopy time
    end
end

% record task start time
respCell(6) = {num2str(taskPStart)}; %saving the start time into the column defined earlier
respInput = strjoin(respCell, ',');
fprintf(fid,'%s\n',respInput);

WaitSecs(1);

%% prime and trigger

for runNum = iRun:nRun
    
    currentContext = context{runNum};
    currentContextQ = contextQ{runNum};
    currentPrimeQ = primeQ{runNum};
    currentPrimeText = primeText{runNum};
   
    % show the prime text
    Screen('TextSize',window,40);
    DrawFormattedText(window,currentPrimeQ,'center',height*0.15, white,85);
    DrawFormattedText(window,currentPrimeText,'center',height*0.3, white,85);
    primePStart = Screen('Flip',window);
    
    KbQueueFlush();
    spacepressed=0;
    while spacepressed==0 %
        [pressed, firstPress]=KbQueueCheck(); %looking to see if anything has been pressed
        spacepressed=firstPress(spaceKey); %if the space bar is pressed
    end
    
    % press spacebar to continue
    KbQueueFlush();
    spacepressed=0;
    DrawFormattedText(window,'Are you ready for the next round?','center','center',white);
    waitTriggerPStart=Screen('Flip',window);runNum
    
    while spacepressed==0 %
        [pressed, firstPress]=KbQueueCheck(); %looking to see if anything has been pressed
        spacepressed=firstPress(spaceKey); %if the space bar is pressed
    end
    
    if isfMRI == 0
        % wait for 3 second to pretend that we sense the trigger
        WaitSecs(3);
        triggerStartPTime = Screen('Flip', window); % official run start time in ptb time
        
        % save prime and trigger time
        respCell([4,7:9,13]) = {num2str(runNum),num2str(currentContext),num2str(primePStart),num2str(waitTriggerPStart),num2str(triggerStartPTime)};
        respInput = strjoin(respCell, ',');
        fprintf(fid,'%s\n',respInput);
    end
    
    if isfMRI ==1
        Datapixx('RegWrVideoSync'); % sync between PTB time and Datapixx time
        syncPTime = Screen('Flip', window); % PTB start time stamp
        syncDTime = Datapixx('GetTime'); % datapixx start time stamp
        [Bpress,triggerStartDTime,RespTime,TheButtons] = SimpleWFE(500, theTrigger); % datapixx time when it sense the trigger
        triggerStartPTime2 = syncPTime + (triggerStartDTime-syncDTime);
        triggerStartPTime = GetSecs; % PTB time immediately followed when datapixx sense the trigger
        
        % save prime, time stamps for synchronization and tigger time
        respCell([4,7:13]) = {num2str(runNum),num2str(currentContext),num2str(primePStart),num2str(waitTriggerPStart),num2str(syncPTime),num2str(syncDTime),num2str(triggerStartDTime),num2str(triggerStartPTime)};
        respInput = strjoin(respCell, ',');
        fprintf(fid,'%s\n',respInput);
    end
    
    %% present traits & catch trials
    currentTrial = (runNum-1) * nTrialPerRun +1;
    currentTraitCount = 1;
    % present initial iti
    Screen(window,'FillRect',black);
    Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter]);
    initialItiPresentPTime = Screen('Flip', window);
    % store initial iti info.
    respCell(14) ={num2str(initialItiPresentPTime)};
    respInput = strjoin(respCell, ',');
    fprintf(fid,'%s\n',respInput);
    
    %adjust text size
    

    for trialInRun = 1:nTrialPerRun
        % extract time info. & trait for current trial
        currentITILength = itiMatrix(trialInRun,runNum);
        currentOnsetPTime = onsetMatrix(trialInRun,runNum);
        currentTraitIdx = traitIdxMatrix(currentTraitCount,runNum);
        currentTrait = traitWords{currentTraitIdx};
        
        % check if this is a catch trial
        currentCatch = catchArray{runNum}(trialInRun);
        respCell(15:18) = {num2str(trialInRun),num2str(currentTrial),num2str(currentITILength),num2str(currentOnsetPTime)};

        
        if currentCatch == 1
            % use the trait presented in the last trial as the catch trait
            currentCatchIdx = traitIdxMatrix(currentTraitCount-1,runNum);
            currentCatchTrait = traitWords{currentCatchIdx};
            % presents stimuli at currentOnsetPTime after triggerPTime
            Screen('TextSize',window,35);
            DrawFormattedText(window,rateQ,width*0.1,height/4,white);
            DrawFormattedText(window,currentContextQ,width*0.8,height/4,orange);
            Screen('TextSize',window,62);
            DrawFormattedText(window,currentCatchTrait,'center','center',orange);
            DrawFormattedText(window,'1',width*0.2,height*0.7,white);
            DrawFormattedText(window,'2',width*0.3,height*0.7,white);
            DrawFormattedText(window,'3',width*0.4,height*0.7,white);
            DrawFormattedText(window,'4','center',height*0.7,white);
            DrawFormattedText(window,'5',width*0.6,height*0.7,white);
            DrawFormattedText(window,'6',width*0.7,height*0.7,white);
            DrawFormattedText(window,'7',width*0.8,height*0.7,white);
            traitPresentPTime = Screen('Flip', window, currentOnsetPTime + triggerStartPTime);
            
            % record response
            response = -99;
            respTime = -99;
            if isfMRI == 0
                KbQueueFlush();
                keypressed = 0;
                %Waitsecs(traitDuration) % wait for response for 3 seconds
                while keypressed==0 && GetSecs() <= traitPresentPTime + traitDuration
                    [pressed, firstPress]=KbQueueCheck();
                    if (pressed)
                        keypressed = 1;
                        firstPress(firstPress==0)=NaN; % get rid of 0s in teh firstPress
                        [keyPreSec keyPressed]=min(firstPress);
                        if keyPressed == keyOne
                            response = 1;
                        elseif keyPressed == keyTwo
                            response = 2;
                        elseif keyPressed == keyThree
                            response = 3;
                        elseif keyPressed == keyFour
                            response = 4;
                        elseif keyPressed == keyFive
                            response = 5;
                        elseif keyPressed == keySix
                            response = 6;
                        elseif keyPressed == keySeven
                            response = 7;
                        end
                        
                        respTime = keyPreSec - traitPresentPTime;
                    end % end of pressed
                    
                end % end keypressed while
                
            end % end of non-fMRI response
            
            if isfMRI ==1
                [bPress,keyPreSec,respTime,TheButtons] = SimpleWFE(3, targList);
                if (bPress) % if get a response
                    if TheButtons == 1
                        response = 1;
                    elseif TheButtons == 2
                        response = 2;
                    elseif TheButtons == 3
                        response = 3;
                    elseif TheButtons == 4
                        response = 4;
                    elseif TheButtons == 5
                        response = 5;
                    elseif TheButtons == 6
                        response = 6;
                    elseif TheButtons == 7
                        response = 7;
                    end
                    
                end % end of Bpress
            end % end of fMRI response
            
            % record response
            respCell([19,20]) = {'NaN'};
            respCell(21:25) = {num2str(currentCatch),num2str(currentCatchTrait),num2str(traitPresentPTime),num2str(response),num2str(respTime)};
            currentTrial = currentTrial+1;
            
        elseif currentCatch == 0
            
            
            % presents stimuli at currentOnsetPTime after triggerPTime
            Screen('TextSize',window,35);
            DrawFormattedText(window,showQ,width*0.2,height/4,white);
            DrawFormattedText(window,currentContextQ,width*0.8,height/4,orange);
            Screen('TextSize',window,62);
            DrawFormattedText(window,currentTrait,'center','center',orange);
            traitPresentPTime = Screen('Flip', window, currentOnsetPTime + triggerStartPTime);
            
            % record trait present time
            respCell([21,22,24,25]) = {'NaN'};
            respCell([19,20,23]) = {num2str(currentTraitIdx),num2str(currentTrait),num2str(traitPresentPTime)};
            % move to the next trial and trait
            currentTrial = currentTrial+1;
            currentTraitCount = currentTraitCount+1;
        end % catch
        
        % present a iti 3 second after the trait get presented
        
        Screen(window,'FillRect',black);
        Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter]);
        itiPresentPTime = Screen('Flip', window,traitPresentPTime + traitDuration);
        
        respCell(26) = {num2str(itiPresentPTime)};
        respInput = strjoin(respCell, ',');
        fprintf(fid,'%s\n',respInput);
        
    end % end of trial

    Screen(window,'FillRect',black); % clear to black
    endRunPTime = Screen('Flip', window);
    
    respCell(27) = {num2str(endRunPTime)};
    respInput = strjoin(respCell, ',');
    fprintf(fid,'%s\n',respInput);
    % press a key to continue
    KbWait(-3); 
   
 
end % end of run    

%% close everything
Datapixx('Close')
fclose(fid);
sca;
