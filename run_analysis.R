library(reshape2)

filename <- "getdata_dataset.zip"

## Download dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Set activity labels
labels <- read.table("UCI HAR Dataset/activity_labels.txt")
labels[,2] <- as.character(labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracts only the measurements on the mean and standard deviation for each measurement
wantedfeatures <- grep(".*mean.*|.*std.*", features[,2])
wantedfeatures.names <- features[wantedfeatures,2]
wantedfeatures.names = gsub('-mean', 'Mean', wantedfeatures.names)
wantedfeatures.names = gsub('-std', 'Std', wantedfeatures.names)
wantedfeatures.names <- gsub('[-()]', '', wantedfeatures.names)


# Load datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[wantedfeatures]
trainactivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainsubjects, trainactivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[wantedfeatures]
testactivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testsubjects, testactivities, test)

# Merge datasets and add labels
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", wantedfeatures.names)

data$activity <- factor(data$activity, levels = labels[,1], labels = activityLabels[,2])
data$subject <- as.factor(data$subject)

data.melted <- melt(data, id = c("subject", "activity"))
data.mean <- dcast(data.melted, subject + activity ~ variable, mean)

## Creates a second, independent tidy data set with the average of each variable for each activity and each subjectreates a second, independent tidy data set with the average of each variable for each activity and each subject
write.table(data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
