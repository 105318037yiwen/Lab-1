import pandas as pd
import numpy as np

# Read dataset into X and Y
train = pd.read_csv('m_train3.csv', header=None)
trainData = train.values
train_X = trainData[:, 1:26]
train_Y = trainData[:, 0]

# Read valid
valid = pd.read_csv('m_valid3.csv', header=None)
validData = valid.values
valid_X = validData[:, 1:26]
valid_Y = validData[:, 0]

# Read test
test = pd.read_csv('m_test3.csv', header=None)
testData = test.values
test_X = testData[:, 1:26]
test_Idx = testData[:, 0]


# Normalized

minValue = 0;
maxValue = [0.3,1,2,2,2,1,1,0.3,0.3,1,2,2,1,1,1,2,2,2,2,1,2,1,2,2,1];

for i in range(0,25):
    maxBound = max(train_X[:,i])
    minBound = min(train_X[:,i])
    train_X[:,i] = ( ((train_X[:,i]-minBound)/(maxBound-minBound))*(maxValue[i]-minValue) ) + minValue
    valid_X[:,i] = ( ((valid_X[:,i]-minBound)/(maxBound-minBound))*(maxValue[i]-minValue) ) + minValue
    test_X[:,i] = ( ((test_X[:,i]-minBound)/(maxBound-minBound))*(maxValue[i]-minValue) ) + minValue

# Define the neural network
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
import matplotlib.pyplot as plt


# Auto Loop ----------------------------------------

success = 0;
tryTimes = 0;
while success == 0:
    
    model = Sequential()
    model.add(Dense(128, input_dim=25, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(256, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(512, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(512, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(512, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(512, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(512, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(448, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(384, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(256, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(128, kernel_initializer ='random_normal', activation='relu'))
    model.add(Dense(1, kernel_initializer ='random_normal'))
    model.compile(loss='mean_absolute_error', optimizer='adam', metrics=['accuracy'])
    
    threshold = 60000
    diff = 2000000
    times = 90
    epochsTimes = 0
    loss_Val = [0] * times
    loss = [0] * times
    tryTimes = tryTimes + 1
    while diff > threshold and epochsTimes < times:
        history = model.fit(train_X, train_Y, batch_size=128, epochs=1, verbose=0, validation_data=(valid_X, valid_Y))
        diff = history.history['val_loss'][0]
        loss_Val[epochsTimes] = diff
        loss[epochsTimes] = history.history['loss'][0]
        epochsTimes = epochsTimes + 1;
        
        print(tryTimes,':',epochsTimes)
        print ("loss:", history.history['loss'][0])
        print ("val_loss:", diff)
    if ( diff < threshold ):
        success = 1
        print ("Try:", tryTimes)

plt.plot(loss[0:epochsTimes-1])
plt.plot(loss_Val[0:epochsTimes-1])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'valid'], loc='upper left')
plt.show()


# Test modelf -------------------------------------------
valid_Y_pre = model.predict(valid_X)
diff = 0;
for i in range(0,len(valid_Y_pre)):
    diff = diff + abs(valid_Y_pre[i]-valid_Y[i])
diff = diff/len(valid_Y_pre)
print ("Diff:", diff)

test_Y = model.predict(test_X)
pred_submit = pd.DataFrame({'id': np.int32(test_Idx.tolist()), 'price': test_Y.ravel()})
pred_submit.to_csv('result.csv',index=False)