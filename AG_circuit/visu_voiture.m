function visu_voiture(n, i, j, di, dj, fig)

% voiture

figure(fig)
hold on

voiture = [-1 1;1 1;2 0;2+max(abs([di,dj])) 0;2 0;1 -1;-1 -1; -1 1]' / 6;
theta   = atan2(dj,-di);
Rot     = [ ...
    cos(theta) -sin(theta)
    sin(theta)  cos(theta)];
voiture = Rot * voiture;

plot(j-.5+voiture(2,:),n-i+.5+voiture(1,:),'r','LineWidth',2)
