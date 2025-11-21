function show_results(circuit_file, res_file)
    % loads Ch, bestCh, best_history
    % load('test.mat');
    load(circuit_file, 'Circuit');
    load(res_file, 'bestCh', 'best_history');
    load('thirdparty/Dij.mat','Dij');

    visu_circuit(Circuit);
    visu_trajectory(bestCh, Circuit, Dij);

    figure; plot(best_history); xlabel('Generation'); ylabel('Best fitness'); title('Evolution of best fitness');
end