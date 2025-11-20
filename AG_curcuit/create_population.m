function Ch = create_population(Ch, nbch)

nbsel = length(Ch);

for nch = nbsel + 1 : nbch
    ncm          = randi(nbsel-1); % mother chromosome number
    ncf          = randi(nbsel-1); % father chromosome number
    child        = crossing(Ch(ncm),Ch(ncf)); % child creation
    Ch(nch).view = child.view;
    Ch(nch).div  = child.div;
    Ch(nch).djv  = child.djv;
    Ch(nch).acc  = child.acc;
    Ch(nch).whe  = child.whe;
    Ch(nch).nbr  = child.nbr;
end




