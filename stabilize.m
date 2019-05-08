%%% Stabilizes video to remain stationary
%%% Video must be an image sequence, with file names consisting of the file
%%%     extension and the prefix 1, 2, 3,...,n for an n-frame long video
%%% User provides video length and specifies input and output folder, both 
%%%     must be valid (output folder will be create if non-existing

function stabilize(input_folder, output_folder, file_type, video_length, Gauss_levels)

    % default Gauss_levels=1 if not specified
    if nargin < 5
        Gauss_levels = 1;
    end
    
    % check input folder
    if(~isdir(input_folder))
        disp('Input folder not found. Exiting.');
        return;     
    end

    % load black-and-white and full color video
    [BW, color] = load_video(input_folder, file_type, video_length);
    
    % get video dimensions and set region of interest to entire video
    [height, width, length] = size(BW);
    roi = ones(height, width);
    
    % calculate motion between each pair of frames
    A_cummulative = eye(2);
    T_cummulative = zeros(2,1);
    h = waitbar(0, 'Estimating motion...');
    for i = 1:(length-1)
        [A,T] = align_frames(BW(:,:,i+1), BW(:,:,i), roi, Gauss_levels);
        A_all(:,:,i) = A;
        T_all(:,:,i) = T;
        [A_cummulative, T_cummulative] = warp_accumulate(A_cummulative, T_cummulative, A, T);
        waitbar(i/(length-1));
    end
    close(h)
    
    % stabilize to last frame
    h = waitbar(0, 'Stabilizing...');
    % stable(:,:,length) = BW(:,:,length); % match last frame
    A_cummulative = eye(2);
    T_cummulative = zeros(2, 1);
    for i = (length-1):-1:1
        [A_cummulative, T_cummulative] = warp_accumulate(A_cummulative, T_cummulative, A_all(:,:,i), T_all(:,:,i));
        color(:,:,1,i) = warp(double(color(:,:,1,i)), A_cummulative, T_cummulative);
        color(:,:,2,i) = warp(double(color(:,:,2,i)), A_cummulative, T_cummulative);
        color(:,:,3,i) = warp(double(color(:,:,3,i)), A_cummulative, T_cummulative);
        waitbar((length-1-i)/(length-1));
    end
    close(h);
    
    % write video to output folder
    write_video(color, output_folder, file_type);
end

% -------------------------------------------------------------------------
%%% Aligns current frame to next
function [A_cummulative, T_cummulative] = align_frames(frame_next, frame_current, roi, Gauss_levels)
    
    frame_current_initial = frame_current;
    A_cummulative = eye(2);
    T_cummulative = zeros(2, 1);
    
    for i = Gauss_levels:-1:0
        
        % extract pyramid level
        level_next = extract_Gauss(frame_next, i);
        level_current = extract_Gauss(frame_current, i);
        level_roi = extract_Gauss(roi, i);
        
        % calculate motion
        [f_x,f_y,f_t] = derivatives(level_next, level_current);
        [A,T] = calc_motion(f_x, f_y, f_t, level_roi);
        T = (2^i) * T;
        [A_cummulative, T_cummulative] = warp_accumulate(A_cummulative, T_cummulative, A, T);
        
        % warp next frame based on motion from current
        frame_current = warp(frame_current_initial, A_cummulative, T_cummulative);
    end
    
end

% -------------------------------------------------------------------------
%%% Calculates motion from current to next frame
function [A, T] = calc_motion(f_x, f_y, f_t, roi)
    
    [height, width] = size(f_x); % get dimensions for search grid
    [x,y] = meshgrid((1:width)-width/2, (1:height)-height/2); % generate search grid
    
    % trim edges (3 pixels off each side)
    f_x = f_x( 3:end-2, 3:end-2 );
    f_y = f_y( 3:end-2, 3:end-2 );
    f_t = f_t( 3:end-2, 3:end-2 );
    roi = roi( 3:end-2, 3:end-2 );
    x = x( 3:end-2, 3:end-2 );
    y = y( 3:end-2, 3:end-2 );
   
    % calculate M
    ind = find( roi > 0 );
    x = x(ind); y = y(ind);
    f_x = f_x(ind); f_y = f_y(ind); f_t = f_t(ind);
    xf_x = x.*f_x; xf_y = x.*f_y; yf_x = y.*f_x; yf_y = y.*f_y;
    
    % see readme for algorithm details/mathematical basis
    M(1,1) = sum( xf_x .* xf_x );   M(1,2) = sum( xf_x .* yf_x );   M(1,3) = sum( xf_x .* xf_y );
    M(1,4) = sum( xf_x .* yf_y );   M(1,5) = sum( xf_x .* f_x );    M(1,6) = sum( xf_x .* f_y );
    M(2,1) = M(1,2);                M(2,2) = sum( yf_x .* yf_x );   M(2,3) = sum( yf_x .* xf_y );
    M(2,4) = sum( yf_x .* yf_y );   M(2,5) = sum( yf_x .* f_x );    M(2,6) = sum( yf_x .* f_y );
    M(3,1) = M(1,3);                M(3,2) = M(2,3);                M(3,3) = sum( xf_y .* xf_y );
    M(3,4) = sum( xf_y .* yf_y );   M(3,5) = sum( xf_y .* f_x );    M(3,6) = sum( xf_y .* f_y );
    M(4,1) = M(1,4);                M(4,2) = M(2,4);                M(4,3) = M(3,4);
    M(4,4) = sum( yf_y .* yf_y );   M(4,5) = sum( yf_y .* f_x );    M(4,6) = sum( yf_y .* f_y );
    M(5,1) = M(1,5);                M(5,2) = M(2,5);                M(5,3) = M(3,5);
    M(5,4) = M(4,5);                M(5,5) = sum( f_x .* f_x );     M(5,6) = sum( f_x .* f_y );
    M(6,1) = M(1,6);                M(6,2) = M(2,6);                M(6,3) = M(3,6);
    M(6,4) = M(4,6);                M(6,5) = M(5,6);                M(6,6) = sum( f_y .* f_y );

    k = f_t + xf_x + yf_y;
    b(1) = sum( k .* xf_x ); b(2) = sum( k .* yf_x );
    b(3) = sum( k .* xf_y ); b(4) = sum( k .* yf_y );
    b(5) = sum( k .* f_x ); b(6) = sum( k .* f_y );
    
    m = inv(M) * b';
    A = [m(1) m(2) ; m(3) m(4)];
    T = [m(5) ; m(6)];
    
end

% -------------------------------------------------------------------------
%%% Warp frame based on motion parameters
function [warped_frame] = warp(frame, A, T)
    
    % dimensions for reshaping    
    [height, width] = size(frame );
    [x, y] = meshgrid((1:width)-width/2, (1:height)-height/2);
    
    % warp frame
    P = [x(:)' ; y(:)'];
    P = A * P;
    x2 = reshape(P(1,:), height, width) + T(1);
    y2 = reshape(P(2,:), height, width) + T(2);
    warped_frame = interp2(x, y, frame, x2, y2, 'bicubic');
    
    % clean up NaN elements, set to 0
    indices = find(isnan(warped_frame));
    warped_frame(indices) = 0;
    
end

% -------------------------------------------------------------------------
%%% Extract Gaussian pyramid levels
function [frame] = extract_Gauss(frame, Gauss_levels)
    
    kernel = [1 2 1]/4;
    for i = 1:Gauss_levels
        frame = conv2(conv2(frame, kernel, 'same'), kernel', 'same');
        frame = frame(1:2:end, 1:2:end);
    end
    
end
% -------------------------------------------------------------------------
%%% Temporal and spatial derivatives
function [f_x, f_y, f_t] = derivatives(frame_next, frame_current )
    
    % 1-D separable filtes
    p = [0.5 0.5];
    d = [0.5 -0.5];
    
    % Spatial and temporal derivatives
    fpt = p(1)*frame_next + p(2)*frame_current; % pre-filter in time
    fdt = d(1)*frame_next + d(2)*frame_current; % differentiate in time
    f_x = conv2(conv2( fpt, p', 'same'), d, 'same');
    f_y = conv2(conv2( fpt, p, 'same'), d', 'same');
    f_t = conv2(conv2( fdt, p', 'same'), p, 'same');
    
end

% -------------------------------------------------------------------------
%%% Accumulate warps from levels
function [A_new, T_new] = warp_accumulate(A_cummulative, T_cummulative, A, T)
    A_new = A * A_cummulative;
    T_new = A*T_cummulative + T;
end

% -------------------------------------------------------------------------
%%% Loads image sequence
function [BW, color] = load_video(input_folder, file_type, video_length)

    for i = 1:video_length
        read_path = sprintf('%s/%d', input_folder, i);
        frame = imread(read_path, file_type);
        frame = frame(:,:,1:3);
        color(:,:,:,i) = frame;
        BW(:,:,i) = double(rgb2gray(frame));
    end
    
end

% -------------------------------------------------------------------------
%%% Writes images sequence to specified output folder
function write_video(color, output_folder, file_type)

    % get video length in frames
    [~, ~, ~, length] = size(color);
    
    % create output folder and write output image sequence
    mkdir(output_folder);
    for i = 1:length
        write_path = sprintf('%s/%d.%s', output_folder, i, file_type);
        imwrite(color(:,:,:,i), write_path);
    end
    
    % check result
    if(~isdir(output_folder))
        disp('Error: unable to write to output folder.');
        return;     
    end

end
