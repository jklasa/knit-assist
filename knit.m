%% Knitting procedure

gestureWait = 0.05;
stitchWait = 0.2;

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
                    rob.up();
                    result = 'UP';
                case 'two'
                    rob.down();
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
                    rob.in();
                    result = 'IN';
                case 'Wrist Extend Out'
                    % Move robot farther away
                    rob.out();
                    result = 'OUT';
                case 'Wrist Abduction'
                    % Move robot left
                    rob.left();
                    result = 'LEFT';
                case 'Wrist Adduction'
                    % Move robot right
                    rob.right();
                    result = 'RIGHT';
            end
            pause(gestureWait);

        case 'twohands'
            % Knit - check which stitch to do
            emgStitch = stitchModel.predict();
            
            %if strcmp(leapGesture, 'knit') && strcmp(emgStitch, 'Wrist Rotate Out')
            if strcmp(emgStitch, 'Wrist Rotate Out')
                % Knit stitch
                rob.knit();
                stitchModel.modeFilter.reset();
                result = 'KNIT';
            %elseif strcmp(leapGesture, 'purl') && strcmp(emgStitch, 'Wrist Rotate In')
            elseif strcmp(emgStitch, 'Wrist Rotate In')
                % Purl stich
                rob.purl();
                stitchModel.modeFilter.reset();
                result = 'PURL';
            else
                % Do nothing
            end
            pause(stitchWait);

        otherwise
            % Do nothing
    end

    disp([state, leapGesture, emgGesture, emgStitch, result])
end