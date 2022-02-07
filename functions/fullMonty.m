function Finger = fullMonty(name)
% FULLMONTY take a finger through the works
%   Create a Finger structure with all possible fields filled from a '.mat'
%    file created with the CPPN app. This function also serves as an
%    example for what inputs are needed to call certain functions, and in
%    what order they should be called.

%% Initialize the Finger structure
Finger = initFinger(name);

%% Set parameters of the Finger structure
Finger.Params = setParams();

%% Create a string representation of the function represented by the CPPN
Finger.Func = net2func(Finger.Geom);

%% Create a scalar field using the function represented by the CPPN
Finger.Field = net2field(Finger.Geom,Finger.Params);

%% Create a shell mesh (triangulation) from an isosurface in scalar field
[F,V] = field2mesh(Finger.Field,Finger.Params);
Finger.Shell.Mesh = triangulation(F,V);

%% Define which nodes that will be fixed for simulation
Finger.Shell.Fixed = define_fixed(Finger.Shell.Mesh,Finger.Params.MembraneThickness);

%% Write input file for Abaqus solver (shell representation)

% Initialize Sim structure
Finger.Shell.Sim = initSim(Finger,'_shellsim');

% Call function to write the input file
%{
    Input files to Abaqus are rather finicky, and understanding one is
    difficult. The write_tet_inp function is commented, as is the input
    file that is created with it, however this input file will only
    simulate the quasi-static deflection of an actuator represented as a
    shell mesh.

    General notes:
        - A line beginning with two asterisks '**' is a comment
        - A line beginning with a single asterisk '*' is the start of a
          command
        - The input file is not case sensitive
        - All instances of the space character ' ' will be ignored
%}
base_shell_inp(Finger.Shell.Mesh,...
                Finger.Shell.Fixed,...
                Finger.Params.P,...
                Finger.Params.MembraneThickness,...
                Finger.Shell.Sim.Inp);

Finger.Shell.Sim.RemoveDir = false;

%% Call Abaqus wrapper function
% This should be the only function in which Matlab and Abaqus interact
Finger.Shell.Sim = abaqus_wrapper(Finger.Shell.Sim);

%%  Create triangulations of the mesh at desired times
Finger.Shell.Sim.Frames = simout2frames(.1:.1:1,Finger.Shell.Sim,Finger.Shell.Mesh);

%% Plot shell frames
num_shell_frames = numel(Finger.Shell.Sim.Frames);

for i = 1:num_shell_frames
    frame2plot(Finger.Shell.Sim.Frames{i});
end

%% Create a mesh with elements approximately a quarter their previous size
%   NOTE: This is necessary in order to create generally simulateable
%   tetrahedral meshes
[Fs,Vs] = subdiv_mesh(Finger.Shell.Mesh.ConnectivityList,Finger.Shell.Mesh.Points);
Finger.Subdiv_Shell = triangulation(Fs,Vs);

%% Create an inner offset mesh which is the inner surface of the Finger
Finger.Inner_Offset = mesh_offset(Finger.Shell.Mesh,-Finger.Params.MembraneThickness,Finger.Params);

%% Create tetrahedral mesh of a finger from two input shell meshes
Finger.Tets.TMesh = meshes2tet(Finger.Inner_Offset,Finger.Subdiv_Shell);

%% Determine inner surface of tetrahedral mesh
Finger.Tets.Insurf = get_elem_insurfs(Finger.Tets.TMesh);

%% Define which nodes that will be fixed for simulation
Finger.Tets.Fixed = define_fixed(Finger.Tets.TMesh,Finger.Params.MembraneThickness);

%% Write input file for Abaqus solver (tet representation)

% Initialize Sim structure
Finger.Tets.Sim = initSim(Finger,'_tetsim');

% Call function to write the input file
%{
    Input files to Abaqus are rather finicky, and understanding one is
    difficult. The write_tet_inp function is commented, as is the input
    file that is created with it, however this input file will only
    simulate the quasi-static deflection of an actuator represented as a
    tetrahedral mesh.

    General notes:
        - A line beginning with two asterisks '**' is a comment
        - A line beginning with a single asterisk '*' is the start of a
          command
        - The input file is not case sensitive
        - All instances of the space character ' ' will be ignored
%}
base_tet_inp(Finger.Tets.TMesh,...
              Finger.Tets.Fixed,...
              Finger.Tets.Insurf,...
              Finger.Params.P,...
              Finger.Tets.Sim.Inp);

Finger.Tets.Sim.RemoveDir = false;

%% Call Abaqus wrapper function
% This should be the only function in which Matlab and Abaqus interact
Finger.Tets.Sim = abaqus_wrapper(Finger.Tets.Sim);

%%  Create triangulations of the mesh at desired times
Finger.Tets.Sim.Frames = simout2frames(.1:.1:1,Finger.Tets.Sim,Finger.Tets.TMesh);

%% Plot tet frames
num_tet_frames = numel(Finger.Tets.Sim.Frames);

for i = 1:num_tet_frames
    frame2plot(Finger.Tets.Sim.Frames{i});
end

%% Local difference plots
elem_type_diff(Finger.Shell.Sim.Frames,Finger.Tets.Sim.Frames);


end
