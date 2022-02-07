function tets = meshes2tet(Si,So,plot_flag)
% MESHES2TET create tet mesh from inner and outer surfaces
%   Use TetGen to create a tetrahedral mesh whose bounds are the inner and
%   outer input surfaces.

%% Verify that the insurf is inside the outsurf

% Get maximum z values for both surfaces
zMax_i = max(Si.Points(:,3));
zMax_o = max(So.Points(:,3));

% Compare
if zMax_i >= zMax_o
    error('Meshes are inside out.\nSwap the first and second input meshes, and don''t forget to invert their unit normals if necessary.');
end

%% Combine vertices and faces of inputs
Vpts   = [ Si.Points;...
           So.Points];
       
Vfaces = [ Si.ConnectivityList;...
           So.ConnectivityList + size(Si.Points,1)];


%% Get reference points for meshing

% Locate a point that is between the two surfaces
%{
    For the inner surface vertices, compute distance from that node to every
    node on outer surface, take the closest one, take the average of the two
%}
[~,ind] = min(sum((So.Points - Si.Points(1,:)).^2,2));
interior_point = mean([Si.Points(1,:); So.Points(ind,:);]);

% Locate a point that is in the void volume
%{
    The void volume is the name given to the empty space inside of the
    solid mesh that we are making. In other words, if the actuator were to
    be fabricated, this space would be where the working fluid would go.
%}
voidpoint = getInnerPoint(Si.ConnectivityList,Si.Points);

%% Create tet mesh using tetgen
%{
    Note that the input to tetgen is rather specific. Documentation for the
    runTetGen function, as well as the command line string options (aka. 
    'switches')for TetGen can be found at the links below.
    
    runTetGen
    https://www.gibboncode.org/html/HELP_runTetGen.html
    
    CMD switches
    https://wias-berlin.de/software/tetgen/switches.html
    ( cmd_switches.txt file of the CPPN_Pipeline package )
%}

% Create tetgen input structure
inputStruct.Faces = Vfaces;
inputStruct.Nodes = Vpts;
inputStruct.regionPoints = interior_point;
inputStruct.holePoints = voidpoint;

stringOpt='-pq1.2';
inputStruct.stringOpt=stringOpt;

% Mesh model with tetrahedral elements using tetGen
[meshOutput] = runTetGen(inputStruct);

if exist('plot_flag','var') & plot_flag
    meshView(meshOutput);
end

% Save the information needed to reconstruct output as Tet triangulation
node = meshOutput.nodes;
elem = meshOutput.elements;

%% Create tet triangulation from TetGen output
tets = triangulation(elem(:,1:4),node(:,1:3));

end
