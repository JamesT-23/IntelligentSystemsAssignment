function [trainedSVM] = trainSVM()
    positiveWords = readOpinionLexicon("positive-words.txt");
    % Read in negative words from file, skip comments and convert to string
    negativeWords = readOpinionLexicon("negative-words.txt");
    
    % Loads in the fastText toolbox to be used
    rng('default');
    embeddings = fastTextWordEmbedding;
    
    % Collates all words into an array and creates a table of the positive and
    % negative words that will be used to train the SVM, also removing any
    % words that weren't in the embeddings but were in the dictionary
    words = [positiveWords; negativeWords];
    labels = categorical(nan(numel(words),1));
    labels( 1: numel(positiveWords)) = "Positive";
    labels( numel(positiveWords) + 1 : end ) = "Negative";
    wordsTable = table(words, labels, 'VariableNames', {'Word' , 'Label'});
    wordsToRemove = ~isVocabularyWord(embeddings, wordsTable.Word);
    wordsTable(wordsToRemove,:) = [];
    
    % Partitions the data into a training set and a testing set 
    noOfWords = size(wordsTable,1);
    partition = cvpartition(noOfWords,'HoldOut',0.02);
    trainingData = wordsTable(training(partition),:);
    testingData = wordsTable(test(partition),:);
    
    % Trains the SVM
    trainingWords = trainingData.Word;
    XTrain = word2vec(embeddings, trainingWords);
    YTrain = trainingData.Label;
    trainedSVM = fitcsvm(XTrain,YTrain);
end