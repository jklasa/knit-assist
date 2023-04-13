function [output] = get_leap_position(frame)
%Takes in a frame of leap motion data and returns finger angles and wrist
%angle all in radians
for i=1:frame.hands
    thumb=reshape([frame.hand(i).finger(1).bone.direction],[3 4])';
    index=reshape([frame.hand(i).finger(2).bone.direction],[3 4])';
    middle=reshape([frame.hand(i).finger(3).bone.direction],[3 4])';
    ring=reshape([frame.hand(i).finger(4).bone.direction],[3 4])';
    pinkie=reshape([frame.hand(i).finger(5).bone.direction],[3 4])';
    output(i).thumb=deg2rad(LinAlg.Anglebetween(thumb(1:3,:)',thumb(2:4,:)'));
    output(i).index=deg2rad(LinAlg.Anglebetween(index(1:3,:)',index(2:4,:)'));
    output(i).middle=deg2rad(LinAlg.Anglebetween(middle(1:3,:)',middle(2:4,:)'));
    output(i).ring=deg2rad(LinAlg.Anglebetween(ring(1:3,:)',ring(2:4,:)'));
    output(i).pinkie=deg2rad(LinAlg.Anglebetween(pinkie(1:3,:)',pinkie(2:4,:)'));
    %to get the angle between hand and wrist we need to take the arccosine of
    %the dot product divided by product of the magnitudes of the position
    %vectors.
    numerator=dot(frame.arm(i).wrist_position,frame.hand(i).position);
    denominator=norm(frame.arm(i).wrist_position)*norm(frame.hand(i).position);
    output(i).wrist=acos(numerator/denominator);
end
end