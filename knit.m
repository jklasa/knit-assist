%% Initialization
% Before running the script, need to train the MyoBand and get the yarn in
% the gripper

% Set robot to ready stage such that the gripper points down
rb = Robot();

% Init classifier
gesture_model = GestureClassifier();

% Attempt to get the gripper slightly above where the user's hands will be
% and directly above the leap controller

while true
    % Get current data from MyoBand and Leap
    data = 0;

    % Feed data into classifier and get gesture
    gesture = gesture_model.predict(data);

    % Check Leap data for general hand positioning

    % If Myo gesture and Leap agree
    if true
        switch gesture
            case "flexion"
                % Bring robot closer in the x-direction
            case "extension"
                % Move robot farther away in x-direction
            case "abduction"
                % Move robot left
            case "adduction"
                % Move robot right
            case "fist"
                % Robot stop. End init stage
                break
        end
    end
end

%% Knitting
stitch_model = StitchClassifier();
num_fists_detected = 0;
stopping_limit = 10;

while true
    % Get MyoBand and Leap data
    data = 0;

    % Check for stopping condition using fist gesture and 
    gesture = gesture_model.predict(data);
    if gesture == "fist"
        if num_fists_detected >= stopping_limit
            break
        end
        num_fists_detected = num_fists_detected + 1;
    else
        num_fists_detected = 0;
    end

    % Classify current knitting state
    state = stitch_model.predict(data);
    switch state
        case "knit"
            % ...
        case "purl"
            % ...
        otherwise
            % ...
    end
end