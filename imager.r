#install.packages('imager',repos='http://cran.us.r-project.org')
require(EBImage)

grayscalePics <- function(local.wd, save_in){
# Set wd where images are located
setwd(local.wd)
# Set d where to save images
#save_in <- "/Users/RvsL/python/facialLidogenerator/badFaces/trainBad/"
# Load images names
images <- list.files()
# Set width
w <- 100
# Set height
h <- 100

# Main loop resize images and set them to greyscale
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
    grayimg <- channel(img_resized,"gray")
    # Path to file
    path <- paste(save_in, imgname, sep = "")
    # Save image
    writeImage(grayimg, path, quality = 70)
    # Print status
    print(paste("Done",i,sep = " "))},
    # Error function
    error = function(e){print(e)})
}
}

v.local.wd <- "/Users/RvsL/python/facialLidogenerator/goodFaces"
v.save_in <- "/Users/RvsL/python/facialLidogenerator/goodFaces/trainGood/"
grayscalePics(v.local.wd, v.save_in)

v.local.wd <- "/Users/RvsL/python/facialLidogenerator/badFaces"
v.save_in <- "/Users/RvsL/python/facialLidogenerator/badFaces/trainBad/"
grayscalePics(v.local.wd, v.save_in)




##########################################

convertGray <- function(save_in, out_file, label)
{
# Set wd where resized greyscale images are located
setwd(save_in)

# Out file

# List images in path
images <- list.files()

# Set up df
df <- data.frame()

# Set image size. In this case 28x28
img_size <- 28*28

# Set label
# label <- 1

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
    print(paste("Done ", i, sep = ""))
}

# Set names
names(df) <- c("label", paste("pixel", c(1:img_size)))

# Write out dataset
write.csv(df, out_file, row.names = FALSE)
}

v.save_in.1 <- "/Users/RvsL/python/facialLidogenerator/goodFaces/trainGood"#убрать закрывающий слэшшшшшш!
v.save_in.2 <- "/Users/RvsL/python/facialLidogenerator/badFaces/trainBad"
v.out_file.1 <- paste0(v.save_in.1, "/good.csv")
v.out_file.2 <- paste0(v.save_in.2, "/bad.csv")

convertGray(v.save_in.1, v.out_file.1, 1)#good
convertGray(v.save_in.2, v.out_file.2, 2)#bad

df.1 <- read.csv(v.out_file.1)
df.2 <- read.csv(v.out_file.2)

# Bind rows in a single dataset
df <- rbind(df.1, df.2)

#в переменную Х надо загрузить например одну строчку для каждого лица с какой то картинки
#очевидно что эти строчки должны быть приведены к такому же формату как и обучающие картинки

v.local.wd <- "/Users/RvsL/python/facialLidogenerator/forNN_toClassify"
v.save_in.3 <- "/Users/RvsL/python/facialLidogenerator/forNN_toClassify/formatted/"
grayscalePics(v.local.wd, v.save_in.3)
v.out_file.3 <- paste0(v.save_in.3, "/classify.csv")
convertGray(v.save_in.3, v.out_file.3, 3)#unknown
df.3 <- read.csv(v.out_file.3)
X <- df.3[,2:785]

########################################
#поднимаем нейросетку и собственно ее тренируем

library(h2o)
h2o.init(nthreads = -1, max_mem_size = "3G")

train_h2o <- as.h2o(df)
#nnet.model <- h2o.deeplearning(2:785,1,train_h2o,epochs=1e3)
nnet.model <- h2o.randomForest(2:785,1,train_h2o)

predicted_class <- as.matrix(h2o.predict(nnet.model, as.h2o(X)))

#потом надо не забыть ее вырубить, но не раньше чем она нам распознает парочку людей
h2o.shutdown(prompt=FALSE)