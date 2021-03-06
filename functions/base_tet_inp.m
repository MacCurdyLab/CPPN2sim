function base_tet_inp(tets,fixed,insurf_elem,pressure,filename)
% BASE_TET_INP write a basice input file for a tetrahedral shell mesh
%   Write the basic input file for a tetrahedral mesh Specifically, this
%   file will result in a simulation in which the bottom most nodes are
%   fixed, and ramping pressure is applied to the inside surface of the 
%   mesh. At each pressure value modeled, the finger will be assumed to
%   be at static equilibrium (quasistatic simulation).

% String used to define material
mat_spec_string = sprintf(['*DENSITY\n',...
                           ' 1.21e-06,\n',...
                           '*HYPERELASTIC,  n=3,  OGDEN\n',...
                           ' 0.108866,  3.20735,   2.1565, -1.89042,  2.94629,  1.33796,      0.1,      0.1\n',...
                           '      0.1']);

static_args_string = '1.,  1.,  1e-05,  1.';

%% Define node and element lists, calculate size of each
nodes = tets.Points;
num_nodes = size(nodes,1);
order_node_coord = floor(log10(max(max(tets.Points))));

elements = tets.ConnectivityList;
num_elements = size(elements,1);
order_num_elem = floor(log10(num_elements));

%% Begin actually writing the input file
fileID = fopen(filename,'W');

%% Heading 
fprintf(fileID,'*HEADING\n');
fprintf(fileID,['JOB NAME: %s\n',...
                'MODEL NAME: %s\n',...
                '<< Generated by MatLab via base_tet_inp >>\n'],...
                'tet_job','tet_model');

% ---------- Model Data Section ----------
inp_comment(fileID,{'-break','MODEL DATA','-break',''});

% Data file printing options
fprintf(fileID,['*PREPRINT,',...
                '  ECHO = no,',...
                '  MODEL = no,',...
                '  HISTORY = no,',...
                '  CONTACT = no\n']);

% ~~~~~~~ Parts ~~~~~~~
fprintf(fileID,'*PART,  NAME = tet_part\n');

% ===== Nodal coordinates (points) =====
fprintf(fileID,'*NODE,  NSET = all_node_set\n');
%{
  *NODE = defines a set of nodes
      NSET = name for future reference of this set of nodes
%}

% Format specification for list of nodes
%       Node#, [spatial coords of this node]
format = sprintf('%% %ii,%% %if,%% %if,%% %if\n',order_num_elem+2,order_node_coord+[10,10,10]);
% format = '%i,\t%f,\t%f,\t%f,\t%f\n';

% Print node number and coordinates
for i = 1:num_nodes
    contents = [i,nodes(i,:)];
    fprintf(fileID,format,contents);
end

% ===== Element connectivity (connectivity list) =====
fprintf(fileID,'*ELEMENT,  TYPE = c3d4,  ELSET = all_elem_set\n');
%{
  *ELEMENT = defines a set of elements
      TYPE  = type of abaqus element (alphanumeric code)
      ELSET = name for future reference of this set of elements 
%}

% Format specification for list of elements
%       Elem#, [Node#s connected by this element]
format = sprintf('%% %ii,%% %ii,%% %ii,%% %ii,%% %ii\n',[2,4,4,4,4]+order_num_elem);
% format = '%i,\t%i,\t%i,\t%i,\t%i\n';

% Print element number and connectivity
for ii = 1:num_elements
    contents = [ii elements(ii,:)];
    fprintf(fileID,format,contents);
end

% ===== Element section properties =====
inp_comment(fileID,{'Section 1\n'});
fprintf(fileID,'*SOLID SECTION,  ELSET = all_elem_set,  MATERIAL = only_mat\n');
fprintf(fileID,',\n');

fprintf(fileID,'*END PART\n');

% ~~~~~~~ Assembly definition ~~~~~~~
inp_comment(fileID,{'-break','ASSEMBLY',''});
fprintf(fileID,'*ASSEMBLY,  NAME = tet_assembly\n');

% ~~~~~~~ Instance definition ~~~~~~~
fprintf(fileID,'*INSTANCE,  NAME = tet_instance,  PART = tet_part\n');
fprintf(fileID,'*END INSTANCE\n');
inp_comment(fileID,{''});

% ~~~~~~~ Define node sets ~~~~~~~
fprintf(fileID,'*NSET,  NSET = fixed,  INSTANCE = tet_instance\n');
curr_set_size = numel(fixed);

for jj = 1:curr_set_size
    if jj ~= curr_set_size
        fprintf(fileID,'%i,\t',fixed(jj));
    else
        fprintf(fileID,'%i\n',fixed(jj));
    end
    if ( rem(jj,10) == 0 ) && ( jj ~= curr_set_size )
        fprintf(fileID,'\n');
    end
end

% ~~~~~~~ Define element sets for pressure placement ~~~~~~~
pressure_faces = cell(4,1);
for ii = 1:4
    if ~isempty(insurf_elem{ii})
        inp_comment(fileID,{'-break'});
        pressure_faces{ii} = sprintf('_tet_insurf_S%i',ii);
        fprintf(fileID,'*ELSET,  ELSET = %s,  INTERNAL,  INSTANCE = %s\n',pressure_faces{ii},'tet_instance');
        
        curr_set = insurf_elem{ii};
        curr_set_size = numel(curr_set);
    
        for jj = 1:curr_set_size
            if jj ~= curr_set_size
                fprintf(fileID,'%i,\t',curr_set(jj));
            else
                fprintf(fileID,'%i\n',curr_set(jj));
            end
            if ( rem(jj,10) == 0 ) && ( jj ~= curr_set_size )
                fprintf(fileID,'\n');
            end
        end
    end
    
end

% Stitch the four pressure placement surfaces from above together
fprintf(fileID,'*SURFACE,  TYPE = ELEMENT,  NAME = tet_insurf\n');
for ii = 1:4
    if ~isempty(pressure_faces{ii})
        fprintf(fileID,'%s, S%i\n',pressure_faces{ii},ii);
    end
end
fprintf(fileID,'*END ASSEMBLY\n');

% ~~~~~~~ Materials ~~~~~~~
inp_comment(fileID,{'-break','MATERIALS',''});

fprintf(fileID,'*MATERIAL,  NAME = only_mat\n');
fprintf(fileID,'*%s\n',mat_spec_string);

% ---------- Simulation Data Section ----------
inp_comment(fileID,{'-break','SIMULATION DATA','-break',''});

% ~~~~~~~ Step ~~~~~~~
inp_comment(fileID,{'STEP: %s',''},{'tet_step',''});

fprintf(fileID,'*STEP,  NAME = tet_step,  NLGEOM = yes\n');
fprintf(fileID,'*STATIC\n');
fprintf(fileID,'%s\n',static_args_string);

% ~~~~~~~ Boundary Conditions ~~~~~~~
inp_comment(fileID,...
    {'','BOUNDARY CONDITIONS','',...
    'NAME: tet_bound_con','TYPE: symmetry/antisymmetry/encastre'})

fprintf(fileID,'*BOUNDARY\n');
fprintf(fileID,'fixed,  ENCASTRE\n');

inp_comment(fileID,{'','LOADS','','NAME: tet_load','TYPE: pressure'})
fprintf(fileID,'*Dsload\n');
fprintf(fileID,'tet_insurf, P, %s\n',pressure);

% ~~~~~~~ Output Requests ~~~~~~~
inp_comment(fileID,{'','OUTPUT REQUESTS',''})
Frequency = 0;
fprintf(fileID,'*RESTART,  WRITE,  FREQUENCY = %g\n',Frequency);

inp_comment(fileID,{'','FIELD OUTPUT: f_output',''})
fprintf(fileID,['*FILE FORMAT,  ASCII\n',...
                '*NODE FILE\n',...
                'U\n']);
fprintf(fileID,'*OUTPUT,  FIELD,  VARIABLE = preselect,  TIME INTERVAL = 0.5\n');

inp_comment(fileID,{'','HISTORY OUTPUT: h_output',''})
fprintf(fileID,'*OUTPUT,  HISTORY,  VARIABLE = preselect\n');
fprintf(fileID,'*END STEP\n');

%% Close the input file
fclose(fileID);

end
