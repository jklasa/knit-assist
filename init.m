%% Initialization
% Connect MyoBand first!

%%
% Myo Inputs
%system('C:\GitHub\minivie\+Inputs\MyoUdp.exe')

% Leap Inputs
%system('C:\GitHub\hrilabs\Lab3_FingerControl\StartLeapStream.bat')

% Cyton Viewer
% C:\Program Files (x86)\Robai\Cyton Epsilon 1500 Viewer_4.0.23-20160811-b59\bin\cytonViewer.exe
% 
% C:\Program Files (x86)\Robai\Cyton Epsilon 1500 Viewer_4.0.23-20160811-b59\bin\cytonCommandExample.exe
% 
% remoteCommandServerPlugin.ecp

%%
% Set up the MiniVIE path
addpath(genpath('C:\GitHub\MiniVIE'));
MiniVIE.configurePath;

%%
% Before running the script, need to train the MyoBand and get the yarn in
% the gripper
MiniVIE

%%
% Create EMG Myo Interface Object
myoband = Inputs.MyoUdp.getInstance();
myoband.initialize();

%%
% Init classifiers
gestureModel = EMGClassifier(myoband, 'amy_all.trainingData', 8);
stitchModel = EMGClassifier(myoband, 'amy_all.trainingData', 8);
leapModel = LeapClassifier(8);

%%
% Set robot to ready stage such that the gripper points down
rob = Robot();