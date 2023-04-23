%% Script to isolate using the myoband identifier and connect it to the robot
% Set up the MiniVIE path
cd('C:\GitHub\MiniVIE');
MiniVIE.configurePath;

%update to match current training data file
myDataFilename = 'C:\Users\student\Documents\MATLAB\Shapiro20230410.trainingData';
 
% Load training data file
hData = PatternRecognition.TrainingData();
hData.loadTrainingData(myDataFilename);

% initialize the MATLAB UDP object to the Unity vCyton
udpUnity = PnetClass(12002, 12001, '127.0.0.1');
udpUnity.initialize();
% put the robot in an itial position
q = [0 0.7 0 0.7 0 0.7 0];
udpUnity.putData(typecast(single([rad2deg(q), 0.01]), 'uint8')); % takes degrees as floats (except for last element)
matlabAngles = @(x) [x(1) - pi / 2, x(2) - pi /2, x(3), x(4), x(5), x(6) - pi / 2, x(7)];
robotStruct = link_constants_cyton();
moveUnityCyton = @(x) udpUnity.putData(typecast([single(reshape(rad2deg(x(1:7)), 1, [])) single(x(8))], 'uint8')); 
% Create EMG Myo Interface Object
hMyo = Inputs.MyoUdp.getInstance();
hMyo.initialize();
 
% Create LDA Classifier Object
hLda = SignalAnalysis.Lda;
hLda.initialize(hData);
hLda.train();
hLda.computeError();
 
adjust=true;
while adjust==true
        
    % Get the appropriate number of EMG samples for the 8 myo channels
    emgData = hMyo.getData(hLda.NumSamplesPerWindow,1:8);
    
    % Extract features and classify
    features2D = hLda.extractfeatures(emgData);
    [classDecision, voteDecision] = hLda.classify(reshape(features2D',[],1));
    
    % get the class name
    classNames = hLda.getClassNames;
    className = classNames{classDecision};
    fprintf('Class=%2d; Class = %16s;\n',classDecision,className);
    % refresh the display
    drawnow;
dt=0.1;
    switch className
        case 'No Movement' %do nothing
        case 'Elbow Flexion' %bring robot closer
            vXYZ = [.1 .1 0]';
            % get the Jacobian based on the current joint angles
            J = numeric_jacobian(matlabAngles(q), robotStruct);
            % inverse of Jacobian to computer joint velocities
            Jinv = pinv(J(1:3,:));
            % compute the joint velocities to achieve the desired end effector position
            q_dot = Jinv * (vXYZ);
            % check out result by forward multiplying the Jacobian
            vExpected = J * q_dot;
            % compute the new joint angles
            q = q + (q_dot.* dt);
            moveUnityCyton(q);

        case 'Elbow Extension'
            vXYZ = [-.1 -.1 0]';
            % get the Jacobian based on the current joint angles
            J = numeric_jacobian(matlabAngles(q), robotStruct);
            % inverse of Jacobian to computer joint velocities
            Jinv = pinv(J(1:3,:));
            % compute the joint velocities to achieve the desired end effector position
            q_dot = Jinv * (vXYZ);
            % check out result by forward multiplying the Jacobian
            vExpected = J * q_dot;
            % compute the new joint angles
            q = q + (q_dot.* dt);
            moveUnityCyton(q);
        case 'Spherical Grasp'
            %adjust=false;%break us out of the loop because robot is now where we want it
    end
 
end