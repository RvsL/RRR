library(h2o)
h2o.init(nthreads = -1)

#train <- h2o.importFile('/Users/RvsL/RRR/h2o/train.csv', header=TRUE)
#test <- h2o.importFile('/Users/RvsL/RRR/h2o/test.csv', header=TRUE)

train <- read.csv('/Users/RvsL/RRR/h2o/train.csv', header=TRUE)
test <- read.csv('/Users/RvsL/RRR/h2o/test.csv', header=TRUE)
train <- data.matrix(train)
test <- data.matrix(test)

train.x <- train[,-1]
train.y <- train[,1]

train.x <- t(train.x/255)
test <- t(test/255)
table(train.y)

train.array <- train.x
dim(train.array) <- c(28, 28, 1, ncol(train.x))
test.array <- test
dim(test.array) <- c(28, 28, 1, ncol(test))

train_h2o <- as.h2o(train)
nnet.model <- h2o.deeplearning(2:785,1,train_h2o,epochs=1e3)


nnet.model2 <- h2o.randomForest(2:785,1,train_h2o)


h2o.shutdown(prompt=FALSE)