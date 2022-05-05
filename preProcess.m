function [document] = preProcess(Data)
    cleanedData = lower(Data);
    document = tokenizedDocument(cleanedData);
    document = erasePunctuation(document);
    document = removeStopWords(document);
end

% This function is passed data and will clean the data and tokenise it so
% that it can be used in the classifier