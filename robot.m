classdef Robot < handle
    properties
        linkbot
        currentPos
        currentAngles
        gripperWidth
        stitchRadius
        udpUnity
        udpActin
        stepVelocity
    end
    methods
        function obj = Robot()
            robai = SerialLink([ ...
                Revolute('a', 0, 'd', 0.177, 'qlim', [deg2rad(-150) deg2rad(150)], 'alpha', -pi/2), ...
                Revolute('a', 0.126, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2, 'offset', -pi/2), ...
                Revolute('a', 0.115, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', -pi/2), ...
                Revolute('a', 0.097,  'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2), ...
                Revolute('a', 0.072,  'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', -pi/2), ...
                Revolute('a', 0, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2, 'offset', pi/2), ...
                Revolute('a', 0, 'd', 0.150, 'qlim', [deg2rad(-150) deg2rad(150)], 'alpha', pi/2, 'offset', pi/2)], ...
                'name', 'robai');
            % Prismatic('theta', -pi/2, 'qlim', [0 .25])], ...

            robai.tool = transl(0, 0, 0.020) * troty(-pi/2);
            robai.base = SE3(0, 0, 0.074);
            obj.linkbot = robai;

            obj.currentAngles = [0 pi/4 0 pi/2 0 pi/4 0];
            obj.currentPos = obj.anglesToPos(obj.currentAngles);
            obj.stepVelocity = 0.01;
            obj.gripperWidth = 0.01;
            obj.stitchRadius = 0.05;

            % Initialize the MATLAB UDP object to the Unity vCyton
            obj.udpUnity = PnetClass(12002, 12001, '127.0.0.1');
            obj.udpUnity.initialize();
            obj.setVirtual(obj.currentAngles, obj.gripperWidth);

            % Initialize the MATLAB UDP object to the Actin Viewer
            obj.udpActin = PnetClass(8889, 8888, '127.0.0.1');
            obj.udpActin.initialize();
        end

        function pos = anglesToPos(obj, angles)
            robot_htms = obj.linkbot.fkine(angles);
            last_htm = robot_htms(end);
            pos = last_htm.transl;
        end

        function setVirtual(obj, angles, gripper)
            obj.udpUnity.putData(typecast([ ...
                single(reshape(rad2deg(angles(1:7)), 1, [])) ...
                single(gripper)], 'uint8')); 
        end

        function move(obj, vel)
            % Jacobian: joint velocities -> end effector velocities
            J = obj.linkbot.jacob0(obj.currentAngles);

            % Inv: end effector velocities -> joint velocities
            Jinv = pinv(J(1:3,:));

            % Compute joint velocities
            q_dot = Jinv * vel;

            % Compute new joint angle using velocity
            obj.currentAngles = obj.limitJointAngles(obj.currentAngles, obj.currentAngles + q_dot');
            obj.currentPos = obj.anglesToPos(obj.currentAngles);

            % Move virtual robot
            obj.setVirtual(obj.currentAngles, obj.gripperWidth);

            % Move actual robot
            % TODO move actual robot
        end

        function openGripper(obj)
            obj.gripperWidth = 0.25;
            obj.setVirtual(obj.currentAngles, obj.gripperWidth);
        end

        function closeGripper(obj)
            obj.gripperWidth = 0.01;
            obj.setVirtual(obj.currentAngles, obj.gripperWidth);
        end

        % Get the circular path of the end effector relative to its current position
        function vel = calcCircularPath(obj, radius, knitType)
            num_points = 30; % Number of points to calc
            checkpoints = zeros(num_points,3);
            
            % We need to move in a circular path of a set radius
            % incrementally and back to same starting point
            theta_inc = 360/num_points;
            theta = theta_inc;

            % Calculate the cartesian checkpoints when moving in a circle
            for ii = 1:num_points
                y = sind(theta)*radius;
                x = cosd(theta)*radius;
                z = obj.currentPos(3);
                checkpoints(ii,:) = [x,y,z];
                theta = theta + theta_inc;
            end
            
            vel = [checkpoints(:,1), checkpoints(:,2), zeros(num_points,1)];
        end

        function rotateRight(obj)
            % Compute new joint angle using rotation
            newAngles = [obj.currentAngles(1) - obj.stepVelocity obj.currentAngles(2:end)];
            obj.currentAngles = obj.limitJointAngles(obj.currentAngles, newAngles);
            obj.currentPos = obj.anglesToPos(obj.currentAngles);

            % Move virtual robot
            obj.setVirtual(obj.currentAngles, obj.gripperWidth);

            % Move actual robot
            % TODO move actual robot
        end

        function rotateLeft(obj)
            % Compute new joint angle using rotation
            newAngles = [obj.currentAngles(1) + obj.stepVelocity obj.currentAngles(2:end)];
            obj.currentAngles = obj.limitJointAngles(obj.currentAngles, newAngles);
            obj.currentPos = obj.anglesToPos(obj.currentAngles);

            % Move virtual robot
            obj.setVirtual(obj.currentAngles, obj.gripperWidth);

            % Move actual robot
            % TODO move actual robot
        end

        function angles = limitJointAngles(obj, prevAngles, newAngles)
            robot = obj.linkbot;
            for i = 1:robot.n
                if robot.links(i).qlim(1) >= newAngles(i) || newAngles(i) >= robot.links(i).qlim(2)
                    angles = prevAngles;
                    return
                end
            end
            angles = newAngles;
        end

        function moveIn(obj)
            obj.move([-obj.stepVelocity 0 0]');
        end

        function moveOut(obj)
            obj.move([obj.stepVelocity 0 0]');
        end

        function moveUp(obj)
            obj.move([0 0 obj.stepVelocity]');
        end

        function moveDown(obj)
            obj.move([0 0 -obj.stepVelocity]');
        end

        function moveLeft(obj)
            obj.move([0 obj.stepVelocity 0]');
        end

        function moveRight(obj)
            obj.move([0 -obj.stepVelocity 0]');
        end

        function knit(obj)
            path = obj.calcCircularPath(obj.stitchRadius, 'knit');

            for vel = path'
                disp(vel)
                obj.move(vel);
            end
        end

        function purl(obj)
            path = obj.calcCircularPath(obj.stitchRadius, 'purl');

            for vel = path'
                obj.move(vel);
            end
        end
    end
end


