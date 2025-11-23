% main.m - Genetic learning controller for circuit driving
% Assumes provided functions are in folder students_etudiants/AG_circuit
% Usage: run this script in MATLAB with that folder on the path.

rng(1); % for reproducibility
addpath('thirdparty');
addpath('src');

cfg = init();

% load Dij
load('thirdparty/Dij.mat', 'Dij');

% preprocess circuit: replace -1 by distances to finish
cfg.Circuit = distance(cfg.Circuit);

res = train(cfg.Ch, cfg.best_history, cfg.Circuit, Dij, cfg);

% show best chromosome trajectory
fprintf('\nBest chromosome fitness = %.2f (crash=%d, line=%d)\n', res.bestCh.fit, res.bestCh.crash, res.bestCh.line);

% save full result for later redraw
save_result(res, cfg.output_file);
