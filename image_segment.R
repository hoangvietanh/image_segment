if (!require("png")) install.packages("png")
if (!require("grid")) install.packages("grid")
if (!require("gridExtra")) install.packages("gridExtra")
library("png")
library("grid")
library("gridExtra")

setwd("C:/todel/")
# download the nt image
#if(!file.exists("nt")){
  download.file(url = "https://dl.dropboxusercontent.com/u/549234/nt.png")
}

# load the PNG into an RGB image object
nt = readPNG("pha.png")

# This nt is 512 x 512 x 3 array
dim(nt)
## [1] 512 512   3

### EX 1: show the full RGB image
grid.raster(nt)

### EX 2: show the B channel in gray scale representing pixel intensity
grid.raster(nt[,,10])

### EX 3: show the 3 channels in separate images
# copy the image three times
nt.R = nt
nt.G = nt
nt.B = nt

# zero out the non-contributing channels for each image copy
nt.R[,,2:3] = 0
nt.G[,,1]=0
nt.G[,,3]=0
nt.B[,,1:2]=0

# build the image grid
img1 = rasterGrob(nt.R)
img2 = rasterGrob(nt.G)
img3 = rasterGrob(nt.B)
grid.arrange(img1, img2, img3, nrow=1)

# reshape image into a data frame
df = data.frame(
  red = matrix(nt[,,1], ncol=1),
  green = matrix(nt[,,2], ncol=1),
  blue = matrix(nt[,,3], ncol=1)
)

### compute the k-means clustering
K = kmeans(df,3)
df$label = K$cluster

### Replace the color of each pixel in the image with the mean 
### R,G, and B values of the cluster in which the pixel resides:

# get the coloring
colors = data.frame(
  label = 1:nrow(K$centers), 
  R = K$centers[,"red"],
  G = K$centers[,"green"],
  B = K$centers[,"blue"]
)

# merge color codes on to df
# IMPORTANT: we must maintain the original order of the df after the merge!
df$order = 1:nrow(df)
df = merge(df, colors)
df = df[order(df$order),]
df$order = NULL
Finally, we have to reshape our data frame back into an image:
  
  # get mean color channel values for each row of the df.
  R = matrix(df$R, nrow=dim(nt)[1])
G = matrix(df$G, nrow=dim(nt)[1])
B = matrix(df$B, nrow=dim(nt)[1])

# reconstitute the segmented image in the same shape as the input image
nt.segmented = array(dim=dim(nt))
nt.segmented[,,1] = R
nt.segmented[,,2] = G
nt.segmented[,,3] = B

# View the result
grid.raster(nt.segmented)
