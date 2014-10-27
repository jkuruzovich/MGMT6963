# source(r_scripts/feature_generation.R')

# Factors to 
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

# Adding time features to the data frame
#
# {{
#    addTimeFeatures(traindata)
# }}
#
# @param dataframe - traindata
# @return a new dataframe with added features
#
addTimeFeatures <- function(dataframe) {
  date = as.POSIXlt(dataframe$unix_timestamp_of_request_utc, tz="UTC", origin="1970-01-01");
  dataframe$day_of_month <- date$mday
  dataframe$day_of_week <- date$wday
  dataframe$day_of_year <- date$yday
  dataframe$month <- date$mon
  dataframe$hour <- date$hour
  dataframe$year <- date$year
  return(dataframe)
}

# Adding user activity features to the data frame
#
# {{
#    addUserActivityScoreFeatures(traindata)
# }}
#
# @param dataframe - traindata
# @return a new dataframe with added features
#
addUserActivityScoreFeatures <- function(df) {
  df$avg_comments_per_day_at_request <- df$requester_number_of_comments_at_request / df$requester_account_age_in_days_at_request
#   df$avg_comments_per_day_at_retrieval <- df$requester_number_of_comments_at_retrieval / df$requester_account_age_in_days_at_retrieval
  df$avg_posts_per_day_at_request <- df$requester_number_of_posts_at_request / df$requester_account_age_in_days_at_request
#   df$avg_posts_per_day_at_retrieval <- df$requester_number_of_posts_at_retrieval / df$requester_account_age_in_days_at_retrieval
  
  df$avg_raop_posts_per_day_at_request <- df$requester_number_of_posts_on_raop_at_request / df$requester_account_age_in_days_at_request
#   df$avg_raop_posts_per_day_at_retrieval <- df$requester_number_of_posts_on_raop_at_retrieval / df$requester_account_age_in_days_at_retrieval
  
  df$avg_requester_subreddits_at_request <- df$requester_subreddits_at_request / df$requester_account_age_in_days_at_request
  
#   df$avg_number_of_upvotes_of_request_at_request <- df$number_of_upvotes_of_request_at_request / df$requester_account_age_in_days_at_request
#   df$avg_number_of_downvotes_of_request_at_request <- df$number_of_downvotes_of_request_at_request / df$requester_account_age_in_days_at_request
  
  df$requester_upvotes_at_request = (df$requester_upvotes_plus_downvotes_at_request + df$requester_upvotes_minus_downvotes_at_request)/ 2
 
  return(df)
}

addUserSubreddits <- function(df) {
  subreddits<-c()
  for (i in 1:length(traindata$requester_subreddits_at_request)){
    subreddits[i]<-length(strsplit(split=",", x=as.character(traindata$requester_subreddits_at_request)[i])[[1]])
  }
  
  df$requester_subreddits_at_request1<-subreddits
  return(df)
}

