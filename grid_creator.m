function [M, D] = grid_creator
    % Grid creator - builds a race track, finds start edges,
    % then runs left- and right-hand wall followers on the inner track.

    % Main loop to allow restart on invalid track
    while true
        % ---------------------------
        % STEP 1 : Get grid + startDir
        % ---------------------------
        [M, startDir] = paint_grid();

        if isempty(M) || isempty(startDir)
            return;
        end

        % ---------------------------
        % STEP 2 : Find start cell (value = 1)
        % ---------------------------
        [startRow, startCol] = find(M == 1);
        if isempty(startRow)
            if ~show_error_dialog()
                return;
            end
            continue;
        end
        startRow = startRow(1);
        startCol = startCol(1);

        % ---------------------------
        % STEP 3 : Compute start-line edges
        % ---------------------------
        [edge1, edge2] = find_start_line_edges(M, startRow, startCol, startDir);

        % ---------------------------
        % STEP 4 : Decide which edge = left/right follower
        % ---------------------------
        dir0 = dirStringToIdx(startDir);

        switch startDir
            case {'East','North'}
                startLeft  = edge1;
                startRight = edge2;
            case {'West','South'}
                startLeft  = edge2;
                startRight = edge1;
            otherwise
                if ~show_error_dialog()
                    return;
                end
                continue;
        end

        % ---------------------------
        % STEP 5 : Run both wall followers
        % ---------------------------
        try
            [leftPath, rightPath] = run_wall_followers(M, startLeft, startRight, dir0);
        catch
            if ~show_error_dialog()
                return;
            end
            continue;
        end

        % ---------------------------
        % STEP 6 : Caculate distances to finish line
        % ---------------------------

        % D has same size as M, initialise with -1
        [nRows, nCols] = size(M);
        D = -1 * ones(nRows, nCols);

        % We only care about track cells: -0.5 or -1
        trackMask = (M == -0.5) | (M == -1);

        % Pre-extract path coordinates for speed
        leftRows  = leftPath(:, 1);
        leftCols  = leftPath(:, 2);
        rightRows = rightPath(:, 1);
        rightCols = rightPath(:, 2);

        for r = 1:nRows
            for c = 1:nCols
                if ~trackMask(r, c)
                    continue;
                end

                % --- Nearest point on left path ---
                dRL = leftRows - r;
                dCL = leftCols - c;
                dist2L = dRL.^2 + dCL.^2;          % squared distances
                [~, idxL] = min(dist2L);          % index in leftPath

                % --- Nearest point on right path ---
                dRR = rightRows - r;
                dCR = rightCols - c;
                dist2R = dRR.^2 + dCR.^2;
                [~, idxR] = min(dist2R);          % index in rightPath

                % Distance = average of the two indices
                D(r, c) = (idxL + idxR) / 2;
            end
        end

        % remove any values not within the track
        D(~trackMask) = NaN;

        % Plot heat map with turbo (optional)
        %figure;
        %imagesc(D);
        %axis image;
        %colormap('turbo');
        %colorbar;
        %title('Distance field');
        
        % ---------------------------
        % STEP 7 : Ask user if they want to save
        % ---------------------------
        choice = questdlg( ...
            'Do you want to save your racetrack?', ...
            'Save racetrack', ...
            'Yes', 'No', 'No');

        if isempty(choice) || strcmp(choice, 'No')
            % User chose not to save (or closed dialog) -> just return M, D
            break;
        end

        % User chose "Yes" -> ask for folder name in a GUI prompt
        folderName = '';
        invalidChars = '\/:*?"<>|';

        while true
            answer = inputdlg( ...
                'Enter a folder name for this racetrack:', ...
                'Racetrack folder name', ...
                [1 50], ...
                {folderName});

            % If user cancels the dialog, just return (no saving)
            if isempty(answer)
                break;
            end

            folderName = strtrim(answer{1});

            % Check basic validity: non-empty, no invalid chars
            if isempty(folderName)
                uiwait(warndlg('Folder name cannot be empty.', ...
                               'Invalid folder name', 'modal'));
                continue;
            end

            if any(ismember(folderName, invalidChars))
                uiwait(warndlg( ...
                    'Folder name contains invalid characters: \ / : * ? " < > |', ...
                    'Invalid folder name', 'modal'));
                continue;
            end

            % Passed validation -> try to create under "data"
            baseDir = 'data';
            if ~exist(baseDir, 'dir')
                mkdir(baseDir);
            end

            % Resolve collisions: folderName, folderName-2, folderName-3, ...
            finalFolder = fullfile(baseDir, folderName);
            if exist(finalFolder, 'dir')
                idx = 2;
                while true
                    candidate = fullfile(baseDir, sprintf('%s-%d', folderName, idx));
                    if ~exist(candidate, 'dir')
                        finalFolder = candidate;
                        break;
                    end
                    idx = idx + 1;
                end
            end

            % Create the folder
            mkdir(finalFolder);

            % Save M and D in track_data.mat
            save(fullfile(finalFolder, 'track_data.mat'), 'M', 'D');

            % All done, break out of name-asking loop
            break;
        end

        % Successfully completed (with or without saving), exit the while loop
        break;
    end
end

function retry = show_error_dialog()
    % Show error dialog with Try Again and Dismiss options
    % Returns true if user wants to try again, false if dismiss
    choice = questdlg('Track invalid: part of the track is either 1 cell thin or it doesn''t close in on itself', ...
                      'Invalid Track', ...
                      'Try Again', 'Dismiss', 'Try Again');
    retry = strcmp(choice, 'Try Again');
end

function [edge1, edge2] = find_start_line_edges(M, startRow, startCol, startDir)

    switch startDir
        case {'North','South'}    % horizontal line
            % left
            leftEdge = startCol;
            for j = startCol-1:-1:1
                if M(startRow,j) < 0
                    leftEdge = j;
                else
                    break;
                end
            end
            % right
            rightEdge = startCol;
            for j = startCol+1:size(M,2)
                if M(startRow,j) < 0
                    rightEdge = j;
                else
                    break;
                end
            end
            edge1 = [startRow, leftEdge];
            edge2 = [startRow, rightEdge];

        case {'East','West'}     % vertical line
            % up
            topEdge = startRow;
            for i = startRow-1:-1:1
                if M(i,startCol) < 0
                    topEdge = i;
                else
                    break;
                end
            end
            % bottom
            bottomEdge = startRow;
            for i = startRow+1:size(M,1)
                if M(i,startCol) < 0
                    bottomEdge = i;
                else
                    break;
                end
            end
            edge1 = [topEdge, startCol];
            edge2 = [bottomEdge, startCol];

        otherwise
            % Invalid direction - will be caught by main function
            error('Invalid start direction: %s', startDir);
        end
end
function dirIdx = dirStringToIdx(s)
    switch s
        case 'East'
            dirIdx = 1;
        case 'South'
            dirIdx = 2;
        case 'West'
            dirIdx = 3;
        case 'North'
            dirIdx = 4;
        otherwise
            % Invalid direction - will be caught by try-catch in main
            error('Invalid direction: %s', s);
    end
end

function [leftPath, rightPath] = run_wall_followers(M, startLeft, startRight, dir0)

    leftPath  = startLeft;
    rightPath = startRight;
    dirL = dir0;
    dirR = dir0;

    statusL = "running"; msgL = "";
    statusR = "running"; msgR = "";

    maxSteps = numel(M) * 10;

    step = 0;
    while step < maxSteps && (statusL=="running" || statusR=="running")
        step = step + 1;

        if statusL=="running"
            [leftPath, dirL, statusL, msgL] = ...
                step_wall_follower(M, leftPath, dirL, "left", rightPath);
        end
        if statusR=="running"
            [rightPath, dirR, statusR, msgR] = ...
                step_wall_follower(M, rightPath, dirR, "right", leftPath);
        end

        if statusL=="error"
            error('Track validation failed');
        end
        if statusR=="error"
            error('Track validation failed');
        end
    end

    if step >= maxSteps
        error('Track validation failed');
    end

    if ~(statusL=="closed" && statusR=="closed")
        error('Track validation failed');
    end
end

function [path, dirIdx, status, errmsg] = step_wall_follower(M, path, dirIdx, hand, otherPath)

    status = "running";
    errmsg = "";

    % direction map: [di dj]
    persistent DirMap
    if isempty(DirMap)
        DirMap = [0 1; 1 0; 0 -1; -1 0];
    end

    wrap = @(k) mod(k-1,4)+1;

    in_bounds = @(ii,jj) ii>=1 && ii<=size(M,1) && jj>=1 && jj<=size(M,2);
    is_empty  = @(ii,jj) in_bounds(ii,jj) && (M(ii,jj) < 0);

    curr = path(end,:);
    i0 = curr(1); j0 = curr(2);

    dirFront = dirIdx;

    if hand == "right"
        dir1 = wrap(dirIdx+1);  % right
        dir2 = dirFront;        % front
        turn = wrap(dirIdx-1);  % turn left
    else
        dir1 = wrap(dirIdx-1);  % left
        dir2 = dirFront;        % front
        turn = wrap(dirIdx+1);  % turn right
    end

    v1 = DirMap(dir1,:);
    v2 = DirMap(dir2,:);

    m1 = [i0 j0] + v1;
    m2 = [i0 j0] + v2;

    newPos = [];

    if is_empty(m1(1), m1(2))
        newPos = m1;
        dirIdx = dir1;
    elseif is_empty(m2(1), m2(2))
        newPos = m2;
        dirIdx = dir2;
    else
        dirIdx = turn;
        return;  % rotate in place
    end

    startPos = path(1,:);

    % ---- TERMINATION CONDITIONS ----

    % closed loop
    if all(newPos == startPos) && size(path,1)>1
        path = [path; newPos];
        status = "closed";
        return;
    end

    % hits other follower
    if ~isempty(otherPath) && ismember(newPos, otherPath, 'rows')
        status = "error";
        errmsg = "Track validation failed";
        return;
    end

    % continue
    path = [path; newPos];
end

