function [Bpress,Etime,RespTime,TheButtons] = SimpleWFE(responsetime, TargList)
%TargList;  red=1, yellow=2, green=3, blue=4,trigger=9

Etime=[];
RespTime=-99;
TheButtons=[];
% initializes values to assume nothing is pressed
Bpress=0; %initializes button press to false
Datapixx('RegWrRd'); %checks in with datapixx
startDtime=Datapixx('GetTime'); %initializes starttime
while ( (Datapixx('GetTime') < (startDtime + responsetime) ) && ~Bpress) %checks for response time limit or button press
    dinValues = Datapixx('GetDinValues'); %gets current values
    binaryvals=dec2bin(dinValues); %convert triggers to binary values
    binaryvals=binaryvals(end:-1:1); %reorder to left to right
        if any(str2num(binaryvals(TargList))) %checks to see if any target event has occured
            Bpress=1; % states that a button has been pressed
            TheButtons=find(binaryvals(TargList)=='1'); %looks for which button was pressed; return the index of the button from the TargList
            Etime =Datapixx('GetTime'); 
            RespTime=Etime-startDtime; % save time of first button press
        end
        Datapixx('RegWrRd');  %checks in with datapixx
        WaitSecs(.002); % avoids tight loop
end

