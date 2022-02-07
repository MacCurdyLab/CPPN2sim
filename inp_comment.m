function inp_comment(fileID,contents,specs)
% INP_COMMENT comment function for input files
%   Function to create a comment in an input file for Abaqus. Aids in
%   programmatic writing of input files.

n = numel(contents);

if ~isempty(fileID)
    for i = 1:n
        if exist('specs','var')
            fprintf(fileID,['** ',contents{i},'\n'],specs{i});
        elseif strcmp(contents{i},'-break')
            fprintf(fileID,'** ----------------------------------------\n');
        else
            fprintf(fileID,['** ',contents{i},'\n']);
        end
    end
else
    for i = 1:n
        if exist('specs','var')
            fprintf(['** ',contents{i},'\n'],specs{i});
        elseif strcmp(contents{i},'-break')
            fprintf('** ----------------------------------------\n');
        else
            fprintf(['** ',contents{i},'\n']);
        end
    end
end


end

