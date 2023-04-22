classdef EMGClassifier 
    properties
        myoband
        model
        modeFilter
    end
    methods
        function obj = EMGClassifier(myoband, trainingDataPath, smoothingWindow)
            obj.myoband = myoband;
            obj.model = obj.loadModel(trainingDataPath);
            obj.modeFilter = ModeFilter(smoothingWindow);
        end

        function model = loadModel(~, trainingDataPath)
            trainData = PatternRecognition.TrainingData();
            trainData.loadTrainingData(trainingDataPath);
            
            model = SignalAnalysis.Lda;
            model.initialize(trainData);
            model.train();
        end

        function className = predict(obj)
            % Get the appropriate number of EMG samples for the 8 myo channels
            emgData = obj.myoband.getData(obj.model.NumSamplesPerWindow,1:8);
            
            % Extract features and classify
            features2D = obj.model.extractfeatures(emgData);
            [classDecision, ~] = obj.model.classify(reshape(features2D',[],1));
            
            % Get the class name
            classNames = obj.model.getClassNames;
            className = obj.modeFilter.filter(classNames{classDecision});
        end
    end
end