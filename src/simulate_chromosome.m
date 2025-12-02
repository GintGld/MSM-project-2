function Chk = simulate_chromosome(Chk, Circuit, max_steps, reg, Dij)
    % reset counters for this simulation
    Chk.nbr(:) = 0;
    Chk.nge = [];
    Chk.crash = false; Chk.line = false;

    start_i = 5;
    start_j = 16;
    start_di = 0;
    start_dj = 1;
    i = start_i; j = start_j; di = 0; dj = 1;

    for t = 1:max_steps
        [div, djv, card] = c2v(di,dj);
        [~, view] = car_view(Circuit, i, j, card);

        % look for matching gene
        gene_idx = find( (Chk.view==view) & (Chk.div==div) & (Chk.djv==djv), 1);
        if isempty(gene_idx)
            % add gene with random action
            acc = randi([0,2]);
            whe = randi([-1,1]);
            Chk.view(end+1) = view;
            Chk.div(end+1) = div;
            Chk.djv(end+1) = djv;
            Chk.acc(end+1) = acc;
            Chk.whe(end+1) = whe;
            Chk.nbr(end+1) = 1;
            gene_idx = numel(Chk.view);
        else
            Chk.nbr(gene_idx) = Chk.nbr(gene_idx) + 1;
            acc = Chk.acc(gene_idx);
            whe = Chk.whe(gene_idx);
        end
        Chk.nge(end+1) = gene_idx;

        i_old = i; j_old = j;
        [i, j, di, dj] = run(i, j, di, dj, acc, whe, Dij);

        % check crash (outside circuit) -- Circuit entries outside track are 0 by problem description
        if i<1 || j<1 || i>size(Circuit,1) || j>size(Circuit,2) || Circuit(i,j)==0
            Chk.crash = true; break;
        end
        % check finish line crossing: assume finish has distance 0/1
        if Circuit(i,j) <= 1
            Chk.line = true; break;
        end

        % Don't allow car to cross non-track cell
        %  0  0  *      0  0 -1
        %  0  0 -1  ->  0  0 -1
        % -1 -1 -1      * -1 -1
        if abs(i - i_old) == 2 && abs(j - j_old) == 2 && Circuit((i+i_old)/2,(j+j_old)/2) == 0
            Chk.crash = true; break;
        end

        % This jump is impossible in normal track.
        % Prevents from turning 180 at the start.
        if Circuit(i_old,j_old) - Circuit(i,j) > 50
            Chk.crash = true; break;
        end
    end

    if Chk.crash
        Chk.fit = double(inf);
    else
        if i>=1 && i<=size(Circuit,1) && j>=1 && j<=size(Circuit,2)
            Chk.fit = Circuit(i,j) + t*reg;
        else
            Chk.fit = double(inf);
        end
    end

    if Circuit(i,j) <= 1
        % penalty for wrong-way crossing
        if di*start_di + dj*start_dj < 0
            Chk.line = false;
            Chk.fit = double(inf);
        end
    end
end