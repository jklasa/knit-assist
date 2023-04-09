classdef robot
%robot Summary of this class goes here
% Detailed explanation goes here
properties
J11
J
handles
readypos
curpos
robotstruct
end
methods
function obj = robot()
q_readypos = [0 pi/4 -pi/2 pi/4 pi/2 0];
obj.readypos = q_readypos;
% first setup all the graphics objects with correct parent/hierarchy
clf
obj.handles = plot_elbow_robot();
view(-20,35)
% These A matrices give us the relative pose of each link, based on the
% current joint angles
obj.robotstruct = link_constants_elbow();
A = get_kinematics(obj.readypos, obj.robotstruct);
% Then the z-axes are based on the global pose of each joint frame,
% computed by the forward multiplication of each relative pose 
T_0_1 = A{1};
T_0_2 = A{1}*A{2};
T_0_3 = A{1}*A{2}*A{3};
T_0_4 = A{1}*A{2}*A{3}*A{4};
T_0_5 = A{1}*A{2}*A{3}*A{4}*A{5};
T_0_6 = A{1}*A{2}*A{3}*A{4}*A{5}*A{6};
% The joint z-axes can be extracted based on the joint pose as the 3rd
% column of the transformation matrix (rows 1-3)
% Note the Global z axis z0 is always [0 0 1]'
z0 = [0 0 1]';
z1 = T_0_1(1:3,3);
z2 = T_0_2(1:3,3);
z3 = T_0_3(1:3,3);
z4 = T_0_4(1:3,3);
z5 = T_0_5(1:3,3);
% The joint origins can be extracted based on the joint pose as the 4th
% column of the transformation matrix (rows 1-3)
% Note the Global origin is always [0 0 0]'
o0 = [0;0;0];
o1 = T_0_1(1:3,4);
o2 = T_0_2(1:3,4);
o3 = T_0_3(1:3,4);
o4 = T_0_4(1:3,4);
o5 = T_0_5(1:3,4);
o6 = T_0_6(1:3,4);
% our end effector point is the last link position
oN = o6; 
% Now the columns of the Jacobian are just the cross product of each joint
% axis with the vector between the joint origin and the end effector.
% This Jacobian is sufficient for 'position control'
% (Using only 3 rows)
J1 = cross(z0,(oN-o0));
J2 = cross(z1,(oN-o1));
J3 = cross(z2,(oN-o2));
J4 = cross(z3,(oN-o3));
J5 = cross(z4,(oN-o4));
J6 = cross(z5,(oN-o5));
% This aggregates the Jacobian into a single variable:
obj.J11 = [J1 J2 J3 J4 J5 J6];
% Finally, the angular velocity components are added to complete the
% Jacobian
obj.J = [obj.J11; z0 z1 z2 z3 z4 z5];
obj.curpos = obj.readypos
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

