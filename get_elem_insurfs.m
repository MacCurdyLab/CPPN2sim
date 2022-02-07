function Insurf = get_elem_insurfs(tets) 
% GET_ELEM_INSURFS find the surfaces on the inside of a tetrahedral mesh
%   Determine which elements, and which faces of those elements, are part
%   of the interior surface of a tetrahedral mesh. This is necessary for
%   the writing of a tetrahedral simulation input file.

%% Supress certain errors (in this file only)

% The input argument '~' might be unused. If this is OK, consider replacing
% it by ~.
%#ok<*INUSD>

% The value assigned to '~' might be unused.
%#ok<*NASGU>

% The variable '~' appears to change size on every loop iteration.
% Consider preallocating for speed.
%#ok<*AGROW>

%% Separate inner and outer surfaces

% Create a triangulation of the inner and outer surfaces of the tet mesh
%{
    Although we have access to this already in the form of Si and So in the
    meshes2tets function, it is not too difficult to obtain. This could be
    changed such that Si and So are passed as inputs, which would decrease
    this function's runtime.
%}
[faces,points] = freeBoundary(tets);
surfs_tri = triangulation(faces,points);

[~,components] = segment_connected_components_no_tic(surfs_tri.ConnectivityList);

[~,ind] = min(points(:,3));

%%
%{
    For each triangle in t_inner [[ each row in components{1} ]] determine
    the tet element from tets that contains 
%}
%% Find and save the coordinates of each vertex on inner surface faces
if ismember(ind,components{1})
    inner_faces = components{2};
else
    inner_faces = components{1};
end
num_inner_elem = size(inner_faces,1);
curr_face_loc = zeros(3);
faces_loc_cell = cell(num_inner_elem,1);

for ii = 1:num_inner_elem
    
    for jj = 1:3
        curr_point_ind = inner_faces(ii,jj);
        curr_face_loc(jj,:) = points(curr_point_ind,:);
    end
    
    faces_loc_cell{ii} = curr_face_loc;
end

%% Generate inner connectivity list
% Find coordinate node number by matching the inner surface vertice values

inner_connectivity = zeros(num_inner_elem,3);

for ii = 1:num_inner_elem
    [~,point_inds] = ismember(faces_loc_cell{ii},tets.Points,'rows');
    inner_connectivity(ii,:) = point_inds';
end

%% Determine which elements contain inner surfaces
% For each inner surface, there will be a unique element that containing it

inner_elems = zeros(num_inner_elem,1);
S1 = [];
S2 = [];
S3 = [];
S4 = [];

for ii = 1:num_inner_elem
    inner_elems(ii) = find(...
                           and(...
                               and(...
                                   any(tets.ConnectivityList == inner_connectivity(ii,1),2),...
                                   any(tets.ConnectivityList == inner_connectivity(ii,2),2)...
                                  ),...
                               any(tets.ConnectivityList == inner_connectivity(ii,3),2)...
                              )...
                          );
%{
    For more information on face numbering of elements go to 
    https://abaqus-docs.mit.edu/2017/English/SIMACAEELMRefMap/simaelm-r-3delem.htm
    
    4-Node Tetrahedral Element Convention
            FACE        NODE ORDER
             S1           1-2-3
             S2           1-4-2
             S3           2-4-3
             S4           3-4-1
%}

    N1 = tets.ConnectivityList(inner_elems(ii),1);
    N2 = tets.ConnectivityList(inner_elems(ii),2);
    N3 = tets.ConnectivityList(inner_elems(ii),3);
    N4 = tets.ConnectivityList(inner_elems(ii),4);
    
    if ~any(inner_connectivity(ii,:) == N4)
        S1 = [S1 inner_elems(ii)];
        
    elseif ~any(inner_connectivity(ii,:) == N3)
        S2 = [S2 inner_elems(ii)];
            
    elseif ~any(inner_connectivity(ii,:) == N1)
        S3 = [S3 inner_elems(ii)];
    
    elseif ~any(inner_connectivity(ii,:) == N2)
        S4 = [S4 inner_elems(ii)];          
    else
        error('ERROR DURING INNER FACE RECOGNITION');
    end

end

Insurf = {sort(S1),sort(S2),sort(S3),sort(S4)};



end