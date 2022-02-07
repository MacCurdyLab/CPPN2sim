function [f,v] = field2mesh(Q,Params)
% FIELD2MESH create triangular mesh from input signed distance field
%   Create a mesh structure from input signed distance field and parameters
%   structure. Note that the parameters structure will contain the value at
%   which to take the isosurface.

% Set up meshgrid of points
[X,Y,Z] = meshgrid(Params.Extents(1,1):Params.dx:Params.Extents(1,2),...
    Params.Extents(2,1):Params.dx:Params.Extents(2,2),...
    Params.Extents(3,1):Params.dx:Params.Extents(3,2));

% Extract isosurface through field
p = isosurface(X,Y,Z,Q,Params.IsoVal);

f = p.faces; v = p.vertices;

valid_mesh = false;
fail = false;
if ~isempty(f) && ~isempty(v) && Params.Remesh

    % Check the number of connected components
    if Params.rmIslands
        [NR,RS] = segment_connected_components_no_tic(f,'explicit');
    else
        NR = 1;
    end
    % If there are multiple regions, quit
    if NR==1
        if Params.CloseHoles
            % Close any holes in the mesh
            try
                [f,v] = triSurfCloseHoles(f,v);
            catch
                fprintf('\nClose Holes Failed\n')
                fail = true;
            end
        end

        if Params.Remesh && ~fail
            % Remesh the isosurface
            opt.pointSpacing=Params.ElementSize/10;
            opt.disp_on=0;
            [f,v]=ggremesh(f,v,opt);
            % Check the number of connected components
            [NR, ~] = segment_connected_components_no_tic(f,'explicit');
            if NR>1
                fail = true;
            end
        end
        % Convert to units of mm from units of cm
        v = v*10;
        
        if size(f,1)<Params.MaxFaces && ~fail
            valid_mesh = true;
        end
    end
end
    

if ~valid_mesh && ~Params.Keep
    f = [];
    v = [];
end

end
