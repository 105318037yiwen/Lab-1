clear
close
clc

%% Load data
dataTrain = csvread('trainMatlab.csv');
dataValid = csvread('validMatlab.csv');
dataTest = csvread('testMatlab.csv');

trainPrice = dataTrain(:,2);
trainData = abs(dataTrain(:,3:23));

validPrice = dataValid(:,2);
validData = abs(dataValid(:,3:23));

testIdx = dataTest(:,1);
testData = abs(dataTest(:,2:22));

%% house age
trainData(:,22) = trainData(:,1) - trainData(:,15);
validData(:,22) = validData(:,1) - validData(:,15);
testData(:,22) = testData(:,1) - testData(:,15);

%% renovated or not
trainData(:,23) = trainData(:,16) ~= 0;
validData(:,23) = validData(:,16) ~= 0;
testData(:,23) = testData(:,16) ~= 0;

%% combine year, date and day
trainData(:,2) = ( (trainData(:,1)-2014)*12 + trainData(:,2) -1 )*30 + trainData(:,3);
validData(:,2) = ( (validData(:,1)-2014)*12 + validData(:,2) -1 )*30 + validData(:,3);
testData(:,2) = ( (testData(:,1)-2014)*12 + testData(:,2) -1 )*30 + testData(:,3);

trainData(:,3) = [];
validData(:,3) = [];
testData(:,3) = [];

%% 14 yr_renovated as 13 built
for i = 1:size(trainData,1)
    if ( trainData(i,15) == 0 )
        trainData(i,15) = trainData(i,14);
    end
end
for i = 1:size(validData,1)
    if ( validData(i,15) == 0 )
        validData(i,15) = validData(i,14);
    end
end
for i = 1:size(testData,1)
    if ( testData(i,15) == 0 )
        testData(i,15) = testData(i,14);
    end
end

%% remove special case

trainMean = mean(trainData);
trainStd = std(trainData);
trainMax = trainMean + trainStd*4;
trainMin = trainMean - trainStd*3;
for i = 1:22
    if ( i ~= 8 && i ~= 9 && i ~= 14 && i ~= 15 && i~= 22)
        % remove to large
        idxRemove = trainData(:,i) > trainMax(i);
        trainData( idxRemove , :) = [];
        trainPrice(idxRemove) = [];
        
        idxRemove = validData(:,i) > trainMax(i);
        validData( idxRemove , :) = [];
        validPrice(idxRemove) = [];
        
        % remove to small
        idxRemove = trainData(:,i) < trainMin(i);
        trainData( idxRemove , :) = [];
        trainPrice(idxRemove) = [];
        
        idxRemove = validData(:,i) < trainMin(i);
        validData( idxRemove , :) = [];
        validPrice(idxRemove) = [];
        
    end
end

trainMax2 = max(trainData);
trainMin2 = min(trainData);
for i = 1:22
    if ( i ~= 8 && i ~= 9 && i ~= 14 && i ~= 15 && i~= 22)
        % adjust bound
%         idxAdjust = validData(:,i) > trainMax2(i);
%         validData( idxAdjust , i) = trainMax2(i);
%         idxAdjust = validData(:,i) < trainMin2(i);
%         validData( idxAdjust , i) = trainMin2(i);
        
        idxAdjust = testData(:,i) > trainMax2(i);
        testData( idxAdjust , i) = trainMax2(i);
        idxAdjust = testData(:,i) < trainMin2(i);
        testData( idxAdjust , i) = trainMin2(i);
    end
end

%% remove to expensive prive/sqft_living
idxRemove=  trainPrice./trainData(:,6) > 600 ;
trainData(idxRemove,:) = [];
trainPrice(idxRemove,:) = [];


%% Totally room

trainData(:,23) = trainData(:,3)+trainData(:,4);
validData(:,23) = validData(:,3)+validData(:,4);
testData(:,23) = testData(:,3)+testData(:,4);

%% Totally living and lot

trainData(:,24) = trainData(:,5)+trainData(:,19);
validData(:,24) = validData(:,5)+validData(:,19);
testData(:,24) = testData(:,5)+testData(:,19);

trainData(:,25) = trainData(:,5)+trainData(:,20);
validData(:,25) = validData(:,5)+validData(:,20);
testData(:,25) = testData(:,5)+testData(:,20);
%% Output

csvwrite('m_train3.csv',[trainPrice trainData])
csvwrite('m_valid3.csv',[validPrice validData])
csvwrite('m_test3.csv',[testIdx testData])
