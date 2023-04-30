%% Knitting procedure

autoBreak = true;
autoBreakSensitivity = 40; % Set to 1 for no sensitivity consideration
knitWaitTime = 3;
adjustmentWaitTime = 0.1;

% Set a ModeFilter so we don't break out of the loop
% so easily
breakFilter = ModeFilter(autoBreakSensitivity, autoBreakSensitivity);

% Clear out filter histories
leapModel.reset();
stitchModel.reset();

% Trust the robot is where we want it
rob.setAdjustedHome()

% Knitting loop
while true
    [state, leapGesture] = leapModel.predict();
    emgStitch = 'none';
    result = 'none';

    if ~strcmp(state, 'rest')
        % Break if desired
        if autoBreak && strcmp(breakFilter.filter(leapGesture), 'openHand')
            disp('AUTOBREAK!');
            break
        end

        % Knit - check which stitch to do
        emgStitch = stitchModel.predict();

        if strcmp(emgStitch, 'Wrist Rotate Out') %|| strcmp(emgStitch, 'Wrist Adduction')
            % Knit stitch
            rob.knit();
            stitchModel.modeFilter.reset();
            result = 'KNIT';
            rob.adjustedHome();
        elseif strcmp(emgStitch, 'Wrist Rotate In') %|| strcmp(emgStitch, 'Wrist Abduction')
            % Purl stich
            rob.purl();
            stitchModel.modeFilter.reset();
            result = 'PURL';
            rob.adjustedHome();
        else
            % Do nothing
        end
    end

    % Turn down breakFilter if we didn't see an openHand
    if ~strcmp(leapGesture, 'openHand')
        breakFilter.filter('other');
    end

    % Debugging output
    disp([state, leapGesture, emgStitch, result]);

    % Wait depending on if we just did a stitch
    if strcmp(result, 'none')
        pause(adjustmentWaitTime);
    else
        pause(knitWaitTime);
    end
end