classdef Robot
    properties
        linkbot
        current_pos
        current_angles
        readypos
    end
    methods
        function obj = Robot()
            robai = SerialLink([ ...
                Revolute('a', 0, 'd', 177, 'qlim', [deg2rad(-150) deg2rad(150)], 'alpha', -pi/2), ...
                Revolute('a', 126, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2, 'offset', -pi/2), ...
                Revolute('a', 115, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', -pi/2), ...
                Revolute('a', 97,  'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2), ...
                Revolute('a', 72,  'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', -pi/2), ...
                Revolute('a', 0, 'd', 0, 'qlim', [deg2rad(-105) deg2rad(105)], 'alpha', pi/2, 'offset', pi/2), ...
                Revolute('a', 0, 'd', 150, 'qlim', [deg2rad(-150) deg2rad(150)], 'alpha', pi/2, 'offset', pi/2), ...
                Prismatic('theta', -pi/2, 'qlim', [0 25])], ...
                'name', 'robai');

            robai.tool = transl(0, 0, 20) * troty(-pi/2);
            robai.base = SE3(0, 0, 74);
            obj.linkbot = robai;

            obj.readypos = zeros(8);
            obj.current_pos = obj.readypos;
            obj.current_angles = robai.fkine(obj.current_pos);
        end

        function output = move(obj, vel)
            % Jacobian: joint velocities -> end effector velocities
            J = obj.linkbot.jacob0(obj.current_angles);

            % Inv: end effector velocities -> joint velocities
            Jinv = pinv(J);

            % Compute joint velocities
            q_dot = Jinv * [vel(i, :)'; omega(:, i)];

            % Compute new joint angle using velocity
            obj. = current_joint_angles + q_dot';
        end

        function output = moveUp(obj)
            
        end

        function output = moveLeft(obj)
            % this will execute a 1 second move at a rate of 0.1 unit/sec
            q = obj.curpos(:); % Reset start value
            dt = 0.01;
            [~, T] = get_kinematics(q, obj.robotstruct);
            % Now to achieve an end effector motion, we need to provide a desired
            % velocity:
            vXYZ = [0.1 0 0]';
            for i = 1:100
                view(0,0)
                % get the Jacobian based on the current joint angles
                obj.J = numeric_jacobian(q, obj.robotstruct);
                % inverse of Jacobian to computer joint velocities
                Jinv = pinv(obj.J(1:3,:));
                % compute the joint velocities to achieve the desired end effector position
                q_dot = Jinv * (vXYZ);
                % check out result by forward multiplying the Jacobian
                vExpected = obj.J11 * q_dot
                q = q + (q_dot.* dt);
                [A, T] = get_kinematics(q, obj.robotstruct);
                update_elbow_manipulator(obj.handles, A)
                pause(dt)
            end
            obj.curpos(:) = q(:);
            output = "move left"
        end
    end
end

