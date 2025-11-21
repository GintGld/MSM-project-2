function Circuit = distance(Circuit)

d       =  0;
i       =  5; % depart
j       = 15; % depart
Circuit(i-1:i+1,j+1) = 0;          % mur sur ligne départ
Circuit = dist_rec(Circuit,i,j,d); % calcul recursif de distance à ligne
Circuit(i-1:i+1,j+1) = max(max(Circuit))+1; % retire le mur


