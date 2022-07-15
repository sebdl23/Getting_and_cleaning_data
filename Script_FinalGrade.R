library(dplyr)
library(data.table)
library(matrixStats)

#Combine test Files

y_test <- fread("y_test.txt")
x_test <- fread("x_test.txt")
features <- fread("features.txt")
colnames(x_test) <- features$V2
testDT <- x_test
testDT$Activity <- y_test$V1

#Combine train files 

y_train <- fread("y_train.txt")
x_train <- fread("x_train.txt")
colnames(x_train) <- features$V2
trainDT <- x_train
trainDT$Activity <- y_train$V1

#Combine train and test
data <- combine(trainDT, testDT)

#act. Labels
Act.Names <- fread("activity_labels.txt")
data$Activity <- gsub("5", Act.Names[5,2], data$Activity)
data$Activity <- gsub("1", Act.Names[1,2], data$Activity)
data$Activity <- gsub("2", Act.Names[2,2], data$Activity)
data$Activity <- gsub("3", Act.Names[3,2], data$Activity)
data$Activity <- gsub("4", Act.Names[4,2], data$Activity)
data$Activity <- gsub("6", Act.Names[6,2], data$Activity)

#means and std
data_names <- names(data)
mean_f <- grep("mean", data_names)
std_f <- grep("std", data_names)
Activity_f <- grep("Activity", data_names)
filter_vec <- combine( Activity_f, mean_f, std_f)
data_ok <- select(data, filter_vec)

#subject data
sub_test <- fread("subject_test.txt")
sub_train <- fread("subject_train.txt")
subjects <- combine(sub_test, sub_train)
data_sub <- data_ok
data_sub$subject <- subjects$V1

#split into diff. subjects
Sub_spef <- split(data_sub, by = c("subject","Activity"), keep.by = FALSE)
Sub_spef_mean <- lapply(Sub_spef, function(x) colMeans(x, na.rm = TRUE))
final_df <- as.data.frame(Sub_spef_mean)
names(final_df) <- sub("X","Subject",names(final_df))
row.names(final_df) <- paste("Aver", row.names(final_df), sep = "_") 
write.csv(final_df, file = "Aver_Values_for_Subjects.csv")
