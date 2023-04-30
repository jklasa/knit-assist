%% Initialization
% Connect MyoBand first!

%%
% Programs

% Myo Inputs
% C:\GitHub\minivie\+Inputs\MyoUdp.exe

% Leap Inputs
% C:\GitHub\hrilabs\Lab3_FingerControl\StartLeapStream.bat

% Cyton Viewer
% C:\Program Files (x86)\Robai\Cyton Epsilon 1500 Viewer_4.0.23-20160811-b59\bin\cytonViewer.exe
% C:\Program Files (x86)\Robai\Cyton Epsilon 1500 Viewer_4.0.23-20160811-b59\bin\cytonCommandExample.exe
% 
% Plugin: remoteCommandServerPlugin.ecp

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
dataName = 'amy_sunday_all';
dataFile = strcat('data/', dataName, '.trainingData');

gestureModel = EMGClassifier(myoband, dataFile, 8, 4);
stitchModel = EMGClassifier(myoband, dataFile, 16, 7);
leapModel = LeapClassifier(12, 6);

%%
% Set robot to ready stage such that the gripper points down
rob = Robot('closed');