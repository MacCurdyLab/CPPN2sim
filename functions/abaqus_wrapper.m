function Sim = abaqus_wrapper(Sim)
% ABAQUS_WRAPPER wrapper function for sending input files to Abaqus
%   Send a simulation to Abaqus defined by the input Sim structure.

%% Suppress certain errors (this file only)

% The variable '~' appears to change size on every loop iteration.
% Consider preallocating for speed.
%#ok<*AGROW>

% The value assigned to '~' here appears to be unused.
% Consider replacing it with ~.
%#ok<*ASGLU>

%% Setup
% Save the path of the current directory
init_dir = pwd;

% Create folder named FINGERNAME followed by SUFFIX, change directory to it
mkdir(Sim.Name);
movefile(Sim.Inp,Sim.Name);
cd(Sim.Name);

% Save full path of current location
Sim.Path = pwd;

% Define string to send to command line
Sim.Command = strcat('abaqus job=',Sim.Name,' input=',Sim.Inp,' interactive');

%% Make system call (and time the simulation)
%{
    This line passes control over to Abaqus, which will then run the
    simulation as requested in the input file. While Abaqus is in control,
    all commands in Matlab, such as Ctrl+C or the pause button, will be
    held until Abaqus passes control back to Matlab.

    If there was an error in Abaqus, Matlab does not know at this point,
    meaning that any unhandled Abaqus errors will most likely result in
    Matlab errors of some variety. This will usually halt any programs
    running in Matlab, so it is important to attempt to handle all
    potential errors.
%}
Sim.Start_Time = fix(clock);
fprintf(' > > > Command sent at %i:%i:%i\n\n',Sim.Start_Time(3:5));
tic;
system(Sim.Command);
Sim.Duration = toc;
fprintf('\n > > > Simulation time was %g\n\n',Sim.Duration);

%% Run the documentation function for the abaqus2matlab package (a2m)
run('Documentation.m');

%{
    Note: You will need to have the a2m package on your path for this to
    work. Furthermore, the above command will change your directory to the
    directory of the Documentation.m file, so we will now change back to
    our simulation directory.
%}
cd(Sim.Path);

%% Save the Abaqus output as a string using a2m
%{
    Note: The variable 'Rec' will contain the entirety of the '.fil' file,
    you won't be able to preview the whole variable in Matlab because it
    will be too large.
%}
Rec = Fil2str(strcat(Sim.Name,'.fil'));

%% Interpret the Abaqus output
%{
    Note: The '.fil' file contains the output of the Abaqus simulation, but
    is not human readable. The below process will create a version that can
    be easily interpreted by Matlab.
%}
if ~isempty(Rec)
    displacements = Rec101f(Rec);
    increments = Rec2000(Rec);
    
    if displacements == false
        Sim.Pass = false;
    else
        Sim.Pass = true;
    end
else
    Sim.Pass = false;
end

if Sim.Pass
    % Filter node displacements to only be what we care about
    displacements = displacements(:,1:4);
    
    % Extract indices of the results
    ind = find(displacements(:,1) == 1);
    
    % Reorganize node displacements into a 3D array
    node_disps = [];
    for i = 1:length(ind)-1
        node_disps(:,:,i) = displacements(ind(i):ind(i+1)-1,:);
    end
    
    % Set fields of output structure
    Sim.Node_Disps = node_disps;
    Sim.Pseudotime = increments(:,1);
end

% Return to the initial directory
cd(init_dir);

% Remove the simulation files if desired
if Sim.RemoveDir
    [status,message] = cmd_rmdir(Sim.Path);
end

end
