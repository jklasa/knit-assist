%% Knitting procedure

% Set robot to ready stage such that the gripper points down
rob = Robot();

% Knitting loop
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