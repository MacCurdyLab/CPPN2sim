function Finger = genFinger(name)
% GENFINGER generate finger structure from cppn input file
%   Create a Finger structure with all fields filled from a '.mat' file
%   created with the CPPN app. This function also serves as an example
%   for what inputs are needed to call certain functions, and in what
%   order they should be called.

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

%% Plot frames
num_frames = numel(Finger.Shell.Sim.Frames);

for i = 1:num_frames
    frame2plot(Finger.Shell.Sim.Frames{i});
end

end
