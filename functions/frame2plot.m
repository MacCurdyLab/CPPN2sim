function fig = frame2plot(frame)
% FRAME2PLOT create plot for a single frame of a simulation
%   Plot a single frame of a simulation. Note that this is effectively
%   plotting the free boundary of an input mesh.

%% Suppress certain errors (this file only)

% The value assigned to '~' might be unused.
%#ok<*NASGU>

%% Only use the outermost boundary
if size(frame,2) == 4
    warnStruct = warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    temp = triangulation(freeBoundary(frame),frame.Points);
    warning(warnStruct);
    [~,outer] = segment_connected_components_no_tic(temp.ConnectivityList);
    if max(temp.Points(outer{1},3)) > max(temp.Points(outer{2},3))
        outer = outer{1};
    else
        outer = outer{2};
    end
else
    outer = frame.ConnectivityList;
end

%% Plot
fig = figure('Name','Frame');
set(fig,'Position',[2,100,800,700])
fig_ax = axes('Parent',fig,'Color','none','FontName','Monospaced',...
              'FontWeight','Bold','FontSize',10,'LineWidth',1,'Clipping','off');
hold(fig_ax,'on');
view(fig_ax,3);

fig_patch = patch('Parent',fig_ax,'faces',outer,...
                  'vertices',frame.Points,'FaceColor',[.4,.76,.65],...
                  'EdgeColor','none','FaceAlpha',.25);

view(fig_ax,3);
material(fig_ax,'dull');
camlight(fig_ax,'headlight');
lighting(fig_ax,'gouraud');
axis(fig_ax,'equal');

end
