function curr_fig = elem_type_diff(A_frames,B_frames)
% ELEM_TYPE_DIFF plot localized difference between input frames
%   Plot both input frames on the same figure, and color the second to
%   visualize localized difference between them.

%% Suppress certain errors (this file only)

% The value assigned to '~' might be unused.
%#ok<*NASGU>

%% Tolerance value
% Each point on mesh A must be within tol distance of any point on mesh B

% Tolerance variable
tol = .5;

%% Only use the free boundary of the input triangulations

if size(A_frames{1},2) == 4
    warnStruct = warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    A_temp = triangulation(freeBoundary(A_frames{1}),A_frames{1}.Points);
    warning(warnStruct);
    [~,A_outer] = segment_connected_components_no_tic(A_temp.ConnectivityList);
    if max(A_temp.Points(A_outer{1},3)) > max(A_temp.Points(A_outer{2},3))
        A_outer = A_outer{1};
    else
        A_outer = A_outer{2};
    end
else
    A_outer = A_frames{1}.ConnectivityList;
end

if size(B_frames{1},2) == 4
    warnStruct = warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    B_temp = triangulation(freeBoundary(B_frames{1}),B_frames{1}.Points);
    warning(warnStruct);
    [~,B_outer] = segment_connected_components_no_tic(B_temp.ConnectivityList);
    if max(B_temp.Points(B_outer{1},3)) > max(B_temp.Points(B_outer{2},3))
        B_outer = B_outer{1};
    else
        B_outer = B_outer{2};
    end
else
    B_outer = B_frames{1}.ConnectivityList;
end

%% Determine corresponding points on input meshes

% Save the number of nodes in mesh A
A_node_num = size(A_frames{1}.Points,1);

% Initialize empty cell array
adjacency = cell(1,A_node_num);

% For each node in the mesh A, determine all points from mesh B in
% (x +/- tol) && (y +/- tol) && (z +/- tol) where (x,y,z) is the
% coordinate of a point in mesh A
for i = 1:A_node_num
   temp_point = A_frames{1}.Points(i,:);
   [is_close,adjacency{i}] = ismembertol(temp_point,B_frames{1}.Points(:,:),...
                                         tol,'ByRows',true,'OutputAllIndices',true);

   if ~is_close
       error(['Meshes are not similar enough; ',...
              'at least one node in mesh A has no nearby nodes in mesh B.']);
   end
end

%%

% Save the number of frames
num_frames = min(numel(A_frames),numel(B_frames));

% Initialize some matrices
B_ave_node = zeros(A_node_num,3,num_frames);
dist_diff = zeros(A_node_num,1,num_frames);

% For each frame in the 'frames' variable, calculate the point on mesh B
% that corresponds to each node on mesh A. We will use this point to 
% calculate localized distance between the meshes
for frame_ind = 1:num_frames
    for i = 1:A_node_num
        B_node_index = cell2mat(adjacency{i});
        B_nodes = B_frames{frame_ind}.Points(B_node_index,:);
        B_ave_node(i,:,frame_ind) = mean(B_nodes,1);
        
        dist_diff(i,:,frame_ind) = ...
            norm(A_frames{frame_ind}.Points(i,:) - B_ave_node(i,:,frame_ind));
    end
end

%% Determine maximum and minimum differences across all input frames
small_dist = min(min(dist_diff));
large_dist = max(max(dist_diff));

%% Plot each frame
for i = 1:num_frames
    curr_fig = figure('Name',sprintf('Localized Difference - Frame %i',i));
    set(curr_fig,'Position',[2,100,800,700])
    curr_ax = axes('Parent',curr_fig,'Color','none','FontName','Monospaced',...
                  'FontWeight','Bold','FontSize',10,'LineWidth',1,'Clipping','off');
    hold(curr_ax,'on');
    
    A_patch = patch('Parent',curr_ax,'faces',A_outer,...
                    'vertices',A_frames{i}.Points,'FaceColor','interp',...
                    'FaceVertexCData',dist_diff(:,:,i),'EdgeColor','none','FaceAlpha',.9);

    B_patch = patch('Parent',curr_ax,'faces',B_outer,...
                    'vertices',B_frames{i}.Points,'FaceColor',[.6,.6,.6],...
                    'EdgeColor','none','FaceAlpha',.25);
    
    set(curr_ax,'DataAspectRatio',[1 1 1]);
    caxis(curr_ax,[small_dist,large_dist])
    colormap(curr_ax,brewermap(20,'*RdYlBu'))
    colorbar(curr_ax,'Location','south outside');
    view(curr_ax,[-300 720 362]);
    camlight headlight;
    material dull;
    lighting gouraud;
    hold off;
end

end