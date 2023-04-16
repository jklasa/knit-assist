%% Initialization
% Set up the MiniVIE path
cd('C:\GitHub\MiniVIE');
MiniVIE.configurePath;

% Before running the script, need to train the MyoBand and get the yarn in
% the gripper

% Set robot to ready stage such that the gripper points down
rob = Robot();

% Init classifiers
emgModel = EMGClassifier();
leapModel = LeapClassifier();

% Attempt to get the gripper slightly above where the user's hands will be
% and directly above the leap controller

StartStopForm([])
while StartStopForm
    [state, leapGesture] = leapModel.predict();
    emgGesture = emgModel.predict();

    switch state
        case 'rest'
            % Do nothing

        case 'lefthand'
            % Adjust up/down
            switch leapGesture
                case 'flexion'
                    rob.moveUp();
                case 'extension'
                    rob.moveDown();
                otherwise
                    % Do nothing
            end

        case 'righthand'
            % Adjust closer/further, left/right
            switch emgGesture
                case "flexion"
                    % Bring robot closer
                    rob.moveIn();
                case "extension"
                    % Move robot farther away
                    rob.moveOut();
                case "adduction"
                    % Move robot left
                    rob.moveLeft();
                case "abduction"
                    % Move robot right
                    rob.moveRight();
            end

        case 'twohands'
            % Knit - check which stitch to do
            switch leapGesture
                case 'knit'
                    % Knit stitch
                case 'purl'
                    % Purl stich
                case 'wait'
                    % ???
                otherwise
                    % Do nothing
            end

        otherwise
            % Do nothing
    end
end