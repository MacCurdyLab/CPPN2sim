function figs = frames2plots(frames)
% FRAMES2PLOTS create plot for all frames of a simulation
%   Plot all frames of a simulation. Note that the input to this function
%   should be a cell array, with each cell being a triangulation.

num_frames = numel(frames);
figs = cell(num_frames,1);

for i = 1:num_frames
    figs{i} = figure('Name',sprintf('Frame %i',i));
    set(figs{i},'Position',[2,100,800,700])
    curr_ax = axes('Parent',figs{i},'Color','none','FontName','Monospaced',...
                   'FontWeight','Bold','FontSize',10,'LineWidth',1,'Clipping','off');
    hold(curr_ax,'on');
    curr_patch = patch('Parent',curr_ax,'faces',frames{i}.ConnectivityList,...
                       'vertices',frames{i}.Points,'FaceColor',[.4,.76,.65],...
                       'EdgeColor','none','FaceAlpha',.25);
    view(curr_ax,3);
    material(curr_ax,'dull'); 
    lighting(curr_ax,'gouraud');
    axis(curr_ax,'equal');
end

end
