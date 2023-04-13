%% Script to use data from leap motion
%the goal of this script is to set up the leap motion and then grab data
%from it to confirm if the hands are in a fist, holding needles, or at rest
thisPath = cd;
cd('C:\GitHub\MiniVIE');
MiniVIE.configurePath;
cd(thisPath);

leap = Inputs.LeapMotion;
leap.initialize();

%% Relaxed hand
relaxed = leap.getData();
relaxed=get_leap_position(relaxed);

%% Fist
fist = leap.getData();
fist=get_leap_position(fist);

%% Holding Needle
needle = leap.getData();
needle=get_leap_position(needle);
%turns out fist and needle are too similar
%% Confirm there are 2 hands
frame=leap.getData();
if frame.hands == 2
    disp('There are 2 hands, knit.')
elseif frame.hands ==1
    disp('There is 1 hand, move robot into position.')
end

%% Testing 
%loop where the leap gets frames until I say stop and then decides if the
%we're steering, knitting, or resting.

StartStopForm([])
while StartStopForm
    drawnow;
    frame = leap.getData();
    if isempty(frame)
        disp('Rest')
    elseif frame.hands ==1
        temp=get_leap_position(frame);
        c1=get_leap_class(temp(1));
        if strcmp(c1,'Fist')
            disp('End Robot Adjustment')
        else
            disp('Robot Adjustment')
        end
    elseif frame.hands==2
        disp('Knitting')
    end
end