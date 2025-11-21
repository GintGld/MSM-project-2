function res = train(Circuit, Dij, pars)
    % initialize empty chromosome struct array as specified in the problem
    Ch(1:pars.nbch) = struct('view',[],'div',[],'djv',[],'acc',[],'whe',[],'fit',0,'nbr',[],'nge',[],'crash',false,'line',false);

    % Main evolutionary loop
    best_history = zeros(pars.nbgen,1);
    for g = 1:pars.nbgen
        % evaluate all children by simulating trajectories
        for k = 1:pars.nbch
            Ch(k) = simulate_chromosome(Ch(k), Circuit, pars.max_steps, pars.reg, Dij);
        end

        % evaluate fitness already stored in Ch
        fits = [Ch.fit];
        [sorted_fits, idx] = sort(fits);
        best_history(g) = sorted_fits(1);
        fprintf('Gen %3d: best fit = %.2f  median = %.2f\n', g, sorted_fits(1), median(fits));

        % select best nbsl as parents
        parents = Ch(idx(1:pars.nbsl));
    
        % create new population via crossover
        Ch = create_population(parents, pars.nbch);
    
        % mutate population (parents reserved inside create_population per description)
        Ch = mutate(Ch, pars.nbsl, pars.nbmu, pars.nbch);
    end

    res = struct();

    [~, best_idx] = min([Ch.fit]);
    res.bestCh = Ch(best_idx);
    res.Ch = Ch;
    res.best_history = best_history;
end