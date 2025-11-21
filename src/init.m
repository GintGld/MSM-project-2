function pars = init()
    prompt = {'Population size (nbch)', 'Max generations (nbgen)', ...
        'fraction of selected as parents', 'Number of mutants per generation', ...
        'Max time steps in a trajectory', 'Regularization factor for time in fit function', ...
        'Circuit file', 'Dij file', 'Output file'};
    title = 'Train parameters';
    default = {'100', '500', '0.3', '60', '500', '0.1', ...
            'thirdparty/Circuit1.mat', 'thirdparty/Dij.mat', ''};

    answer = inputdlg(prompt, title, [1 50], default);

    pars = struct();

    if isempty(answer)
        return;
    end

    pars.nbch =      str2double(answer{1});
    pars.nbgen =     str2double(answer{2});
    pars.nbsl_frac = str2double(answer{3});
    pars.nbmu =      str2double(answer{4});
    pars.max_steps = str2double(answer{5});
    pars.reg =       str2double(answer{6});
    pars.circuit_file = answer{7};
    pars.Dij_file =     answer{8};
    pars.output_file =  answer{9};

    % Number of parents to take during crossover
    pars.nbsl = max(2,ceil(pars.nbch*pars.nbsl_frac));
end