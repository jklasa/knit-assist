classdef robot < handle
    properties
        linkbot
        current_pos
        current_angles
        udpUnity
        udpActin
        velocity
    end
    methods
        function obj = robot()
            robai = SerialLink([ ...
                Revolute('a', 0, 'd', 0.177, 'qlim', [deg2rad(-150) deg2rad(150)], 'alpha', -pi/2), ...
                Revolute('a', 0.126, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2, 'offset', -pi/2), ...
                Revolute('a', 0.115, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', -pi/2), ...
                Revolute('a', 0.097,  'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2), ...
                Revolute('a', 0.072,  'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', -pi/2), ...
                Revolute('a', 0, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2, 'offset', pi/2), ...
                Revolute('a', 0, 'd', 0.150, 'qlim', [deg2rad(-150) deg2rad(150)], 'alpha', pi/2, 'offset', pi/2), ...
                Prismatic('theta', -pi/2, 'qlim', [0 25])], ...
                'name', 'robai');

            robai.tool = transl(0, 0, 0.020) * troty(-pi/2);
            robai.base = SE3(0, 0, 0.074);
            obj.linkbot = robai;

            obj.current_angles = [0 pi/4 0 pi/2 0 pi/4 0 0.1];
            obj.current_pos = obj.anglesToPos(obj.current_angles);
            obj.velocity = 0.1;

            % Initialize the MATLAB UDP object to the Unity vCyton
            obj.udpUnity = PnetClass(12002, 12001, '127.0.0.1');
            obj.udpUnity.initialize();
            obj.setVirtual(obj.current_angles);

            % Initialize the MATLAB UDP object to the Actin Viewer
            obj.udpActin = PnetClass(8889, 8888, '127.0.0.1');
            obj.udpActin.initialize();
        end

        function pos = anglesToPos(obj, angles)
            robot_htms = obj.linkbot.fkine(angles);
            last_htm = robot_htms(end);
            pos = last_htm.transl;
        end

        function obj = setVirtual(obj, angles)
            obj.udpUnity.putData(typecast([ ...
                single(reshape(rad2deg(angles(1:7)), 1, [])) ...
                single(angles(8))], 'uint8')); 
        end

        function obj = move(obj, vel)
            % Jacobian: joint velocities -> end effector velocities
            J = obj.linkbot.jacob0(obj.current_angles);

            % Inv: end effector velocities -> joint velocities
            Jinv = pinv(J(1:3,:));

            % Compute joint velocities
            q_dot = Jinv * vel;

            % Compute new joint angle using velocity
            obj.current_angles = obj.limitJointAngles(obj.current_angles + q_dot');
            obj.current_pos = obj.anglesToPos(obj.current_angles);

            % Move virtual robot
            obj.setVirtual(obj.current_angles);

            % Move actual robot
            % TODO move actual robot
        end

        function rotate(obj)
            % TODO rotate robot in one direction
        end

        function angles = limitJointAngles(obj, angles)
            % TODO fix robot limiting
            robot = obj.linkbot;
            for i = 1:robot.n
                angles(i) = min( ...
                    robot.links(i).qlim(2), ...
                    max(robot.links(i).qlim(1), angles(i)));
            end
        end

        function obj = moveIn(obj)
            obj.move([-obj.velocity 0 0]');
        end

        function obj = moveOut(obj)
            obj.move([obj.velocity 0 0]');
        end

        function obj = moveUp(obj)
            obj.move([0 0 obj.velocity]');
        end

        function obj = moveDown(obj)
            obj.move([0 0 -obj.velocity]');
        end

        function obj = moveLeft(obj)
            obj.move([0 obj.velocity 0]');
        end

        function obj = moveRight(obj)
            obj.move([0 -obj.velocity 0]');
        end

        function obj = knit(obj)
            % TODO knit path
        end

        function obj = purl(obj)
            % TODO purl path
        end
    end
end

