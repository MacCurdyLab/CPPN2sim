function frames = simout2frames(vis_times,Sim,ref_mesh)
% SIMOUT2FRAMES
%   Create path of an actuator over a simulation by interpolating between
%   data points

% Determine and save the limiting number of instances
min_inc = min(size(Sim.Pseudotime,1),size(Sim.Node_Disps,3));

% Extract and organize relevant time and displacement data
t = cell2mat(Sim.Pseudotime(1:(min_inc-1)));
U = transpose(reshape(Sim.Node_Disps(:,2:4,1:(min_inc-1)),[],min_inc-1));

% Form gridded interpolation operator
int_op = griddedInterpolant(t,U);

% Save times to visualize that occurred in the simulation
ti = vis_times(vis_times < t(end));

% Interpolate to find displacement values at those times
Ui = int_op(ti);

% Reshape back into 3D array
interp_disps = reshape(Ui',size(Sim.Node_Disps,1),3,[]);

% Save number of frames that will actually be created
num_frames = numel(ti);

% Create cell containing triangulations of the mesh at specified times
frames = cell(num_frames+1,1);
frames{1} = ref_mesh;
for i = 1:num_frames
    frames{i+1} = triangulation(ref_mesh.ConnectivityList,ref_mesh.Points+interp_disps(:,1:3,i));
end

end