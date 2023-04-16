classdef ModeFilter
    properties
        windowSize
        history
        head
    end

    methods
        function obj = ModeFilter(windowSize)
            obj.windowSize = windowSize;
            obj.history = strings([1, windowSize]);
            
            for i = 1:windowSize
                obj.history(i) = 'other';
            end

            obj.head = 1;
        end

        function output = filter(obj, input)
            obj.head = mod(obj.head + 1, obj.windowSize);
            obj.history(obj.head) = input;

            
        end
    end
end