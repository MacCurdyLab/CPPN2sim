function Sim = initSim(Finger,suffix)
% INITSIM initialize a simulation structure

if ~exist('suffix','var')
    suffix = '_sim';
end

name = sprintf('%s%s',Finger.Name,suffix);
input_file = strcat(name,'.inp');

Sim = struct('Name',name,'Inp',input_file,'RemoveDir',Finger.Params.RemoveDir);

end