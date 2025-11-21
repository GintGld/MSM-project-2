function k = kDij(dip0, djp0, acc, vol)

dip0 = find([.1,1,2]            ==dip0); % {.1,1,2}             -> 1:3
djp0 = find([-2,-1,-.1,0,.1,1,2]==djp0); % {-2,-1,-.1,0,.1,1,2} -> 1:7
acc  = acc         + 1;                  %  0:2                 -> 1:3 
vol  = vol         + 2;                  % -1:1                 -> 1:3
k    = dip0 + 3 * ((djp0-1) + 7 * ((acc-1) + 3 * (vol-1)));
