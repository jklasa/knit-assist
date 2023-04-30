classdef LeapClassifier < handle
    properties
        leapSensor
        stateFilter
        gestureFilter
        stitchThreshold
    end

    methods
        function obj = LeapClassifier(smoothingWindow)
            leap = Inputs.LeapMotion;
            leap.initialize();
            obj.leapSensor = leap;
            obj.stateFilter = ModeFilter(smoothingWindow);
            obj.gestureFilter = ModeFilter(smoothingWindow);
            obj.stitchThreshold = pi/4;
        end

        function [state, gesture] = predict(obj)
            frame = obj.leapSensor.getData();
            gesture = 'none';

            if isempty(frame)
                state = 'rest';

            elseif frame.hands == 1
                if strcmp(frame.hand.name, "Left")
                    state = 'leftHand';
                else
                    state = 'rightHand';
                end
                angles = obj.getAngles(frame);
                gesture = obj.getGesture(angles);

            elseif frame.hands == 2
                state = 'bothHands';
                gesture = obj.getStitch(frame);

            else
                state = 'other';

            end

            [state, stateChanged] = obj.stateFilter.filter(state);
            if stateChanged
                % If the state changed, we should reset the gesture history
                % since gestures have changed.
                obj.gestureFilter.reset();
            end
            gesture = obj.gestureFilter.filter(gesture);
        end

        function gesture = getGesture(~, angles)
            % Function to take the leap position data and determine if
            % gesture is up or down
            if sum(rad2deg(angles.index)<50)==3 && ~(sum(rad2deg(angles.middle)<50)==3)
                gesture = 'oneFinger';
            elseif sum(rad2deg(angles.index)<50)==3 && sum(rad2deg(angles.middle)<50)==3 && ~(sum(rad2deg(angles.ring)<50)==3)
                gesture = 'twoFingers';
            elseif sum([rad2deg(angles.index)<50 rad2deg(angles.middle)<50 rad2deg(angles.ring)<50])==9
                gesture = 'openHand';
            else
                gesture = 'other';
            end
        end

        function stitch = getStitch(obj, frame)
            handRPY=nan(2,3);
            for i=1:2
                nx = frame.hand(i).x_basis' ./ norm(frame.hand(i).x_basis);
                ny = frame.hand(i).y_basis' ./ norm(frame.hand(i).y_basis);
                nz = frame.hand(i).z_basis' ./ norm(frame.hand(i).z_basis);
                R = [nx ny nz];
                [U,~,V]=svd(R);
                R=U*V;
                handRPY(i,:)=tr2rpy(R);
            end
            if handRPY(1,1) < obj.stitchThreshold && handRPY(2,1) < obj.stitchThreshold
                stitch = 'knit';
            elseif (handRPY(1,1) < obj.stitchThreshold && handRPY(2,1) > obj.stitchThreshold) ...
                    || (handRPY(1,1) > obj.stitchThreshold && handRPY(2,1) < obj.stitchThreshold)
                stitch = 'purl';
            else
                stitch = 'other';
            end
        end

        function angles = getAngles(~, frame)
            % Takes in a frame of leap motion data and returns finger angles and wrist
            % angle all in radians
            for i=1:frame.hands
                thumb=reshape([frame.hand(i).finger(1).bone.direction],[3 4])';
                index=reshape([frame.hand(i).finger(2).bone.direction],[3 4])';
                middle=reshape([frame.hand(i).finger(3).bone.direction],[3 4])';
                ring=reshape([frame.hand(i).finger(4).bone.direction],[3 4])';
                pinkie=reshape([frame.hand(i).finger(5).bone.direction],[3 4])';
                angles(i).thumb=deg2rad(LinAlg.Anglebetween(thumb(1:3,:)',thumb(2:4,:)'));
                angles(i).index=deg2rad(LinAlg.Anglebetween(index(1:3,:)',index(2:4,:)'));
                angles(i).middle=deg2rad(LinAlg.Anglebetween(middle(1:3,:)',middle(2:4,:)'));
                angles(i).ring=deg2rad(LinAlg.Anglebetween(ring(1:3,:)',ring(2:4,:)'));
                angles(i).pinkie=deg2rad(LinAlg.Anglebetween(pinkie(1:3,:)',pinkie(2:4,:)'));
                % To get the angle between hand and wrist we need to take the arccosine of
                % the dot product divided by product of the magnitudes of the position
                % vectors.
                numerator=dot(frame.arm(i).wrist_position,frame.hand(i).position);
                denominator=norm(frame.arm(i).wrist_position)*norm(frame.hand(i).position);
                angles(i).wrist=acos(numerator/denominator);
            end
        end
    end
end