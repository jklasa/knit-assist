classdef ModeFilter < handle
    properties
        windowSize
        history = {}
        head = 1
        currentOutput
        previousOutput
        threshold
    end

    methods
        function obj = ModeFilter(windowSize, threshold)
            obj.windowSize = windowSize;
            obj.threshold = threshold;
            obj.reset();
        end

        function [output, hasChanged] = filter(obj, input)
            obj.previousOutput = obj.currentOutput;
            obj.head = mod(obj.head, obj.windowSize) + 1;
            obj.history{obj.head} = convertStringsToChars(input);

            cats = categorical(obj.history);
            classes = categories(cats);
            counts = countcats(cats);

            [modeCount, modeIdx] = max(counts);

            if modeCount > obj.threshold
                output = string(classes(modeIdx));
            else
                output = 'other';
            end
            obj.currentOutput = output;

            if nargout == 2
                if obj.currentOutput == obj.previousOutput
                    hasChanged = false;
                else
                    hasChanged = true;
                end
            end
        end

        function reset(obj)
            for i = 1:obj.windowSize
                obj.history{i} = 'other';
            end

            obj.currentOutput = 'other';
            obj.previousOutput = 'other';
        end
    end
end