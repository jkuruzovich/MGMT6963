# naiveColumns = c("day_of_week", "hour", "requester_number_of_comments_at_request")

naiveColumns = c(
  # "giver_username_if_known",
  "requester_account_age_in_days_at_request",
  "requester_days_since_first_post_on_raop_at_request",
  "requester_number_of_comments_at_request",            
  "requester_number_of_comments_in_raop_at_request", 
  "requester_number_of_posts_at_request",        
  "requester_number_of_posts_on_raop_at_request",       
  "requester_number_of_subreddits_at_request",
  "requester_subreddits_at_request",
  "requester_upvotes_minus_downvotes_at_request",
  "requester_upvotes_plus_downvotes_at_request",
  "day_of_month",
  "day_of_week",
  "day_of_year", 
  "month",
  "hour",      
  "year",
  "avg_comments_per_day_at_request",
  "avg_posts_per_day_at_request",
  "avg_raop_posts_per_day_at_request",
  "avg_requester_subreddits_at_request",
  "requester_upvotes_at_request",
  "requester_subreddits_at_request1"
)

naiveColumnsAwesome = c(
  "requester_account_age_in_days_at_request",
  "requester_days_since_first_post_on_raop_at_request",
  "requester_number_of_comments_at_request",            
  "requester_number_of_comments_in_raop_at_request", 
  "requester_number_of_posts_at_request",        
  "requester_number_of_posts_on_raop_at_request",   
  "requester_upvotes_at_request",
  "day_of_week",
  "month",
  "hour",      
  "year"
)

naiveBayesBenchmark <- function(data, columns = naiveColumnsAwesome) {
  naiveBayesModel <- train(
    x = data[columns],
    y = data$requester_received_pizza,
    "nb", 
    trControl = trainControl(method = "cv", number = 10, classProbs = TRUE, summaryFunction = twoClassSummary),
    metric = "ROC"
  )
  
  row = data.frame(
    false = naiveBayesModel$results$ROC[1],
    true = naiveBayesModel$results$ROC[2],
    features = paste(columns, collapse = ' | ')      
  )
  return(row)
}

naiveBayesFeatureSelection <- function(data, names = naiveColumns, window = 3) {
  
  positions = seq(1, length(names)-window)
  print('Running feature selection for naive bayes')
  results = data.frame()
  
  for(i in positions) {
    possibleError <- tryCatch({
      columns = names[i:(i+window-1)]
      row = naiveBayesBenchmark(data, columns)
      print(row)
      
      results = rbind(results, row)
    }, error=function(e) e
    )
    
    if(inherits(possibleError, "error")) {
      print(paste(columns, collapse = ' | ') )
      next
    }
    
  }
  
  return(results)
}

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
  
  write.csv2(results, file="prediction.naive.csv", sep=",", row.names = FALSE)
  
  return(results)
}

naiveBayesFeatureSelection(traindata, names=naiveColumns, window=3)
naiveBayesFeatureSelection(traindata, names=naiveColumns, window=5)

# naiveBayesModel <- train(
#     x = traindata[naiveColumnsAwesome], # naiveColumns[1:5] 
#     y = traindata$requester_received_pizza,
#     "nb", 
#     trControl = trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = twoClassSummary),
#     metric = "ROC"
# )
# naiveBayesModel

