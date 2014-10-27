library(rjson)
library(caret)
library(lubridate)
library(qdap)
options(stringsAsFactors = F)

test = fromJSON(file = 'test.json')
test = lapply(test, lapply, function(x) ifelse(is.null(x), NA, x))
test = lapply(test, lapply, lapply, function(x) ifelse(is.null(x), NA, x))
test_df = data.frame(matrix(unlist(test), byrow = T, nrow = length(test)))
names(test_df) = names(test[[1]])
save(test_df, file = 'test.RData')

#create predictors
#create narratives
req = paste(test_df$request_title, test_df$request_text_edit_aware)
req = tolower(req)
test_df$req = gsub('[^[:alpha:]]', ' ', req)

req_w = strsplit(test_df$req, ' +')
req_w = lapply(req_w, lapply, function(x) paste0(' ', x))
req_w = lapply(req_w, unlist)

f_money = unlist(lapply(req_w, calc_freq, money))
f_job = unlist(lapply(req_w, calc_freq, job))
f_student = unlist(lapply(req_w, calc_freq, student))
f_family = unlist(lapply(req_w, calc_freq, family))
f_craving = unlist(lapply(req_w, calc_freq, craving))

load(file = 'quantiles.RData')
test_df$d_money = findInterval(f_money, quantiles$q_money)
test_df$d_job = findInterval(f_job, quantiles$q_job)
test_df$d_student = findInterval(f_student, quantiles$q_student)
test_df$d_family = findInterval(f_family, quantiles$q_family)
test_df$d_craving = findInterval(f_craving, quantiles$q_craving)

#create temporal features
test_df$req_dt = as.Date(as.numeric(test_df$unix_timestamp_of_request_utc) / (3600*24), origin = '1970-01-01')
summary(test_df$req_dt) #2011-04-08 - 2013-10-12

comm_age = test_df$req_dt - as.Date('2010-12-08')
test_df$d_comm_age = findInterval(comm_age, quantiles$q_comm_age)
test_df$month_h1 = as.factor(day(test_df$req_dt) <= 15)

#create gratitude
gratitude = lapply(test_df$req, function(x) as.factor(length(grep('thank|appreciate|advance', x)) > 0))
test_df$gratitude = unlist(gratitude)

#create indicator for including hyperlinks
hyperlink = lapply(test_df$req, function(x) as.factor(length(grep('http', x)) > 0))
test_df$hyperlink = unlist(hyperlink)

#create reciprocity
reciprocity = lapply(test_df$req, function(x) as.factor(length(grep('pay.+forward|pay.+back|return.+favor|repay', x)) > 0))
test_df$reciprocity = unlist(reciprocity)

#create sentiment
sentiment = lapply(test_df$req, function(x) polarity(x)[[1]]$polarity)
sentiment_v = unlist(sentiment)
sentiment_pm = median(sentiment_v[sentiment_v > 0])
sentiment_nm = median(sentiment_v[sentiment_v < 0])
test_df$sentiment_p = as.factor(sentiment_v > sentiment_pm)
test_df$sentiment_n = as.factor(sentiment_v < sentiment_nm)

#create request length
req_len = lapply(test_df$req, function(x) nchar(x) / 100)
test_df$req_len = unlist(req_len)

#create karma decile
karma_raw = as.numeric(test_df$requester_upvotes_minus_downvotes_at_request)
test_df$d_karma = findInterval(karma_raw, quantiles$q_karma)

#create indicator for requestors who have posted on raop before (last one!)
test_df$posted_before = as.factor(as.numeric(test_df$requester_number_of_posts_on_raop_at_request) > 0)

test_m = subset(test_df, 
                 select = c(d_comm_age, month_h1, gratitude, hyperlink,
                            reciprocity, sentiment_p, sentiment_n,
                            req_len, d_karma, posted_before,
                            d_craving, d_family, d_job, d_money, d_student))
test_md = test_m
test_md$month_h1 = as.numeric(test_md$month_h1) - 1
test_md$gratitude = as.numeric(test_md$gratitude) - 1
test_md$hyperlink = as.numeric(test_md$hyperlink) - 1
test_md$reciprocity = as.numeric(test_md$reciprocity) - 1
test_md$sentiment_p = as.numeric(test_md$sentiment_p) - 1
test_md$sentiment_n = as.numeric(test_md$sentiment_n) - 1
test_md$posted_before = as.numeric(test_md$posted_before) - 1
save(test_df, file = 'test.RData')
save(test_m, file = 'test_m.RData')
save(test_md, file = 'test_md.RData')

#now predict!
logit_p = predict(logit_m, test_m, type = 'prob')
rf_p = predict(rf_m, test_m, type = 'prob')
gbm_p = predict(gbm_m, test_m, type = 'prob')
nnet_p = predict(nnet_m, test_md, type = 'prob')

#combine results
requester_received_pizza = (logit_p$success + rf_p$success + gbm_p$success + nnet_p$success) / 4
submit = data.frame(cbind(test_df$request_id, requester_received_pizza))
names(submit)[1] = 'request_id'
write.csv(submit, file = 'submit.csv', row.names = F)
