function visu_trajectory(Ch, Circuit, Dij)

% i, j, di, dj at start

i   =  5; % starting point
j   = 16;
di  =  0; % starting direction
dj  = .1;
n   = size(Circuit,1);

persistent already_called

if isempty(already_called) 
    visu_circuit(Circuit) % plot the track only at first call
    already_called = true; 
end

nbpaCh = length(Ch.nge);

for npa = 1 : nbpaCh
    nge = Ch.nge(npa);

    if nge ~= 0
        acc              = Ch.acc(nge); % acceleration
        whe              = Ch.whe(nge); % wheel
        [div, djv, card] = c2v(di,dj);
        [di,dj]          = v2c(Ch.div(nge),Ch.djv(nge),card);
        [i, j, di, dj]   = run(i, j, di, dj, acc, whe, Dij);
    
        visu_voiture(n, i, j, di, dj, 1) % plot the car
    end
end

title(['fitness ' num2str(Ch.fit)]);

