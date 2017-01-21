#source('~/RRR/imagerstart.r')

image.side <- 100
test.percent <- 10 #%

bot$sendMessage(paste0(Sys.time(),'\n', "image side = ", image.side, "px"))

train.length <- image.side*image.side + 1
root.wd <- "/Users/RvsL/python/facialLidogenerator"
prepareFile(root.wd,'goodFaces',1,image.side)
prepareFile(root.wd,'badFaces',2,image.side)

df.1 <- read.csv(paste0(root.wd,"/",'goodFaces',".csv"))
df.2 <- read.csv(paste0(root.wd,"/",'badFaces',".csv"))

# Bind rows in a single dataset
df <- rbind(df.1, df.2)
df$label <- as.factor(df$label)

shuffled <- df[sample(1:nrow(df)),]

# Train-test split
ndata <- nrow(df)
ntest <- round(ndata * test.percent/100)
ntrain <- ndata - ntest

train <- shuffled[1:ntrain,]
test <- shuffled[(ntrain + 1):ndata,]

########################################
#поднимаем нейросетку и собственно ее тренируем

# library(h2o)
# h2o.init(nthreads = -1, max_mem_size = "3G")

train_h2o <- as.h2o(train)

bot$sendMessage(paste0("starting nnet modeling: ",'\n', Sys.time()))
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,hidden=c(5000,5000,5000,5000),epochs=1e6)
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,hidden=c(100,100,100,100,100,100,100),epochs=1e6)
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,hidden=c(500,500,500,500,500,500,500),epochs=1e8)
nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,epochs=1e10)
#nnet.model <- h2o.randomForest(2:train.length,1,train_h2o,ntrees = 100)

# nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,
#   model_id="dl_model_tuned", 
#   overwrite_with_best_model=F,    ## Return the final model after 10 epochs, even if not the best
#   hidden=c(700,700,700,700,700,700,700),          ## more hidden layers -> more complex interactions
#   epochs=1e10,                      ## to keep it short enough
#   score_validation_samples=10000, ## downsample validation set for faster scoring
#   score_duty_cycle=0.025,         ## don't score more than 2.5% of the wall time
#   adaptive_rate=F,                ## manually tuned learning rate
#   rate=0.01, 
#   rate_annealing=2e-6,            
#   momentum_start=0.2,             ## manually tuned momentum
#   momentum_stable=0.4, 
#   momentum_ramp=1e7, 
#   l1=1e-5,                        ## add some L1/L2 regularization
#   l2=1e-5,
#   max_w2=10                       ## helps stability for Rectifier
# ) 

# nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,
#   model_id="bin_response", 
#   hidden=c(700,700,700,700,700,700,700),          ## more hidden layers -> more complex interactions
#   epochs=1e10
# )

bot$sendMessage(paste0("ready nnet modeling: ",'\n', Sys.time()))

predicted_class <- as.matrix(h2o.predict(nnet.model, as.h2o(test)))

res <- as.matrix(predicted_class)
res <- as.data.frame(res) %>% select(predict) %>% mutate(predict = as.numeric(predict))

res <- cbind.data.frame(predict = res[,1], fact = test[,1]) %>% mutate(hit = ifelse(predict == fact, 1, 0))
quality <- round(100*sum(res$hit) / nrow(res))
cat("quality = ", quality, "%")
bot$sendMessage(paste0("quality = ", quality, "%"))
