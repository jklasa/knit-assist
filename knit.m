%% Knitting procedure

autoBreak = true;
autoBreakSensitivity = 5; % Set to 0.5 for no sensitivity consideration
knitWaitTime = 0.5;
adjustmentWaitTime = 0.1;

% Set a ModeFilter so we don't break out of the loop
% so easily
breakFilter = ModeFilter(autoBreakSensitivity * 2);

% Knitting loop
StartStopForm([])
while StartStopForm
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

        if strcmp(emgStitch, 'Wrist Rotate Out')
            % Knit stitch
            rob.knit();
            stitchModel.modeFilter.reset();
            result = 'KNIT';
        elseif strcmp(emgStitch, 'Wrist Rotate In')
            % Purl stich
            rob.purl();
            stitchModel.modeFilter.reset();
            result = 'PURL';
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