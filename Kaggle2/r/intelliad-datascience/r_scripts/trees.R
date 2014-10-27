require(caret)
require(pROC)

ctrl <- trainControl(method = "cv", repeats =5, classProbs = TRUE, summaryFunction = twoClassSummary)

TREE<- train(         requester_received_pizza ~ 
                      giver_username2 +
                      #number_of_downvotes_of_request_at_retrieval +         
                      #number_of_upvotes_of_request_at_retrieval +
                      #request_number_of_comments_at_retrieval +           
                      requester_account_age_in_days_at_request +
                      #requester_account_age_in_days_at_retrieval +
                      requester_days_since_first_post_on_raop_at_request +
                      #requester_days_since_first_post_on_raop_at_retrieval +
                      requester_number_of_comments_at_request +           
                      #requester_number_of_comments_at_retrieval +
                      requester_number_of_comments_in_raop_at_request + 
                      #requester_number_of_comments_in_raop_at_retrieval +
                      requester_number_of_posts_at_request +       
                      #requester_number_of_posts_at_retrieval +
                      requester_number_of_posts_on_raop_at_request +      
                      #requester_number_of_posts_on_raop_at_retrieval +
                      requester_number_of_subreddits_at_request +
                      #requester_subreddits_at_request +
                      requester_upvotes_minus_downvotes_at_request +
                      #requester_upvotes_minus_downvotes_at_retrieval +   
                      requester_upvotes_plus_downvotes_at_request +
                      #requester_upvotes_plus_downvotes_at_retrieval + 
                      #requester_user_flair +
                      #requester_user_flair1 + 
                      textsize +
                      day_of_month +
                      day_of_week +
                      day_of_year + 
                      month +
                      hour +     
                      year +
                      avg_comments_per_day_at_request +
                      #avg_comments_per_day_at_retrieval +
                      avg_posts_per_day_at_request +
                      #avg_posts_per_day_at_retrieval +
                      #avg_raop_posts_per_day_at_request +
                      #avg_raop_posts_per_day_at_retrieval +
                      #avg_requester_subreddits_at_request +
                      #avg_number_of_upvotes_of_request_at_retrieval +
                      #avg_number_of_downvotes_of_request_at_retrieval +
                      requester_upvotes_at_request ,
                      #requester_subreddits_at_request1,
                      data = traindata, method = "rf",
                      tuneLength = 15, 
                      trControl = ctrl, 
                      metric = "ROC",
                      preProc = c("knnImpute"))


plot(TREE$finalModel)
result <- predict.train(TREE, newdata = testdata, type="prob", verbose=TRUE, na.action=na.pass)
resultdata <- as.data.frame(testdata$request_id)
resultdata$requester_received_pizza = result$true
str(testdata)
write.csv(resultdata, file="rf_textsize_result.csv", quote=FALSE)