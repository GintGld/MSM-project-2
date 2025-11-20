% ================================
% Main racetrack launcher script
% ================================

clear; clc;

% Ask user whether to load or create
choice = questdlg( ...
    'Do you want to use an existing race track or create a new one?', ...
    'Racetrack selection', ...
    'load existing', 'create new one', ...
    'create new one');

% If user closes the dialog, just stop
if isempty(choice)
    return;
end

M = [];
D = [];

switch choice
    case 'create new one'
        % Call your function that builds track + distance
        [M, D] = grid_creator;

    case 'load existing'
        % Let user pick a .mat file
        [fileName, filePath] = uigetfile('*.mat', 'Select racetrack file');
        if isequal(fileName, 0)
            % User cancelled
            return;
        end

        data = load(fullfile(filePath, fileName));

        % Expect variables M and D inside the file
        if ~isfield(data, 'M') || ~isfield(data, 'D')
            errordlg('Selected file does not contain variables M and D.', ...
                     'Invalid file', 'modal');
            return;
        end

        M = data.M;
        D = data.D;

    otherwise
        % Should not happen, but just in case
        return;
end

% If something went wrong and we don't have M/D, stop
if isempty(M) || isempty(D)
    return;
end

% ================================
% Plot M and D side by side
% ================================

% --- Build custom colormap for M ---
anchorVals = [-1   -0.5   0    0.5    1];
anchorRGB  = [139  133  136; ... % -1
               89   38   11; ...  % -0.5
                0   87   63; ...  %  0
              219  154   74; ...  %  0.5
              196    2   51] / 255; % 1

Ncolors = 256;
x = linspace(-1, 1, Ncolors);
cmap = zeros(Ncolors, 3);

for k = 1:3
    cmap(:, k) = interp1(anchorVals, anchorRGB(:, k), x, 'linear');
end

% --- Create figure and axes ---
fig = figure('Name', 'Racetrack: M and D', 'NumberTitle', 'off');
tiledlayout(fig, 1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

% ----- Left: M -----
ax1 = nexttile;
imagesc(ax1, M, [-1 1]);
axis(ax1, 'image');
colormap(ax1, cmap);      % custom colormap for M
set(ax1, 'XTick', [], 'YTick', []);   % no ticks
title(ax1, 'Track (M)');
% No colorbar for M

% ----- Right: D -----
ax2 = nexttile;
imagesc(ax2, D);
axis(ax2, 'image');
colormap(ax2, turbo);     % turbo for D
set(ax2, 'XTick', [], 'YTick', []);   % no ticks
title(ax2, 'Distance field (D)');
colorbar(ax2);            % only D has a colorbar
