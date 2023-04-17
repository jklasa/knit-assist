%% Initialization
% Prerequisite: run programs for setup
%
% Myo Inputs
% C:\GitHub\minivie\+Inputs\MyoUdp.exe
% 
% Leap Inputs
% C:\GitHub\hrilabs\Lab3_FingerControl\StartLeapStream.bat

% Set up the MiniVIE path
addpath(genpath('C:\GitHub\MiniVIE'));
MiniVIE.configurePath;

% Before running the script, need to train the MyoBand and get the yarn in
% the gripper
% MiniVIE

% Set robot to ready stage such that the gripper points down
rob = Robot();

% Create EMG Myo Interface Object
myoband = Inputs.MyoUdp.getInstance();
myoband.initialize();

% Init classifiers
gestureModel = EMGClassifier(myoband, '0417_shapiro.trainingData', 8);
stitchModel = EMGClassifier(myoband, '0417_shapiro.trainingData', 8);
leapModel = LeapClassifier(8);

% Attempt to get the gripper slightly above where the user's hands will be
% and directly above the leap controller

StartStopForm([])
while StartStopForm
    [state, leapGesture] = leapModel.predict();

    if ~strcmp(gestureModel, 'righthand')
        gestureModel.modeFilter.reset();
    end

    switch state
        case 'rest'
            % Do nothing

        case 'Left'
            % Adjust up/down
            switch leapGesture
                case 'flexion'
                    rob.moveUp();
                    disp("UP")
                case 'extension'
                    rob.moveDown();
                    disp("DOWN")
                otherwise
                    % Do nothing
            end

        case 'Right'
            % Adjust closer/further, left/right
            emgGesture = gestureModel.predict();

            switch emgGesture
                case 'Wrist Flex In'
                    % Bring robot closer
                    rob.moveIn();
                    disp("IN")
                case 'Wrist Extend Out'
                    % Move robot farther away
                    rob.moveOut();
                    disp("OUT")
                case 'Wrist Abduction'
                    % Move robot left
                    rob.moveLeft();
                    disp("LEFT")
                case 'Wrist Adduction'
                    % Move robot right
                    rob.moveRight();
                    disp("RIGHT")
            end

        case 'twohands'
            % Knit - check which stitch to do
            emgStitch = stitchModel.predict();
            
            if strcmp(leapGesture, 'knit') && strcmp(emgStitch, 'Wrist Rotate Out')
                % Knit stitch
                rob.knit();
                disp("KNIT")
            elseif strcmp(leapGesture, 'purl') && strcmp(emgStitch, 'Wrist Rotate In')
                % Purl stich
                rob.purl();
                disp("PURL")
            else
                % Do nothing
            end

        otherwise
            % Do nothing
    end
end