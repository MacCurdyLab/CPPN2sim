function fixed = define_fixed(mesh,thickness)
% DEFINE_FIXED choose which nodes should be fixed in an input mesh
%   Return an array containing the node numbers that should be fixed,
%   assuming that only the bottom most layer of nodes should be fixed.

% Determine minimum height of a node in the mesh
min_height = min(mesh.Points(:,3));

% Calculate maximum height to fix using thickness and min height
max_fix = min_height + 1.5*thickness;

% Save the numbers of the fixed nodes
fixed = find(mesh.Points(:,3) < max_fix);

end