% main.m - Genetic learning controller for circuit driving
% Assumes provided functions are in folder students_etudiants/AG_circuit
% Usage: run this script in MATLAB with that folder on the path.

rng(1); % for reproducibility
addpath('thirdparty');
addpath('src');

pars = init();

% load circuit and Dij
load(pars.circuit_file, 'Circuit');
load(pars.Dij_file, 'Dij');

% preprocess circuit: replace -1 by distances to finish
Circuit = distance(Circuit);

res = train(Circuit, Dij, pars);

% show best chromosome trajectory
fprintf('\nBest chromosome fitness = %.2f (crash=%d, line=%d)\n', res.bestCh.fit, res.bestCh.crash, res.bestCh.line);

% save full result for later redraw
save_result(res, pars.output_file);
