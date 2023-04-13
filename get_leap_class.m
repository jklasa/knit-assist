function [class] = get_leap_class(position)
%function to take the leap position data and spit out a class
if rad2deg(position.index)<50
    class='Other';
else
    class='Fist';
end