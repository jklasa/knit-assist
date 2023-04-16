classdef EMGClassifier
    properties
        myoband
        ldaModel
    end
    methods
        function obj = EMGClassifier()
            % Update to match current training data file
            trainingDataPath = 'C:\Users\student\Documents\MATLAB\Shapiro20230410.trainingData';

            % Load training data file
            trainData = PatternRecognition.TrainingData();
            trainData.loadTrainingData(trainingDataPath);

            % Create EMG Myo Interface Object
            myoband = Inputs.MyoUdp.getInstance();
            myoband.initialize();
            obj.myoband = myoband;

            % Create LDA Classifier Object
            ldaModel = SignalAnalysis.Lda;
            ldaModel.initialize(trainData);
            ldaModel.train();
            ldaModel.computeError();
            obj.ldaModel = ldaModel;
        end

        function className = predict(obj)
            % Get the appropriate number of EMG samples for the 8 myo channels
            emgData = obj.myoband.getData(obj.ldaModel.NumSamplesPerWindow,1:8);
            
            % Extract features and classify
            features2D = obj.ldaModel.extractfeatures(emgData);
            [classDecision, ~] = obj.ldaModel.classify(reshape(features2D',[],1));
            
            % Get the class name
            classNames = obj.ldaModel.getClassNames;
            className = classNames{classDecision};
        end
    end
end