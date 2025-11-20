function [M_out, startDir] = paint_grid
    % Interactive grid painter
    % Returns:
    %   M_out    - painted matrix
    %   startDir - start direction ('North','East','South','West')

    % Defaults for outputs (in case user closes without baking)
    M_out    = [];
    startDir = [];

    % Grid size
    N = 40;
    M = zeros(N);   % initial matrix, all 0

    % Create figure and axes
    fig = figure('Name','Grid Painter', ...
                 'NumberTitle','off', ...
                 'MenuBar','none', ...
                 'ToolBar','none');
    ax  = axes('Parent',fig, 'Position',[0.15 0.25 0.65 0.65]);

    % Show the matrix (note range now -1..1)
    hImg = imagesc(M, [-1 1]);
    axis(ax, 'image');
    
    % Add title to the plot
    title(ax, 'Create your race track');

    % ---- CUSTOM COLORMAP ----
    % Anchor values and colors:
    %  1   -> (196, 2, 51) Start position
    %  0.5 -> (219, 154, 74) Start line
    %  0   -> (0, 87, 63) Grass
    % -0.5 -> (89, 38, 11) Dirt
    % -1   -> (139, 133, 136) Track
    anchorVals = [-1   -0.5   0    0.5    1];
    anchorRGB  = [139  133  136; ... % -1
                   89   38   11;  ... % -0.5
                   0    87   63;   ... %  0
                   219  154  74;  ... %  0.5
                   196    2   51] / 255; % 1

    Ncolors = 256;
    x = linspace(-1, 1, Ncolors);
    cmap = zeros(Ncolors, 3);
    for k = 1:3
        cmap(:,k) = interp1(anchorVals, anchorRGB(:,k), x, 'linear');
    end
    colormap(ax, cmap);
    
    % Remove ticks and tick labels
    set(ax, 'XTick', []);
    set(ax, 'YTick', []);
    set(ax, 'XTickLabel', []);
    set(ax, 'YTickLabel', []);

    % ---- UI CONTROLS ----

    % Brush VALUE selection (track / dirt / grass)
    bg = uibuttongroup('Units','normalized', ...
        'Position',[0.05 0.05 0.35 0.12], ...
        'Title','Terrain type', ...
        'SelectionChangedFcn',@brushValueChanged);

    rbTrack = uicontrol(bg,'Style','radiobutton', ...
        'String','Track (-1)', ...
        'Tag','track', ...
        'Units','normalized', ...
        'Position',[0.05 0.60 0.9 0.30]);

    rbDirt = uicontrol(bg,'Style','radiobutton', ...
        'String','Dirt (-0.5)', ...
        'Tag','dirt', ...
        'Units','normalized', ...
        'Position',[0.05 0.30 0.9 0.30]);

    rbGrass = uicontrol(bg,'Style','radiobutton', ...
        'String','Grass (0)', ...
        'Tag','grass', ...
        'Units','normalized', ...
        'Position',[0.05 0.00 0.9 0.30]);

    % Explicitly select Track as default
    bg.SelectedObject = rbTrack;

    % Slider for brush WIDTH (integer 1..10)
    brushSlider = uicontrol('Style','slider', ...
        'Min',1, 'Max',10, 'Value',1, ...
        'SliderStep',[1/9 1/9], ...   % nominal step of 1
        'Units','normalized', ...
        'Position',[0.45 0.08 0.25 0.04], ...
        'TooltipString','Brush width (integer cells)', ...
        'Callback',@brushWidthChanged);

    uicontrol('Style','text', ...
        'Units','normalized', ...
        'Position',[0.45 0.04 0.25 0.03], ...
        'String','Brush width', ...
        'HorizontalAlignment','center');

    % Clear button
    clearButton = uicontrol('Style','pushbutton', ...
        'String','Clear all', ...
        'Units','normalized', ...
        'Position',[0.05 0.18 0.15 0.05], ...
        'Callback',@clearGrid);

    % Start-position button
    startButton = uicontrol('Style','pushbutton', ...
        'String','Set Start', ...
        'Units','normalized', ...
        'Position',[0.23 0.18 0.15 0.05], ...
        'Callback',@placeStart);

    % Bake button (replaces Save)
    bakeButton = uicontrol('Style','pushbutton', ...
        'String','Bake', ...
        'Units','normalized', ...
        'Position',[0.42 0.18 0.15 0.05], ...
        'Callback',@bakeGrid);

    % Start direction selector
    dirPopup = uicontrol('Style','popupmenu', ...
        'Units','normalized', ...
        'Position',[0.62 0.18 0.15 0.05], ...
        'String',{'North','East','South','West'}, ...
        'Callback',@directionChanged);

    uicontrol('Style','text', ...
        'Units','normalized', ...
        'Position',[0.62 0.15 0.15 0.025], ...
        'String','Start direction', ...
        'HorizontalAlignment','center');

    % Status text (top-right) showing current config
    statusText = uicontrol('Style','text', ...
        'Units','normalized', ...
        'Position',[0.65 0.92 0.30 0.05], ...
        'HorizontalAlignment','left', ...
        'String','');

    % ---- STORE DATA ----
    data.M            = M;
    data.hImg         = hImg;
    data.ax           = ax;
    data.brushSlider  = brushSlider;
    data.clearButton  = clearButton;
    data.startButton  = startButton;
    data.bakeButton   = bakeButton;
    data.dirPopup     = dirPopup;
    data.statusText   = statusText;
    data.brushGroup   = bg;

    % Logical / meta state
    data.brushValue   = -1;                % default = track
    data.startDir     = 'North';           % default direction
    data.lastClick    = [NaN NaN];         % last painted cell
    data.baked        = false;             % set true when Bake pressed

    guidata(fig, data);

    % Mouse callbacks
    fig.WindowButtonDownFcn = @startPaint;
    fig.WindowButtonUpFcn   = @stopPaint;

    % Initialise status text
    updateStatus(fig);

    % Block execution until Bake or figure close
    uiwait(fig);

    % On resume: if figure still exists, get data and outputs
    if isvalid(fig)
        data = guidata(fig);
        if isfield(data,'baked') && data.baked
            M_out    = data.M;
            startDir = data.startDir;
        end
        delete(fig);
    end
end

% ================== CALLBACKS ==================

function startPaint(fig, ~)
    % called when mouse is pressed
    fig.WindowButtonMotionFcn = @doPaint;  % start painting while moving
    doPaint(fig, []);                      % also paint where we first click
end

function stopPaint(fig, ~)
    % called when mouse released
    fig.WindowButtonMotionFcn = '';        % stop painting
end

function doPaint(fig, ~)
    data = guidata(fig);
    if isempty(data) || ~isfield(data,'ax')
        return;
    end

    % Current mouse position in axis coordinates
    cp = get(data.ax, 'CurrentPoint');
    x = cp(1,1);
    y = cp(1,2);

    % Convert to matrix indices
    i = round(y);
    j = round(x);

    [nRows, nCols] = size(data.M);
    if i >= 1 && i <= nRows && j >= 1 && j <= nCols
        % ---- BRUSH VALUE (from radio buttons) ----
        v = data.brushValue;

        % ---- INTEGER BRUSH WIDTH ----
        bw = round(max(1, min(10, data.brushSlider.Value)));
        data.brushSlider.Value = bw;             % snap slider
        half = floor((bw-1)/2);
        iMin = max(1, i-half);
        iMax = min(nRows, i+half);
        jMin = max(1, j-half);
        jMax = min(nCols, j+half);

        % Paint block
        data.M(iMin:iMax, jMin:jMax) = v;

        % Update last clicked cell (centre of brush)
        data.lastClick = [i j];

        set(data.hImg, 'CData', data.M);
        guidata(fig, data);
        drawnow;
    end
end

function clearGrid(src, ~)
    fig  = ancestor(src, 'figure');
    data = guidata(fig);

    data.M = zeros(size(data.M));   % reset to zero
    set(data.hImg, 'CData', data.M);
    data.lastClick = [NaN NaN];
    guidata(fig, data);
    drawnow;
end

function brushValueChanged(bg, event)
    % Change terrain value based on selected radio button
    fig  = ancestor(bg, 'figure');
    data = guidata(fig);

    switch event.NewValue.Tag
        case 'track'
            data.brushValue = -1;
        case 'dirt'
            data.brushValue = -0.5;
        case 'grass'
            data.brushValue = 0;
        otherwise
            data.brushValue = 0;
    end

    guidata(fig, data);
    updateStatus(fig);
end

function brushWidthChanged(src, ~)
    % Snap brush width slider to integer and update status
    fig  = ancestor(src, 'figure');
    data = guidata(fig);

    bw = round(max(1, min(10, src.Value)));
    src.Value = bw;
    guidata(fig, data);
    updateStatus(fig);
end

function directionChanged(src, ~)
    fig  = ancestor(src, 'figure');
    data = guidata(fig);

    strs = src.String;
    data.startDir = strs{src.Value};

    % Clear existing start lines and recompute if start exists
    data.M(data.M == 0.5) = -1;
    guidata(fig, data);  % Save before computing
    computeStartLine(fig);
    data = guidata(fig);  % Get updated data
    
    % Update the display
    set(data.hImg, 'CData', data.M);

    guidata(fig, data);
    updateStatus(fig);
end

function placeStart(src, ~)
    % Place a single start cell (value 1) on the last clicked -1 cell
    fig  = ancestor(src, 'figure');
    data = guidata(fig);

    i = data.lastClick(1);
    j = data.lastClick(2);

    if any(isnan([i j]))
        warndlg('Click on the grid first to choose a start position.', ...
                'No last click');
        return;
    end

    if data.M(i,j) ~= -1
        warndlg('Start can only be placed on track cells (gray).', ...
                'Invalid start position');
        return;
    end

    % Clear existing start lines and previous start position
    data.M(data.M == 0.5) = -1;
    
    % Remove any previous start (value 1)
    data.M(data.M == 1) = -1;

    % Place new start
    data.M(i,j) = 1;
    
    guidata(fig, data);  % Save before computing
    
    % Compute start line based on direction
    computeStartLine(fig);
    data = guidata(fig);  % Get updated data

    set(data.hImg, 'CData', data.M);
    guidata(fig, data);
    drawnow;
end

function bakeGrid(src, ~)
    % Finalise and return data to caller
    fig  = ancestor(src, 'figure');
    data = guidata(fig);

    % Replace start line markers (0.5) with track (-1) for final output
    data.M(data.M == 0.5) = -1;
    set(data.hImg, 'CData', data.M);
    
    data.baked = true;
    guidata(fig, data);

    % Resume execution in paint_grid
    uiresume(fig);
end

function updateStatus(fig)
    % Update the top-right status text with current color + width + direction
    data = guidata(fig);
    if ~isfield(data,'statusText') || ~ishandle(data.statusText)
        return;
    end

    % Brush value label
    switch data.brushValue
        case -1
            terrain = 'Track (-1)';
        case -0.5
            terrain = 'Dirt (-0.5)';
        case 0
            terrain = 'Grass (0)';
        otherwise
            terrain = sprintf('Value %.2f', data.brushValue);
    end

    % Brush width
    bw = round(max(1, min(10, data.brushSlider.Value)));

    % Direction
    dir = data.startDir;

    txt = sprintf('Brush: %s | Width: %d | Start dir: %s', ...
                  terrain, bw, dir);
    set(data.statusText, 'String', txt);
end

function computeStartLine(fig)
    % Compute start line based on start position and direction
    data = guidata(fig);
    [startRow, startCol] = find(data.M == 1);
    
    if isempty(startRow)
        return; % No start position set
    end
    
    [nRows, nCols] = size(data.M);
    
    switch data.startDir
        case {'North', 'South'}
            % Create horizontal start line
            % Go left from start position
            for j = startCol-1:-1:1
                if data.M(startRow, j) == -1
                    data.M(startRow, j) = 0.5;
                else
                    break; % Stop at first non-track cell
                end
            end
            % Go right from start position
            for j = startCol+1:nCols
                if data.M(startRow, j) == -1
                    data.M(startRow, j) = 0.5;
                else
                    break; % Stop at first non-track cell
                end
            end
            
        case {'East', 'West'}
            % Create vertical start line
            % Go up from start position
            for i = startRow-1:-1:1
                if data.M(i, startCol) == -1
                    data.M(i, startCol) = 0.5;
                else
                    break; % Stop at first non-track cell
                end
            end
            % Go down from start position
            for i = startRow+1:nRows
                if data.M(i, startCol) == -1
                    data.M(i, startCol) = 0.5;
                else
                    break; % Stop at first non-track cell
                end
            end
    end
    
    guidata(fig, data);  % Save the updated matrix
end
