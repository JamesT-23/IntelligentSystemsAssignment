function [Words] = readOpinionLexicon(filename)
    file = fopen(filename);
    commentSkipped = textscan(file,'%s', 'CommentStyle',';');
    Words = string(commentSkipped{1});
end
% This function reads files into matlab and converts the array to string