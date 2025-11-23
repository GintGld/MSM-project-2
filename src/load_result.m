function [Ch, best_history, bestCh, Circuit] = load_result(file)
    data = load(file);
    if ~isfield(data, 'Ch') || ~isfield(data, 'best_history') || ~isfield(data, 'bestCh') || ~isfield(data, 'Circuit')
        error('MAT-file must contain Ch, best_history, bestCh, Circuit.');
    end

    Ch =           data.Ch;
    best_history = data.best_history;
    bestCh =       data.bestCh;
    Circuit =      data.Circuit;
end