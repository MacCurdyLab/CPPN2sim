function [offsurf,sdf] = mesh_offset(surface_tri,offset,MeshParams)
% MESH_OFFSET create offset mesh
%   Create and return offset surface mesh of input surface mesh. Note that
%   if the new surface should be inside the input triangulation, the input
%   value for offset should be negative.

%% Initial Setup

% Set bool for direction of offset based on offset value
if offset > 0
    % Offset should be external to current shell
    direction = 1;
else
    % Offset should be internal to current shell
    direction = 0;
end

% Set values based off of MeshParams
sigma = MeshParams.Sigma;
vol_delta = MeshParams.dx * 1.5*10; %mm

% Save input mesh into structure in terms of faces and vertices
iFV.Faces = surface_tri.ConnectivityList;
iFV.Vertices = surface_tri.Points;

% Set boundary values in x, y, and z for mesh space
if direction
    p0 = min(iFV.Vertices) - offset;
    p1 = max(iFV.Vertices) + offset;
else
    p0 = min(iFV.Vertices) + offset;
    p1 = max(iFV.Vertices) - offset;
end

% Create mesh grid to volumetric specifications
[x,y,z] = meshgrid(p0(1) : vol_delta : p1(1),...
                   p0(2) : vol_delta : p1(2),...
                   p0(3) : vol_delta : p1(3));

% Create [x_n, y_n, z_n] point matrix for above mesh grid
BC = [x(:),y(:),z(:)];

% Calculate signed distance field for the mesh created above
%{
    A signed distance field is a scalar field representing the shortest
    distance from any given point to a specific surface. Negative values in
    a signed distance field indicate that the corresponding point is within
    the surface, while positive values indicate that the point is outside
    of the surface.
%}
sdf = point2trimesh(iFV,'QueryPoints',BC,'Algorithm','linear');

% Reshape signed distance field
sdf = reshape(sdf,size(x));

% UNSURE OF WHAT THIS DOES
sdf = imfilter(sdf,fspecial('gaussian',9,sigma),'replicate');

%% Create offset surface

% Take level set of SDF at 'offset'
offsurf = isosurface(x,y,z,sdf,offset);

%% Remesh the surface

% Set option structure and define point spacing option
% optionStruct.pointSpacing = MeshParams.Edge_Length / 2;
optionStruct.pointSpacing = MeshParams.MembraneThickness;
[faces,vertices] = ggremesh(offsurf.faces,offsurf.vertices,optionStruct);

% Invert normals of new mesh if necessary
%{
    Inverting normals to the offset mesh is necessary if the offset is
    negative (new mesh will be internal to the input shell). Note that if the offset value
    is positive (new mesh will be external to the input shell), you will need to
    do this kind of operation for the other mesh.
%}
if ~direction
    faces = [faces(:,1),...
             faces(:,3),...
             faces(:,2)];
end

%% Format output as a triangulation
offsurf = triangulation(faces,vertices);

end