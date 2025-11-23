function show_results(res_file)
    addpath('src');
    addpath('thirdparty');

    load(res_file, 'bestCh', 'best_history', 'Circuit');
    load('thirdparty/Dij.mat','Dij');

    visu_circuit(Circuit);
    visu_trajectory(bestCh, Circuit, Dij);

    figure; plot(best_history); xlabel('Generation'); ylabel('Best fitness'); title('Evolution of best fitness');
end