function res = train(Ch, best_history, Circuit, Dij, cfg)
    for g = 1:cfg.nbgen
        % evaluate all children by simulating trajectories
        for k = 1:cfg.nbch
            Ch(k) = simulate_chromosome(Ch(k), Circuit, cfg.max_steps, cfg.reg, Dij);
        end

        % evaluate fitness already stored in Ch
        fits = [Ch.fit];
        [sorted_fits, idx] = sort(fits);
        best_history(g) = sorted_fits(1);
        fprintf('Gen %3d: best fit = %.2f  median = %.2f\n', g, sorted_fits(1), median(fits));

        % select best nbsl as parents
        parents = Ch(idx(1:cfg.nbsl));
    
        % create new population via crossover
        Ch = create_population(parents, cfg.nbch);
    
        % mutate population (parents reserved inside create_population per description)
        Ch = mutate(Ch, cfg.nbsl, cfg.nbmu, cfg.nbch);
    end

    res = struct();

    [~, best_idx] = min([Ch.fit]);
    res.bestCh = Ch(best_idx);
    res.Ch = Ch;
    res.best_history = best_history;
    res.Circuit = Circuit;
end