%% Knitting procedure

waitTime = 0.2;

% Knitting loop
StartStopForm([])
while StartStopForm
    [state, leapGesture] = leapModel.predict();
    emgGesture = 'none';
    emgStitch = 'none';
    result = 'nothing';
    
    switch state
        case 'rest'
            % Do nothing

        case 'Left'
            % Adjust up/down
            switch leapGesture
                case 'one'
                    rob.moveUp();
                    result = 'UP';
                case 'two'
                    rob.moveDown();
                    result = 'DOWN';
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
                    result = 'IN';
                case 'Wrist Extend Out'
                    % Move robot farther away
                    rob.moveOut();
                    result = 'OUT';
                case 'Wrist Abduction'
                    % Move robot left
                    rob.rotateLeft();
                    result = 'LEFT';
                case 'Wrist Adduction'
                    % Move robot right
                    rob.rotateRight();
                    result = 'RIGHT';
            end

        case 'twohands'
            % Knit - check which stitch to do
            emgStitch = stitchModel.predict();
            
            if strcmp(leapGesture, 'knit') && strcmp(emgStitch, 'Wrist Rotate Out')
                % Knit stitch
                rob.knit();
                gestureModel.modeFilter.reset();
                result = 'KNIT';
            elseif strcmp(leapGesture, 'purl') && strcmp(emgStitch, 'Wrist Rotate In')
                % Purl stich
                rob.purl();
                gestureModel.modeFilter.reset();
                result = 'PURL';
            else
                % Do nothing
            end

        otherwise
            % Do nothing
    end

    pause(waitTime);
    disp([state, leapGesture, emgGesture, emgStitch, result])
end