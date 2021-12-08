# prepare for R packages
library(dplyr)
library(data.table)

filename <- "projectYX.zip"

#download dataset
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method = "curl")
    unzip(filename)
}

# load activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

#load features
features <- read.table("./UCI HAR Dataset/features.txt")

#load test data
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

#load train data
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

#1 Merges the training and the test sets to create one data set.
x <- rbind(x_train, x_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
data <- cbind(subject, y, x)

#name all column, include first two columns:subject and activity
colnames(data) = c("subject", "activity", features[,2])

#2 Extracts only the measurements on the mean and standard deviation for each measurement. 
#select features with name mean/std, also include first two columns
extract_features <- grepl("mean|std", features[ ,2])
extract1_features <- c(TRUE, TRUE, extract_features)
extract_data <- data[ , extract1_features]

#3 Uses descriptive activity names to name the activities in the data set
extract_data$activity <- activity_labels[extract_data$activity, 2]

#4 Appropriately labels the data set with descriptive variable names. 
colnames(extract_data) <- gsub("Acc", "Acceleration", colnames(extract_data))
colnames(extract_data) <- gsub("Gyro", "Gyroscope", colnames(extract_data))
colnames(extract_data) <- gsub("Mag", "Magnitude", colnames(extract_data))
colnames(extract_data) <- gsub("Freq", "Frequency", colnames(extract_data))
colnames(extract_data) <- gsub("^t", "Time", colnames(extract_data))
colnames(extract_data) <- gsub("^f", "Frequency", colnames(extract_data))

#5 From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
final_data <- summarise_all(group_by(extract_data, subject, activity), mean)

#save the second tidy data set into final_data.txt.
write.table(final_data, "final_data.txt")


