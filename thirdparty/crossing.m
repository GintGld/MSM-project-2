function child = crossing(moth, fath)

% the genes (view, di, dj) present uniquely in the father or the mother 
% go to the child. If both have them then random draw of who gives.

nbgm = length(moth.view); % number of genes in the mother
nbgp = length(fath.view); %                        father
nge  = 0;                 % child gene number

for ngm = 1 : nbgm %
    nge = nge + 1;      
    ngp = find(...
        fath.view(1:nbgp) == moth.view(ngm) & ...
        fath.div(1:nbgp)  == moth.div(ngm) & ...
        fath.djv(1:nbgp)  == moth.djv(ngm));

    if isempty(ngp) || randi(2) > 1 % gene absent form father or random
        child.view(nge) = moth.view(ngm);
        child.div(nge)  = moth.div(ngm);
        child.djv(nge)  = moth.djv(ngm);
        child.acc(nge)  = moth.acc(ngm);
        child.whe(nge)  = moth.whe(ngm);
        child.nbr(nge)  = moth.nbr(ngm);
    else
        child.view(nge) = fath.view(ngp);
        child.div(nge)  = fath.div(ngp);
        child.djv(nge)  = fath.djv(ngp);
        child.acc(nge)  = fath.acc(ngp);
        child.whe(nge)  = fath.whe(ngp);
        child.nbr(nge)  = fath.nbr(ngp);
    end

    if ~isempty(ngp) % canceling of the father's genes already copied
        nbgp            = nbgp - 1;
        fath.view(ngp)  = [];
        fath.div(ngp)   = [];
        fath.djv(ngp)   = [];
        fath.acc(ngp)   = [];
        fath.whe(ngp)   = [];
        fath.nbr(ngp)   = [];
    end
end

for ngp = 1 : nbgp % genes present only in the father go to the child
    nge = nge + 1;      
    child.view(nge) = fath.view(ngp);
    child.div(nge) = fath.div(ngp);
    child.djv(nge) = fath.djv(ngp);
    child.acc(nge) = fath.acc(ngp);
    child.whe(nge) = fath.whe(ngp);
    child.nbr(nge) = fath.nbr(ngp);
end



