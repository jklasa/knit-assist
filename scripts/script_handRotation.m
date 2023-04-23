load('20230416_handRotation.mat')
nx = palmDown.hand(1).x_basis' ./ norm(palmDown.hand(1).x_basis);
ny = palmDown.hand(1).y_basis' ./ norm(palmDown.hand(1).y_basis);
nz = palmDown.hand(1).z_basis' ./ norm(palmDown.hand(1).z_basis);
R = [nx ny nz];
[U,~,V]=svd(R);
R_palmDown=U*V;
tr2rpy(R_palmDown)

nx = palmUp.hand(1).x_basis' ./ norm(palmUp.hand(1).x_basis);
ny = palmUp.hand(1).y_basis' ./ norm(palmUp.hand(1).y_basis);
nz = palmUp.hand(1).z_basis' ./ norm(palmUp.hand(1).z_basis);
R = [nx ny nz];
[U,~,V]=svd(R);
R_palmUp=U*V;
tr2rpy(R_palmUp)