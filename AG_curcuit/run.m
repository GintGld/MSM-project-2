function [i, j, di, dj] = run(i0, j0, di0, dj0, acc, whe, Dij)

% in the car referential
% acc {0, 1, 2} acceleration
% whe {-1, 0, 1} = {left, straight, right} weel

if ~exist('Dij')
    Dij = ones(189,2)*999;
    Dij = cree_Dij(Dij);
    'existe pas'
end

[div0, djv0, card] = c2v(di0, dj0);
k                  = kDij(div0,djv0,acc,whe);
div                = Dij(k,1);
djv                = Dij(k,2);
[di, dj]           = v2c(div, djv, card);
i                  = i0 + round(di);
j                  = j0 + round(dj);
