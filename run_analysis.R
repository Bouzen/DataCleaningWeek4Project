########Gathering data
##colnames
library(dplyr)
datacolnames<-read.csv('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/features.txt',sep=' ', header=FALSE)
colnames(datacolnames)<- c('rownumber','Metric')
datacolnames$IsMeanorStd<- (regexpr('mean',datacolnames$Metric) >= 0 | regexpr('std',datacolnames$Metric)>= 0)

##FixedWidth format
8976/16 ##finding how many columns
FwfCols<-data.frame(rownames = 1:561,width = 16)

##Test data
test<-read.fwf('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/test/X_test.txt'
                , header=FALSE
               ,widths = FwfCols$width)
colnames(test) <- datacolnames$Metric
test<-test[,datacolnames$IsMeanorStd]
##Mapping test subject in
testsubject<-read.csv('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt',header=FALSE)
colnames(testsubject)<-c('subject')
test<-cbind(test,testsubject$subject)

##Mapping activity in
testactivity <- read.csv('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt',header=FALSE) 
colnames(testactivity)<-c('activity')
test<-cbind(test,testactivity$activity)
colnames(test)[c(80,81)]<- c('subject','activity')

##Training data
train<-read.fwf('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/train/X_train.txt'
               , header=FALSE
               ,widths = FwfCols$width)
colnames(train)<-datacolnames$Metric
train<-train[,datacolnames$IsMeanorStd]
##Mapping training subjects in
trainsubject<-read.csv('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt',header=FALSE)
colnames(trainsubject)<-c('subject')
train<-cbind(train,trainsubject$subject)
##Mapping activity in
trainactivity<-read.csv('C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/train/y_train.txt',header = FALSE)
colnames(trainactivity)<-c('activity')
train<-cbind(train,trainactivity$activity)
colnames(train)[c(80,81)]<- c('subject','activity')


##Merged data
alldata<-rbind(train,test) 

##Getting aggregate level on subject and activity level
datasummary<-aggregate(.~subject+activity,data=alldata,FUN=mean)

##activity names
act<-data.frame(activity=1:6,activityname = c('Walking','Walking Upstairs','Walking Downstairs','Sitting','Standing','Laying'))
tidydatasummary<-merge(datasummary,act, by = 'activity',all.x=TRUE)
tidydatasummary$activity<-tidydatasummary$activityname
tidydatasummary<-tidydatasummary[1:81]

##even better measure names
names(tidydatasummary) <- gsub('^t', 'time', names(tidydatasummary))
names(tidydatasummary) <- gsub('^f', 'frequency', names(tidydatasummary))
names(tidydatasummary) <- gsub('Acc', 'Accelerometer', names(tidydatasummary))
names(tidydatasummary) <- gsub('Gyro','Gyroscope', names(tidydatasummary))
names(tidydatasummary) <- gsub('mean[(][)]','Mean',names(tidydatasummary))
names(tidydatasummary) <- gsub('std[(][)]','Std',names(tidydatasummary))
names(tidydatasummary) <- gsub('-','',names(tidydatasummary))

write.table(tidydatasummary, file = 'C:/Users/Nate/Documents/Data Science Course/Data Cleaning/Week 4 project/tidy.txt', row.names=FALSE)
