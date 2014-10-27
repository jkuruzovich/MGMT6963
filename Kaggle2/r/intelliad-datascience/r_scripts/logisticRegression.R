# Adjust part and call this upfront to set your working directory
# setwd("Y:\\Analysis\\Random-Acts-of-Pizza")


traindata<-read.csv2("raw_data/train.csv",header=TRUE,dec=".")


#-------------------------
# Logische Variablen
#-------------------------

traindata$post_was_edited1<-as.logical(traindata$post_was_edited)

traindata$requester_user_flair1<-traindata$requester_user_flair
levels(traindata$requester_user_flair1)
levels(traindata$requester_user_flair1)[1]<-"None"

traindata$giver_username1<-as.character(traindata$giver_username)
table(traindata$giver_username1)

traindata$giver_username1[traindata$giver_username1=="N/A"]<-NA
source("r_scripts/feature_generation.R")
traindata <- addTimeFeatures(traindata)
traindata <- addUserActivityScoreFeatures(traindata)


subreddits<-c()
for (i in 1:length(traindata$requester_subreddits_at_request)){
  subreddits[i]<-length(strsplit(split=",", x=as.character(traindata$requester_subreddits_at_request)[i])[[1]])
}

traindata$requester_subreddits_at_request1<-subreddits

######logistic regression ####
library(caret)
library(car)
library(e1071)
library(verification)

traindata$requester_received_pizza1 <- as.numeric(traindata$requester_received_pizza)-1


selectedAttributes=formula(requester_received_pizza
~
+requester_account_age_in_days_at_request  
+requester_days_since_first_post_on_raop_at_request
+requester_number_of_comments_in_raop_at_request
+requester_number_of_posts_on_raop_at_request
)



tc <- trainControl("cv", 5, savePredictions=T,classProbs = TRUE, summaryFunction = twoClassSummary)
model1 <- train(selectedAttributes, 
data=traindata, method="glm", family=binomial(link="logit"), trControl=tc, metric = "ROC")
finalModel<-model1$finalModel

testdata<-read.csv2("raw_data/test.csv",header=TRUE,dec=".")

prediction<-predict(finalModel,testdata,type="prob")

results = data.frame(
 request_id = testdata$request_id,
  prediction
    )

    write.csv(results, file="logreg_result.csv", quote=FALSE, row.names=F)



###### end #######


predictWithNaiveBayes <- function(trainSet, testSet, features = naiveColumnsAwesome) {
  model <- train(
    x = trainSet[features],
    y = trainSet$requester_received_pizza,
    "nb", 
    trControl = trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = twoClassSummary),
    metric = "ROC"
  )
  naiveModel = model$finalModel
  prediction = predict(naiveModel, testSet)
  
  results = data.frame(
    request_id = testSet$request_id,
    requester_received_pizza = prediction$posterior[,2]
  )
  
  return(results)
}






## feature selection ##
simplenames<- setdiff(names(traindata),c("giver_username1","giver_username_if_known","post_was_edited" ,"requester_username" ,"requester_subreddits_at_request", "request_text", "request_text_edit_aware", "request_title", "unix_timestamp_of_request", "unix_timestamp_of_request_utc", "requester_username", "request_id" ,"requester_received_pizza", "requester_subreddits_at_request", "requester_user_flair", "requester_user_flair1" ,"requester_username",
"request_number_of_comments_at_retrieval","requester_account_age_in_days_at_retrieval","requester_days_since_first_post_on_raop_at_retrieval","requester_number_of_comments_in_raop_at_retrieval","requester_number_of_posts_on_raop_at_retrieval","requester_upvotes_minus_downvotes_at_retrieval","number_of_downvotes_of_request_at_retrieval","number_of_upvotes_of_request_at_retrieval","requester_number_of_comments_at_retrieval","requester_number_of_posts_at_retrieval","requester_upvotes_plus_downvotes_at_retrieval","post_was_edited1"
))

traindata.simple<-traindata[,simplenames]

traindata.simple<-traindata[,-c("giver_username_if_known","requester_username" ,"requester_subreddits_at_request", "request_text", "request_text_edit_aware", "request_title", "unix_timestamp_of_request", "unix_timestamp_of_request_utc", "requester_username", "request_id" ,"requester_received_pizza1", "requester_subreddits_at_request", "requester_user_flair" ,"requester_username")]

summary(modelglm <- glm(requester_received_pizza1~., data = traindata.simple), family=binomial(link="logit"),direction="backward", trace=T )
slm1 <- step(modelglm)
summary(slm1)
slm1$anova
####forward####
summary(modelglm <- glm(requester_received_pizza1~1, data = traindata.simple), family=binomial(link="logit"))
slm1 <- step(modelglm,direction="forward", trace=T , scope=list(lower=~1,upper=~requester_account_age_in_days_at_request
+requester_days_since_first_post_on_raop_at_request
+requester_number_of_comments_at_request
+requester_number_of_comments_in_raop_at_request
+requester_number_of_posts_at_request
+requester_number_of_posts_on_raop_at_request
+requester_number_of_subreddits_at_request
+requester_upvotes_minus_downvotes_at_request
+requester_upvotes_plus_downvotes_at_request
+post_was_edited1
))
summary(slm1)
slm1$anova

model1 <- train(requester_received_pizza~.-giver_username_if_known -post_was_edited -requester_username -requester_subreddits_at_request -request_text -request_text_edit_aware -request_title -unix_timestamp_of_request -unix_timestamp_of_request_utc -requester_username,
data=traindata, method="glm", family=binomial(link="logit"), trControl=tc, metric = "ROC")

##working version ###
#model1 <- train(requester_received_pizza~requester_subreddits_at_request1+number_of_upvotes_of_request_at_retrieval, 
#data=traindata, method="glm", family=binomial(link="logit"), trControl=tc, metric = "ROC")
