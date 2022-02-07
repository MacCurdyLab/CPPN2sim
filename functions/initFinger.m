function Finger = initFinger(cppn_out)
% INITFINGER initialize finger structure
%   Initialize a finger containing values in the CPPN output file cppn_out

[~,name,ext] = fileparts(cppn_out);
if ext ~= ".mat"
    error('CPPN output should be a ".mat" file.');
end

load(cppn_out,'Finger');

Finger = struct('Name',name,'Geom',Finger.Geom);
end
