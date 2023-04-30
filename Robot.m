classdef Robot < handle
    properties
        currentPos
        currentAngles
        gripperWidth
        stitchRadius
        udpUnity
        udpActin
        stepVelocity
        waitTime
        robotStruct
        jointConstraints
        homeAngles
        adjustedHomeAngles
    end
    methods
        function obj = Robot(gripper)
            obj.robotStruct = obj.createDHCyton();
            obj.jointConstraints = [-150 150; -110 110; -110 110; -110 110; -110 110; -115 115; -170 170];

            obj.homeAngles = [0 pi/5 0 pi/4 0 pi/2 0];
            obj.adjustedHomeAngles = [0 pi/5 0 pi/4 0 pi/2 0];
            obj.currentAngles = obj.homeAngles;
            %obj.currentPos = obj.anglesToPos(obj.currentAngles);

            obj.stepVelocity = 0.01;
            obj.stitchRadius = 0.0125;
            obj.waitTime = 0.1;

            % Initialize the MATLAB UDP object to the Unity vCyton
            obj.udpUnity = PnetClass(12002, 12001, '127.0.0.1');
            obj.udpUnity.initialize();

            % Initialize the MATLAB UDP object to the Actin Viewer
            obj.udpActin = PnetClass(8889, 8888, '127.0.0.1');
            obj.udpActin.initialize();

            if nargin == 1
                if strcmp(gripper, 'closed')
                    obj.close()
                else
                    obj.open()
                end
            else
                obj.open()
            end
        end

        function delete(obj)
            obj.udpUnity.close();
            obj.udpActin.close();
        end

        function robotStruct = createDHCyton(obj)
            d = [0.2 0 0 0 0 0 0.09];
            a = [0 0.135 0.125 0.125 0.135 0 0];
            alpha = [-pi/2 -pi/2 pi/2 -pi/2 pi/2 -pi/2 0];

            robotStruct = struct();
            robotStruct.numJoints = 7;
            robotStruct.d = d;
            robotStruct.a = a;
            robotStruct.alpha = alpha;
        end

        function pos = anglesToPos(obj, angles)
            robot_htms = obj.linkbot.fkine(angles);
            last_htm = robot_htms(end);
            pos = last_htm.transl;
        end

        function angles = convertAngles(obj, x)
            angles = [x(1) - pi / 2, x(2) - pi /2, x(3), x(4), x(5), x(6) - pi / 2, x(7)];
        end

        function [A, T] = getKinematics(obj, theta)
            % Get kinematics for the Elbow Manipulator
            % theta is a list of joint angles
            % robot_struct has four fields, which comprise the DH convention for
            % describing a robot: (1) numJoints, (2) d, (3) a, (4) alpha
            %
            % Returns: A as a cell array of transformation matrices between joints
            % Returns: T as a cell array of transformation matrices in global
            %       coordinates

            % grab info from the struct
            numJoints = obj.robotStruct.numJoints;
            d = obj.robotStruct.d;
            a = obj.robotStruct.a;
            alpha = obj.robotStruct.alpha;

            % initialize each transformation matrix
            A = repmat({eye(4)},[1 numJoints]);

            % Ref pg 77 Spong for DH convention
            % Ai = DH_transformation(a_i,alpha_i,d_i,theta_i)
            % Ai = DH_transformation(linkLength,linkTwist,linkOffset,jointAngle)
            % Ai = DH_transformation(Tx,Rx,Tz,Rz)
            % Ai = Rot_z * Trans_z * Trans_x * Rot_x

            for i = 1:numJoints
                A{i} = DH(a(i),alpha(i),d(i),theta(i));
            end

            % compute the global transformation matrices if output is size 2
            if nargout > 1
                % initialize T and then initialize T{1}
                T = cell(size(A));
                T{1} = A{1};

                % post-multiply each transformation matrix
                for i = 2:numJoints
                    T{i} = T{i-1}*A{i};
                end
            end

            function A = DH(linkLength, linkTwist, linkOffset, jointAngle)
                % Compute homogeneous transformation A given Denavit-Hartenberg parameters:
                % linkLength    = a_i
                % linkTwist     = alpha_i
                % linkOffset    = d_i
                % jointAngle    = theta_i

                % pre-computing the cosine and sine is more efficient
                c_theta = cos(jointAngle);
                s_theta = sin(jointAngle);

                % pre-computing the cosine and sine is more efficient
                c_alpha = cos(linkTwist);
                s_alpha = sin(linkTwist);

                A = [
                    c_theta -s_theta*c_alpha  s_theta*s_alpha   linkLength*c_theta;
                    s_theta  c_theta*c_alpha -c_theta*s_alpha   linkLength*s_theta;
                    0        s_alpha          c_alpha           linkOffset;
                    0        0                0                 1;];
            end
        end

        function jac = jacobian(obj, q)
            % Kinematics for the Elbow Robot
            [~, T] = obj.getKinematics(q);

            % Define components for Jacobian:
            % z-axis is just the 3rd column of the transforms
            z = cell(obj.robotStruct.numJoints, 1);
            z{1} = [0 0 1]';
            for loop = 2 : length(z)
                z{loop} = T{loop - 1}(1:3,3);
            end

            % The joint centers are just the 4th column from each transformation
            % matrix to the base
            o = cell(obj.robotStruct.numJoints + 1, 1);
            o{1} = [0 0 0]';
            for loop = 2 : length(o)
                o{loop} = T{loop - 1}(1:3,4);
            end

            % Per Eq. 4.64, J is the Geometric Jacobian
            oc = o{end};
            J = cell(obj.robotStruct.numJoints, 1);
            for loop = 1 : length(J)
                J{loop} = cross(z{loop}, (oc-o{loop}));
            end

            % construct the top half of the Jacobian, that corresponds to endpoint
            J_endpoint = J{1};
            J_orientation = z{1};
            for loop = 2:length(J)
                J_endpoint = [J_endpoint, J{loop}];
                J_orientation = [J_orientation, z{loop}];
            end

            % stack the two jacobian components
            jac = [J_endpoint; J_orientation];
        end

        function setAngles(obj, angles, gripper)
            obj.setVirtualAngles(angles, gripper);
            obj.setPhysicalAngles(angles, gripper);

            % Wait for robot or simulation to move
            pause(obj.waitTime);
        end

        function home(obj)
            obj.setAngles(obj.homeAngles, obj.gripperWidth);
        end

        function setAdjustedHome(obj)
            obj.adjustedHomeAngles = obj.currentAngles;
        end

        function adjustedHome(obj)
            obj.setAngles(obj.adjustedHomeAngles, obj.gripperWidth)
        end

        function setVirtualAngles(obj, angles, gripper)
            obj.udpUnity.putData(typecast([ ...
                single(reshape(rad2deg(angles(1:7)), 1, [])) ...
                single(gripper)], 'uint8'));
        end

        function setPhysicalAngles(obj, angles, gripper)
            joints = [angles gripper];
            obj.udpActin.putData(typecast(double(joints), 'uint8'));
        end

        function move(obj, vel)
            % Jacobian: joint velocities -> end effector velocities
            J = obj.jacobian(obj.convertAngles(obj.currentAngles));

            % Inv: end effector velocities -> joint velocities
            Jinv = pinv(J(1:3,:));

            % Compute joint velocities
            q_dot = Jinv * vel;

            % Compute new joint angle using velocity
            %obj.currentPos = obj.anglesToPos(obj.currentAngles);
            obj.currentAngles = obj.limitJointAngles(obj.currentAngles, obj.currentAngles + q_dot');

            % Move virtual and physical robot
            obj.setAngles(obj.currentAngles, obj.gripperWidth);
        end

        function open(obj)
            obj.gripperWidth = 0.25;
            obj.setAngles(obj.currentAngles, obj.gripperWidth);
        end

        function close(obj)
            obj.gripperWidth = 0.002;
            obj.setAngles(obj.currentAngles, obj.gripperWidth);
        end

        % Get the circular path of the end effector relative to its current position
        function vel = calcCircularPath(obj, radius, knitType)
            num_points = 60; % Number of points to calc
            checkpoints = zeros(num_points,3);

            % We need to move in a circular path of a set radius
            % incrementally and back to same starting point
            theta_inc = 360/num_points;
            if strcmp(knitType, 'purl')
                theta_inc = theta_inc * -1;
            end
            theta = 0;

            % Calculate the cartesian checkpoints when moving in a circle
            for ii = 1:num_points
                y = sind(theta)*radius;
                x = cosd(theta)*radius;
                %z = obj.currentPos(3);
                z = 0;
                checkpoints(ii,:) = [x,y,z];
                theta = theta + theta_inc;
            end

            vel = [checkpoints(:,1), checkpoints(:,2), zeros(num_points,1)];
        end

        function rotateRight(obj)
            % Compute new joint angle using rotation
            newAngles = [obj.currentAngles(1) - obj.stepVelocity obj.currentAngles(2:end)];
            obj.currentAngles = obj.limitJointAngles(obj.currentAngles, newAngles);
            %obj.currentPos = obj.anglesToPos(obj.currentAngles);

            % Move robot
            obj.setAngles(obj.currentAngles, obj.gripperWidth);
        end

        function rotateLeft(obj)
            % Compute new joint angle using rotation
            newAngles = [obj.currentAngles(1) + obj.stepVelocity obj.currentAngles(2:end)];
            obj.currentAngles = obj.limitJointAngles(obj.currentAngles, newAngles);
            %obj.currentPos = obj.anglesToPos(obj.currentAngles);

            % Move robot
            obj.setAngles(obj.currentAngles, obj.gripperWidth);
        end

        function angles = limitJointAngles(obj, prevAngles, newAngles)
            for i = 1:obj.robotStruct.numJoints
                if obj.jointConstraints(i,1) >= newAngles(i) || newAngles(i) >= obj.jointConstraints(i,2)
                    angles = prevAngles;
                    return
                end
            end
            angles = newAngles;
        end

        function left(obj)
            obj.move([-obj.stepVelocity 0 0]');
        end

        function right(obj)
            obj.move([obj.stepVelocity 0 0]');
        end

        function up(obj)
            obj.move([0 0 obj.stepVelocity * 0.5]');
        end

        function down(obj)
            obj.move([0 0 -obj.stepVelocity * 0.5]');
        end

        function in(obj)
            obj.move([0 obj.stepVelocity 0]');
        end

        function out(obj)
            obj.move([0 -obj.stepVelocity 0]');
        end

        function knit(obj)
            disp('knitting');
            path = obj.calcCircularPath(obj.stitchRadius, 'knit');
            for vel = path'
                obj.move(vel ./ 2);
            end
        end

        function purl(obj)
            disp('purling');
            path = obj.calcCircularPath(obj.stitchRadius, 'purl');
            for vel = path'
                obj.move(vel ./ 2);
            end
        end
    end
end


