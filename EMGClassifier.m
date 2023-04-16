classdef EMGClassifier
    properties
        myoband
        gestureModel
        stitchModel
    end
    methods
        function obj = EMGClassifier()
            % Create EMG Myo Interface Object
            myoband = Inputs.MyoUdp.getInstance();
            myoband.initialize();
            obj.myoband = myoband;

            % Create classifier for gestures
            gestureDataPath = 'C:\Users\student\Documents\MATLAB\Shapiro20230410.trainingData';
            obj.gestureModel = obj.loadModel(gestureDataPath);

            % Create classifier for stitch
            stitchDataPath = '';
            obj.stitchModel = obj.loadModel(stitchDataPath);
        end

        function model = loadModel(trainingDataPath)
            trainData = PatternRecognition.TrainingData();
            trainData.loadTrainingData(trainingDataPath);
            
            model = SignalAnalysis.Lda;
            model.initialize(trainData);
            model.train();
            model.computeError();
        end

        function className = predictGesture(obj)
            % Get the appropriate number of EMG samples for the 8 myo channels
            emgData = obj.myoband.getData(obj.gestureModel.NumSamplesPerWindow,1:8);
            
            % Extract features and classify
            features2D = obj.gestureModel.extractfeatures(emgData);
            [classDecision, ~] = obj.gestureModel.classify(reshape(features2D',[],1));
            
            % Get the class name
            classNames = obj.gestureModel.getClassNames;
            className = classNames{classDecision};
        end

        function stitch = predictStitch(obj)
            % Get EMG data
            emgData = obj.myoband.getData(obj.stitchModel.NumSamplesPerWindow,1:8);

        end
    end
end