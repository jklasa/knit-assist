%% Robot Position Adjustment

autoBreak = true;
autoBreakSensitivity = 40; % Set to 1 for no sensitivity consideration
adjustmentWaitTime = 0.1;

% Set a ModeFilter so we don't break out of the loop
% so easily
breakFilter = ModeFilter(autoBreakSensitivity, autoBreakSensitivity);

% Clear out filter histories
leapModel.reset();
gestureModel.reset();

% Adjustment loop
while true
    [state, leapGesture] = leapModel.predict();
    emgGesture = 'none';
    result = 'none';

    switch state
        case 'rest'
            % Do nothing

        case 'bothHands'
            % Do nothing

        case 'leftHand'
            % Adjust up/down

            switch leapGesture
                case 'oneFinger'
                    rob.up();
                    result = 'UP';
                case 'twoFingers'
                    rob.down()
                    result = 'DOWN';
                case 'openHand'
                    if autoBreak && strcmp(breakFilter.filter(leapGesture), 'openHand')
                        disp('AUTOBREAK!');
                        break
                    end
                    result = 'BREAK';
                case 'closedHand'
                    rob.close();
                    result = 'CLOSE';
                otherwise
                    % Do nothing
            end

        case 'rightHand'
            % Adjust in/out, left/right
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

        otherwise
            % Do nothing
    end

    % Turn down breakFilter if we didn't see an openHand
    if ~strcmp(leapGesture, 'openHand')
        breakFilter.filter('other');
    end

    % Debugging Output
    disp([state, leapGesture, emgGesture, result]);

    % Pause for dramatic effect
    pause(adjustmentWaitTime);
end