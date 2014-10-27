library(plyr)
library(data.table)
library(ggplot2)
library(lubridate)
library(qdap)
library(gridExtra)

#create narrative buckets
load(file = 'train.RData')

#keywords from different buckets (add an extra white space in front when necessary to prevent incorrect matching)
money = ' money| now| broke| week| until| time| last|day| when| paid| next| first|night| after| tomorrow| month| while| account| before| long| rent| buy| bank| still| bill| ago| cash| due| soon| past| never|check| spent| year| poor| till| morning| dollar| financial| hour| evening| credit| budget| loan| buck| deposit| current| pay'
job = ' work| job|check|employ| interview| fire| hire'
student = ' college| student| school| roommate| study| university| final| semester| class| project| dorm| tuition'
family = ' family| mom| wife| parent| mother| husband| dad| son| daughter| father| mum'
craving = ' friend| girlfriend| crave| craving| birthday| boyfriend| celebrat| party| parties| game| movie| film| date| drunk| beer| invite| drink| waste'

#caclulate the % frequency for each request (incl. title)
req_w = strsplit(train$req, ' +')

#pad an extra white space in front of each word
req_w = lapply(req_w, lapply, function(x) paste0(' ', x))
req_w = lapply(req_w, unlist)

calc_freq = function(x, bucket) {
  m = length(grep(bucket, x))
  return(m / length(x))
}

f_money = unlist(lapply(req_w, calc_freq, money))
f_job = unlist(lapply(req_w, calc_freq, job))
f_student = unlist(lapply(req_w, calc_freq, student))
f_family = unlist(lapply(req_w, calc_freq, family))
f_craving = unlist(lapply(req_w, calc_freq, craving))

#calculate deciles (0 frequencies are represented as 0 decile)
q_money = quantile(f_money[f_money > 0], seq(0, .9, .1))
q_job = quantile(f_job[f_job > 0], seq(0, .9, .1))
q_student = quantile(f_student[f_student > 0], seq(0, .9, .1))
q_family = quantile(f_family[f_family > 0], seq(0, .9, .1))
q_craving = quantile(f_craving[f_craving > 0], seq(0, .9, .1))

train_df$d_money = findInterval(f_money, q_money)
train_df$d_job = findInterval(f_job, q_job)
train_df$d_student = findInterval(f_student, q_student)
train_df$d_family = findInterval(f_family, q_family)
train_df$d_craving = findInterval(f_craving, q_craving)

#explore the relationship between deciles and outcome
train_df$requester_received_pizza = as.factor(train_df$requester_received_pizza)
s_money = data.frame(cbind('money', ddply(train_df, .(d_money), summarize, sr = sum(requester_received_pizza == T) / length(requester_received_pizza))))
s_job = data.frame(cbind('job', ddply(train_df, .(d_job), summarize, sr = sum(requester_received_pizza == T) / length(requester_received_pizza))))
s_student = data.frame(cbind('student', ddply(train_df, .(d_student), summarize, sr = sum(requester_received_pizza == T) / length(requester_received_pizza))))
s_family = data.frame(cbind('family', ddply(train_df, .(d_family), summarize, sr = sum(requester_received_pizza == T) / length(requester_received_pizza))))
s_craving = data.frame(cbind('craving', ddply(train_df, .(d_craving), summarize, sr = sum(requester_received_pizza == T) / length(requester_received_pizza))))

s_narrative = rbindlist(list(s_money, s_job, s_student, s_family, s_craving))
names(s_narrative) = c('narrative', 'decile', 'success_rate')
pn = 
  ggplot(s_narrative, aes(x = decile, y = success_rate, colour = narrative, group = narrative)) +
  geom_line() + ggtitle('Success rate vs. narrative') +
  scale_x_continuous(breaks = seq(0, 10, 1), name = 'Narrative declie') +
  scale_y_continuous(name = 'Success rate')
ggsave(pn, file = 'narrative.jpg')

#create temporal features
train_df$req_dt = as.Date(as.numeric(train_df$unix_timestamp_of_request_utc) / (3600*24), origin = '1970-01-01')
summary(train_df$req_dt) #2011-02-14 - 2013-10-11

comm_age = train_df$req_dt - as.Date('2010-12-08')
q_comm_age = quantile(comm_age, seq(0, .9, .1))
train_df$d_comm_age = findInterval(comm_age, q_comm_age)
train_df$month_h1 = as.factor(day(train_df$req_dt) <= 15)

s_comm_age = ddply(train_df, .(d_comm_age), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
s_month = ddply(train_df, .(month_h1), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
pa = 
  ggplot(s_comm_age, aes(x = d_comm_age, y = success_rate)) + geom_line(colour = '#e7298a') + 
  ggtitle('Success rate vs. community age') +
  scale_x_continuous(breaks = seq(0, 10, 1), name = 'Community age declie') +
  scale_y_continuous(name = 'Success rate')
pm = 
  ggplot(s_month, aes(x = month_h1, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#6baed6') + 
  ggtitle('Success rate vs. the time in month') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('First half', 'Second half'), name = 'Time in month') +
  scale_y_continuous(name = 'Success rate')

#create gratitude
gratitude = lapply(train_df$req, function(x) as.factor(length(grep('thank|appreciate|advance', x)) > 0))
train_df$gratitude = unlist(gratitude)

s_grat = ddply(train_df, .(gratitude), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
pg = 
  ggplot(s_grat, aes(x = gratitude, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#74c476') + 
  ggtitle('Success rate vs. gratitude') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Gratitude expressed', 'Gratitude not expressed'), name = 'Gratitude') +
  scale_y_continuous(name = 'Success rate')

#create indicator for including hyperlinks
hyperlink = lapply(train_df$req, function(x) as.factor(length(grep('http', x)) > 0))
train_df$hyperlink = unlist(hyperlink)

s_hl = ddply(train_df, .(hyperlink), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
ph = 
  ggplot(s_hl, aes(x = hyperlink, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#fed976') + 
  ggtitle('Success rate vs. the inclusion of hyperlinks') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Hyperlink included', 'Hyperlink not included'), name = 'Hyperlink') +
  scale_y_continuous(name = 'Success rate')

#create reciprocity
reciprocity = lapply(train_df$req, function(x) as.factor(length(grep('pay.+forward|pay.+back|return.+favor|repay', x)) > 0))
train_df$reciprocity = unlist(reciprocity)

s_r = ddply(train_df, .(reciprocity), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
pr = 
  ggplot(s_r, aes(x = reciprocity, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#9e9ac8') + 
  ggtitle('Success rate vs. reciprocity') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Reciprocity expressed', 'Reciprocity not expressed'), name = 'Reciprocity') +
  scale_y_continuous(name = 'Success rate')

#create sentiment
sentiment = lapply(train_df$req, function(x) polarity(x)[[1]]$polarity)
sentiment_v = unlist(sentiment)
sentiment_pm = median(sentiment_v[sentiment_v > 0])
sentiment_nm = median(sentiment_v[sentiment_v < 0])
train_df$sentiment_p = as.factor(sentiment_v > sentiment_pm)
train_df$sentiment_n = as.factor(sentiment_v < sentiment_nm)

s_sp = ddply(train_df, .(sentiment_p), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
s_sn = ddply(train_df, .(sentiment_n), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
psp = 
  ggplot(s_sp, aes(x = sentiment_p, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#1d91c0') + 
  ggtitle('Success rate vs. strong positive sentiment') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Expressed', 'Not expressed'), name = 'Strong positive sentiment') +
  scale_y_continuous(name = 'Success rate')
psn = 
  ggplot(s_sn, aes(x = sentiment_n, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#1d91c0') + 
  ggtitle('Success rate vs. strong negative sentiment') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Expressed', 'Not expressed'), name = 'Strong negative sentiment') +
  scale_y_continuous(name = 'Success rate')

#create request length
req_len = lapply(train_df$req, function(x) nchar(x) / 100)
train_df$req_len = unlist(req_len)
pl =
  ggplot(train_df, aes(x = requester_received_pizza, y = req_len)) +
  geom_boxplot(fill = '#ffffcc') +
  ggtitle('Success rate vs. request length') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Success', 'Fail'), name = 'Request outcome') +
  scale_y_continuous(name = 'Requent length (in 100 words)')

#create karma decile
karma_raw = as.numeric(train_df$requester_upvotes_minus_downvotes_at_request)
q_karma = quantile(karma_raw, seq(0, .9, .1))
train_df$d_karma = findInterval(karma_raw, q_karma)

s_k = ddply(train_df, .(d_karma), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
pk = 
  ggplot(s_k, aes(x = d_karma, y = success_rate)) + geom_line(colour = '#08519c') + 
  ggtitle('Success rate vs. karma') +
  scale_x_continuous(breaks = seq(0, 10, 1), name = 'Karma declie') +
  scale_y_continuous(name = 'Success rate')

#create indicator for requestors who have posted on raop before (last one!)
train_df$posted_before = as.factor(as.numeric(train_df$requester_number_of_posts_on_raop_at_request) > 0)
s_pb = ddply(train_df, .(posted_before), summarize, success_rate = sum(requester_received_pizza == T) / length(requester_received_pizza))
ppb = 
  ggplot(s_pb, aes(x = posted_before, y = success_rate)) + 
  geom_bar(stat = 'identity', fill = '#41b6c4') + 
  ggtitle('Success rate vs. historical posts on ROAP') +
  scale_x_discrete(limits = c('TRUE', 'FALSE'), labels = c('Posted before', 'Never posted before'), name = 'Whether the requester has posted on ROAP before') +
  scale_y_continuous(name = 'Success rate')

#combine all plots
grid.arrange(pa, pm, pg, ph, pr, psp, psn, pl, pk, ppb, ncol = 2)

#clean up for modeling
train_m = subset(train_df, 
                 select = c(d_comm_age, month_h1, gratitude, hyperlink,
                            reciprocity, sentiment_p, sentiment_n,
                            req_len, d_karma, posted_before,
                            d_craving, d_family, d_job, d_money, d_student,
                            requester_received_pizza))
save(train_df, file = 'train.RData')
save(train_m, file = 'train_m.RData')

#save quantiles for prediction
quantiles = data.frame(do.call(cbind, list(q_comm_age, q_craving, q_family, q_job, q_karma, q_money, q_student)))
names(quantiles) = c('q_comm_age', 'q_craving', 'q_family', 'q_job', 'q_karma', 'q_money', 'q_student')
save(quantiles, file = 'quantiles.RData')
