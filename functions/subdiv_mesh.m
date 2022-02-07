function [Fnew,Vnew] = subdiv_mesh(F,V)
% SUBDIV_MESH generate a mesh with smaller elements
%   Create a mesh whose edge lengths are approximately one half of the
%   input edge lengths. This results in a triangular mesh whose elements
%   are approximately one fourth the size of the elements in the input
%   mesh.

E = edges(triangulation(F,V));

num_edges = size(E,1);

sample = unique(randi(num_edges,round(.33*num_edges),1));
num_sample = numel(sample);

for i = 1:num_sample
    sample(i) = norm(V(E(sample(i),1),:)-V(E(sample(i),2),:));
end

ave_length = mean(sample);


% Concatenate the coords of every edge's startpt and endpt along the 3rd
% dimension, then take the mean along the third dimesntion to find midpts
newpts = mean(cat(3,V(E(:,1),:),V(E(:,2),:)),3);

% Now augment edges list with the index of vertex created by the split
E = [E (size(V,1)+1:1:size(V,1)+size(E,1))'];

% Add these new points to the list of vertices
Vnew = [V; newpts];

Fnew = [];
for i = 1:size(F,1)
    
     % Find the three original edges of this triangle
     [~,~,i1] = intersect(sort([F(i,1) F(i,2)],2),sort(E(:,[1 2]),2),'rows');
     [~,~,i2] = intersect(sort([F(i,2) F(i,3)],2),sort(E(:,[1 2]),2),'rows');
     [~,~,i3] = intersect(sort([F(i,3) F(i,1)],2),sort(E(:,[1 2]),2),'rows');
          
     % Now add the four new faces
     Fnew = [Fnew; F(i,1) E(i1,3) E(i3,3)]; 
     Fnew = [Fnew; E(i1,3) F(i,2) E(i2,3)];  
     Fnew = [Fnew; E(i2,3) F(i,3) E(i3,3)]; 
     Fnew = [Fnew; E(i1,3) E(i2,3) E(i3,3)];
     
end

%% Remesh the surface

% Set option structure and define point spacing option to be half of
% average edge length of the input
optionStruct.pointSpacing = ave_length / 2;
[Fnew,Vnew] = ggremesh(Fnew,Vnew,optionStruct);

end
