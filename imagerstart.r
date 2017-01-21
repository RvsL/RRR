#install.packages('imager',repos='http://cran.us.r-project.org')
require(EBImage)
require(dplyr)
library(h2o)

h2o.init(nthreads = -1, max_mem_size = "3G")

source('~/RRR/telegram.r')

grayscalePics <- function(local.wd, save_in, image.side){
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

convertGray <- function(save_in, out_file, label, image.side){
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


prepareFile <- function(root.wd, train.dir, label, image.side) {
	grayscalePics(paste0(root.wd,"/",train.dir,"/"), paste0(root.wd,"/",train.dir,"/train/"), image.side)
	convertGray(paste0(root.wd,"/",train.dir,"/train/"), paste0(root.wd,"/",train.dir,".csv"), label, image.side)
}

