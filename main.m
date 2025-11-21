% main.m - Genetic learning controller for circuit driving
% Assumes provided functions are in folder students_etudiants/AG_circuit
% Usage: run this script in MATLAB with that folder on the path.

rng(1); % for reproducibility
addpath('AG_circuit');

% Parameters
nbch = 100;           % population size
nbgen = 10;         % max generations
nbsl_frac = 0.3;    % fraction selected as parents
nbmu = 60;            % number of mutants per generation
max_steps = 500;      % max time steps in a trajectory
start_i = 5; start_j = 16; % given starting point in Circuit coordinates
reg = 1;                % regularization factor for race time

% load circuit and Dij
load('AG_circuit/Circuit1.mat','Circuit');
load('AG_circuit/Dij.mat','Dij');

% preprocess circuit: replace -1 by distances to finish
Circuit = distance(Circuit);

% helper numbers
nbsl = max(2,ceil(nbch*nbsl_frac));

% initialize empty chromosome struct array as specified in the problem
Ch(1:nbch) = struct('view',[],'div',[],'djv',[],'acc',[],'whe',[],'fit',0,'nbr',[],'nge',[],'crash',false,'line',false);

% Main evolutionary loop
best_history = zeros(nbgen,1);
for g = 1:nbgen
    % evaluate all children by simulating trajectories
    for k = 1:nbch
        Ch(k) = simulate_chromosome(Ch(k), Circuit, max_steps, reg, Dij);
    end

    % evaluate fitness already stored in Ch
    fits = [Ch.fit];
    [sorted_fits, idx] = sort(fits);
    best_history(g) = sorted_fits(1);
    fprintf('Gen %3d: best fit = %.2f  median = %.2f\n', g, sorted_fits(1), median(fits));

    % select best nbsl as parents
    parents = Ch(idx(1:nbsl));

    % create new population via crossover
    Ch = create_population(parents, nbch);

    % mutate population (parents reserved inside create_population per description)
    Ch = mutate(Ch, nbsl, nbmu, nbch);
end

% show best chromosome trajectory
[~, best_idx] = min([Ch.fit]);
bestCh = Ch(best_idx);
fprintf('\nBest chromosome fitness = %.2f (crash=%d, line=%d)\n', bestCh.fit, bestCh.crash, bestCh.line);

% save full result for later redraw
save('training_result.mat', 'Ch', 'bestCh', 'best_history');

visu_circuit(Circuit);
visu_trajectory(bestCh, Circuit, Dij);

% plot progress
figure; plot(best_history(1:g)); xlabel('Generation'); ylabel('Best fitness'); title('Evolution of best fitness');
