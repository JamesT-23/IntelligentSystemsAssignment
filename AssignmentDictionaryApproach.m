clc; clear;

% defines variables for calculating true and false positives and negatives
truePos = 0;
trueNeg = 0;
falsePos = 0;
falseNeg = 0;

% Read in positive words from file, skip comments and convert to string
positiveWords = readOpinionLexicon("positive-words.txt");
% Read in negative words from file, skip comments and convert to string
negativeWords = readOpinionLexicon("negative-words.txt");

% Closes all files
fclose all;

% Defines the sentiment dictionary that will be used
SentDictionary = java.util.Hashtable;

% Defines the size of positiveWords and iterates through it putting all of
% the words into the dictionary and assigning them a sentiment score of 1
[ positiveSize, ~ ] = size(positiveWords);
for i = 1:positiveSize
    SentDictionary.put(positiveWords(i,1),1);
end

% Defines the size of negativeWords and iterates through putting the words
% in the dictionary and assigning a sentiment score of -1
[ negativeSize, ~ ] = size(negativeWords);
for i = 1:negativeSize
    SentDictionary.put(negativeWords(i,1),-1);
end

% Opens the data set and retrieves textual data and actual sentiment score
% then cleans the text data so it is ready to be classified
reviewData = readtable("amazon_cells_labelled.txt",'TextType','string');
reviewText = reviewData.review;
actualScore = reviewData.score;
cleanData = preProcess(reviewText);

% This creates a vector that is filled with zeros to store found sentiment
% scores from classifier
sentimentScores = zeros(size(cleanData));

% Iterates through all sentences in clean data and checks if each word is
% in sentiment dictionary, if it is then it retrieves the sentiment score
% and adds that to current sentiment score of the sentence.
for i = 1 : cleanData.length
    sentWords = cleanData(i).Vocabulary;
    for j = 1 : length(sentWords)
        if SentDictionary.containsKey(sentWords(j))
            sentimentScores(i) = sentimentScores(i) + SentDictionary.get(sentWords(j));
        end
    end
% Changes all positive sentiment scores to 1 and all negative sentiment
% scores to -1 allowing for easier evaluation
    if (sentimentScores(i) >= 1)
        sentimentScores(i) = 1;
    elseif (sentimentScores(i) <= -1)
        sentimentScores(i) = -1;
    end
    % Calculates the number of true and false positive and negatives
    if ((sentimentScores(i) == 1) & (actualScore(i) == 1))
        truePos = truePos + 1;
    elseif ((sentimentScores(i) == -1) & (actualScore(i) == 0))
        trueNeg =trueNeg + 1;
    elseif ((sentimentScores(i) == 1) & (actualScore(i) == 0))
        falsePos = falsePos + 1;
    elseif ((sentimentScores(i) == -1) & (actualScore(i) == 1))
        falseNeg = falseNeg +1;
    end
end

% Creates variables to calculate the total coverage of the classifier then
% outputs the number of true and negative positives and negatives
NoOfNeutral = sum(sentimentScores == 0);
NoOfFound = numel(sentimentScores) - NoOfNeutral;
fprintf("Coverage: %2.2f%% | Number Found: %d | Neutral: %d \n", (NoOfFound*100)/numel(sentimentScores), NoOfFound, NoOfNeutral);
fprintf("true pos: %d | true neg: %d | false pos: %d | false neg: %d",truePos,trueNeg,falsePos,falseNeg);