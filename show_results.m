% loads Ch, bestCh, best_history
load('training_result.mat');

visu_circuit(Circuit);
visu_trajectory(bestCh, Circuit, Dij);

figure; plot(best_history(1:g)); xlabel('Generation'); ylabel('Best fitness'); title('Evolution of best fitness');