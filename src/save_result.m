function save_result(res, output_file)
    Ch =           res.Ch;
    bestCh =       res.bestCh;
    best_history = res.best_history;

    save(output_file, 'Ch', 'bestCh', 'best_history');
end