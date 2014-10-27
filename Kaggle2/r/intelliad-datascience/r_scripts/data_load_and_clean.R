traindata<-read.csv2("raw_data/train.csv",header=TRUE,dec=".")
testdata<-read.csv2("raw_data/test.csv",header=TRUE,dec=".")
str(traindata)
clean <- function(data) {
  # data$post_was_edited1<-as.logical(data$post_was_edited) 
  # should not be used - data leaked
  # data$requester_user_flair1<-data$requester_user_flair
  # levels(data$requester_user_flair1)
  # levels(data$requester_user_flair1)[1]<-"None"
  data$textsize<-data$request_text
  data$giver_username1<-as.character(data$giver_username_if_known)
  data$giver_username1[data$giver_username1=="N/A"]<-NA
  data$giver_username2<-is.na(data$giver_username1)
  data$textsize <- sapply(data$request_text, function(x) nchar(as.character(x)))
  #data$giver_username1<-as.character(data$giver_username)
  return(data)
}

traindata <- clean(traindata)
traindata <- addTimeFeatures(traindata)
traindata <- addUserActivityScoreFeatures(traindata)

testdata <- clean(testdata)
testdata <- addTimeFeatures(testdata)
testdata <- addUserActivityScoreFeatures(testdata)