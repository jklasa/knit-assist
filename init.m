%% Initialization
% Connect MyoBand first!

% Myo Inputs
system('C:\GitHub\minivie\+Inputs\MyoUdp.exe', '&')

% Leap Inputs
system('C:\GitHub\hrilabs\Lab3_FingerControl\StartLeapStream.bat', '&')

% Set up the MiniVIE path
addpath(genpath('C:\GitHub\MiniVIE'));
MiniVIE.configurePath;

% Before running the script, need to train the MyoBand and get the yarn in
% the gripper
MiniVIE

% Create EMG Myo Interface Object
myoband = Inputs.MyoUdp.getInstance();
myoband.initialize();

% Init classifiers
gestureModel = EMGClassifier(myoband, '0417_shapiro.trainingData', 8);
stitchModel = EMGClassifier(myoband, '0417_shapiro.trainingData', 8);
leapModel = LeapClassifier(8);