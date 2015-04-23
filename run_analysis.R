library(plyr)
library(data.table)
library(utils)


###load generic data
activities<-data.table(read.table("activity_labels.txt"))
xcolumns<-data.table(read.table("features.txt"))

###load training set data
xtr<-data.table(read.table("train/X_train.txt"))
ytr<-data.table(read.table("train/Y_train.txt"))
subjecttr<-data.table(read.table("train/subject_train.txt"))

###load test set data
xte<-data.table(read.table("test/X_test.txt"))
yte<-data.table(read.table("test/Y_test.txt"))
subjectte<-data.table(read.table("test/subject_test.txt"))

###set column names for generic data
colnames(activities)<-c("activitycode","activityname")

###set column names for training data
colnames(xtr)<-as.character(xcolumns$V2)
colnames(ytr)<-"activitycode"
colnames(subjecttr)<-"subject"

###set column names for test data
colnames(xte)<-as.character(xcolumns$V2)
colnames(yte)<-"activitycode"
colnames(subjectte)<-"subject"

###join data sets for training
setkey(activities,activitycode)
setkey(ytr,activitycode)
yatr<-merge(ytr,activities)
xytr<-cbind(xtr,yatr)
xytr<-cbind(xytr,subjecttr)

###join data sets for test
setkey(yte,activitycode)
yate<-merge(yte,activities)
xyte<-cbind(xte,yate)
xyte<-cbind(xyte,subjectte)

###filter "mean" and "std" columns + activity and subject for training
stdvect<-grep("[Ss]td",xcolumns$V2)
meanvect<-grep("[Mm]ean",xcolumns$V2)
colvect<-sort(c(stdvect,meanvect))
###create a column vector for aggregation
aggregatevect<-colvect
colvect<-c(563,564,colvect)

###filter columns for training
xyfilt<-xytr[,colvect,with=FALSE]

###add filtered test to filtered training
xyfilt<-rbind(xyfilt,xyte[,colvect,with=FALSE])

### modify column names: all to lowercase; remove >(),-< 
colnames(xyfilt)<-gsub("[(),-]","",tolower(colnames(xyfilt)))