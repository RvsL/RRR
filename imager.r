#install.packages('imager',repos='http://cran.us.r-project.org')
require(EBImage)
require(dplyr)

source('~/RRR/telegram.r')

image.side <- 80
train.length <- image.side*image.side + 1

grayscalePics <- function(local.wd, save_in){
# Set wd where images are located
setwd(local.wd)
# Set d where to save images
#save_in <- "/Users/RvsL/python/facialLidogenerator/badFaces/trainBad/"
# Load images names
images <- list.files()
# Set width
w <- image.side
# Set height
h <- image.side

# Main loop resize images and set them to greyscale
pb <- txtProgressBar(style = 3, min=0, max = length(images))
for(i in 1:length(images))
{
    # Try-catch is necessary since some images
    # may not work.
    result <- tryCatch({
    # Image name
    imgname <- images[i]
    # Read image
    img <- readImage(imgname)
    # Resize image 28x28
    img_resized <- resize(img, w = w, h = h)
    # Set to grayscale
    #grayimg <- channel(img_resized,"gray")
    grayimg <- img_resized
    # Path to file
    path <- paste(save_in, imgname, sep = "")
    # Save image
    writeImage(grayimg, path, quality = 70)
    # Print status
   	setTxtProgressBar(pb, i)},
    # Error function
    error = function(e){print(e)})
}
}


##########################################

convertGray <- function(save_in, out_file, label){
# Set wd where resized greyscale images are located
setwd(save_in)

# Out file

# List images in path
images <- list.files()

# Set up df
df <- data.frame()

# Set image size. In this case 28x28
img_size <- image.side*image.side

# Set label
# label <- 1

pb <- txtProgressBar(style = 3, min=0, max = length(images))
# Main loop. Loop over each image
for(i in 1:length(images))
{
    # Read image
    img <- readImage(images[i])
    # Get the image as a matrix
    img_matrix <- img@.Data
    # Coerce to a vector
    img_vector <- as.vector(t(img_matrix))
    # Add label
    vec <- c(label, img_vector)
    # Bind rows
    df <- rbind(df,vec)
    # Print status info
    #print(paste("Done ", i, sep = ""))
	setTxtProgressBar(pb, i)
}

# Set names
names(df) <- c("label", paste("pixel", c(1:img_size)))

# Write out dataset
write.csv(df, out_file, row.names = FALSE)
}

root.wd <- "/Users/RvsL/python/facialLidogenerator"

train.dir <- "goodFaces"
grayscalePics(paste0(root.wd,"/",train.dir,"/"), paste0(root.wd,"/",train.dir,"/train/"))
convertGray(paste0(root.wd,"/",train.dir,"/train/"), paste0(root.wd,"/",train.dir,".csv"), 1)#good

train.dir <- "badFaces"
grayscalePics(paste0(root.wd,"/",train.dir,"/"), paste0(root.wd,"/",train.dir,"/train/"))
convertGray(paste0(root.wd,"/",train.dir,"/train/"), paste0(root.wd,"/",train.dir,".csv"), 2)#bad

train.dir <- "goodFaces"
df.1 <- read.csv(paste0(root.wd,"/",train.dir,".csv"))
train.dir <- "badFaces"
df.2 <- read.csv(paste0(root.wd,"/",train.dir,".csv"))

# Bind rows in a single dataset
df <- rbind(df.1, df.2)
df$label <- as.factor(df$label)

shuffled <- df[sample(1:nrow(df)),]

# Train-test split

test.percent <- 10 #%


ndata <- nrow(df)
ntest <- round(ndata * test.percent/100)
ntrain <- ndata - ntest

train <- shuffled[1:ntrain,]
test <- shuffled[(ntrain + 1):ndata,]

#в переменную Х надо загрузить например одну строчку для каждого лица с какой то картинки
#очевидно что эти строчки должны быть приведены к такому же формату как и обучающие картинки

# v.local.wd <- "/Users/RvsL/python/facialLidogenerator/forNN_toClassify"
# v.save_in.3 <- "/Users/RvsL/python/facialLidogenerator/forNN_toClassify/formatted/"
# grayscalePics(v.local.wd, v.save_in.3)
# v.out_file.3 <- paste0(v.save_in.3, "/classify.csv")
# convertGray(v.save_in.3, v.out_file.3, 3)#unknown
# df.3 <- read.csv(v.out_file.3)
# X <- df.3[,2:785]

########################################
#поднимаем нейросетку и собственно ее тренируем

# library(h2o)
# h2o.init(nthreads = -1, max_mem_size = "3G")

train_h2o <- as.h2o(train)
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,hidden=c(5000,5000,5000,5000),epochs=1e6)
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,hidden=c(100,100,100,100,100,100,100),epochs=1e6)
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,hidden=c(500,500,500,500,500,500,500),epochs=1e8)
#nnet.model <- h2o.deeplearning(2:train.length,1,train_h2o,epochs=1e8)
nnet.model <- h2o.randomForest(2:train.length,1,train_h2o,ntrees = 100)

predicted_class <- as.matrix(h2o.predict(nnet.model, as.h2o(test)))
#res <- round(as.matrix(predicted_class))
# res <- as.data.frame(res)
# res.1 <- res %>% filter(predict == 1)
# 
# quality <- round((nrow(res.1) / nrow(res)) * 100)

res <- as.matrix(predicted_class)
res <- as.data.frame(res) %>% select(predict) %>% mutate(predict = as.numeric(predict))

res <- cbind.data.frame(predict = res[,1], fact = test[,1]) %>% mutate(hit = ifelse(predict == fact, 1, 0))
quality <- round(100*sum(res$hit) / nrow(res))
cat("quality = ", quality, "%")
bot$sendMessage(paste0("quality = ", quality, "%"))

#h2o.saveModel('/Users/RvsL/python/facialLidogenerator/', object=nnet.model)
#потом надо не забыть ее вырубить, но не раньше чем она нам распознает парочку людей
#h2o.shutdown(prompt=FALSE)