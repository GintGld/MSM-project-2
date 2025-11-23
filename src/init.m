function cfg = init()
    cfg = struct();

    [file, path] = uigetfile({'*.mat','MAT-files'}, 'Select a circuit file');
    if isequal(file,0)
        error('Didn''t get any file');
    else
        fullpath = fullfile(path, file);
        circuit_file = fullpath;
        disp(['Use circuit: ', fullpath]);
    end
        
    load(circuit_file, 'Circuit');
    cfg.Circuit = Circuit;

    % Ask user to choose output file
    [file, path] = uiputfile('output.mat', 'Save as');
    if isequal(file,0)
        error('Didn''t get any file');
    else
        fullpath = fullfile(path, file);
        cfg.output_file = fullpath;
        disp(['Save file to: ', fullpath]);
    end

    prompt = {'Population size (nbch)', 'Max generations (nbgen)', ...
        'Fraction of selected as parents', 'Number of mutants per generation', ...
        'Max time steps in a trajectory', 'Regularization factor for time in fit function'};
    title = 'Train parameters';
    default = {'100', '500', '0.3', '60', '500', '0.1'};

    answer = inputdlg(prompt, title, [1 50], default);

    if isempty(answer)
        error('Din''t get any answer');
    end

    cfg.nbch =      str2double(answer{1});
    cfg.nbgen =     str2double(answer{2});
    cfg.nbsl_frac = str2double(answer{3});
    cfg.nbmu =      str2double(answer{4});
    cfg.max_steps = str2double(answer{5});
    cfg.reg =       str2double(answer{6});

    % Number of parents to take during crossover
    cfg.nbsl = max(2,ceil(cfg.nbch*cfg.nbsl_frac));

    cfg.Ch(1:cfg.nbch) = struct('view',[],'div',[],'djv',[], ...
                                'acc',[],'whe',[],'fit',0, ...
                                'nbr',[],'nge',[],'crash',false,'line',false);
    cfg.best_history = zeros(cfg.nbgen,1);
end