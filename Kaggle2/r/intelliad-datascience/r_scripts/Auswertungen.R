# Adjust part and call this upfront to set your working directory
# setwd("Y:\\Analysis\\Random-Acts-of-Pizza")


traindata<-read.csv2("raw_data/train.csv",header=TRUE,dec=".")


str(traindata)
dim(traindata)
names(traindata)

# Zusammenfassung
# (1) Es gibt insgesamt 4040 Beobachtungen und 32 Variablen
# (2) Es gibt viele Text-Variablen (die wir in ersten Schritt noch nicht analysieren können)
# (3) Einige Angaben beziehen sich auf zwei Zeitpunkte (user activity?)

#-------------------------
# Logische Variablen
#-------------------------

# (1) post_was_edited
table(traindata$post_was_edited)
# Was bedeuten hier die Zahlen? Es m?ssen logische Werte sein!
# Da wir keine ERkl?rung daf?r gefunden haben, haben wir uns entschieden
# diese Werte als NA zu markieren.
traindata$post_was_edited1<-as.logical(traindata$post_was_edited)

# (2) requester_recieived_pizza
 table(traindata$requester_received_pizza)
#false  true 
#3046   994 
# hier alles in Ordnung

#--------------------------
# Kategoriale Variablen
#--------------------------

# (3) requester_user_flair
table(traindata$requester_user_flair)
#          PIF shroom 
# 3046     59    935 
str(traindata$requester_user_flair)
traindata$requester_user_flair1<-traindata$requester_user_flair
levels(traindata$requester_user_flair1)
levels(traindata$requester_user_flair1)[1]<-"None"
table(traindata$requester_user_flair1)

# (4) requester_username
range(table(traindata$requester_username))
# das sind unique values -> kann man l?schen. diese variable ist nicht informativ!

# (5) giver_username
summary(traindata$giver_username)
# Summary: ed gibt sehr viele NAs, ABER wenn nan diese ERgebnisse mit den H?ufigkeiten von
#oben vergleicht, stellt sich heraus, dass die Mehrheit von "giver" anonym waren!
# Kann man mit dieser Variable ?berhaupt etwas anfangen?
# Ist die genug informativ?
traindata$giver_username1<-as.character(traindata$giver_username)
table(traindata$giver_username1)

traindata$giver_username1[traindata$giver_username1=="N/A"]<-NA
sum(is.na(traindata$giver_username1))
# super!!!

str(traindata$giver_username1)
range(table(traindata$giver_username1))
# minimum=1, maximum=5
barplot(table(traindata$giver_username1))


#-----------------------------------------------
# Stetige Variablen
#----------------------------------------------

summary(traindata$requester_account_age_in_days_at_request)
summary(traindata$requester_account_age_in_days_at_retrieval)
summary(traindata$requester_days_since_first_post_on_raop_at_request)
summary(traindata$requester_days_since_first_post_on_raop_at_retrieval)

#> summary(traindata$requester_account_age_in_days_at_request)
#Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#0.000    3.473  157.100  254.600  390.100 2810.000 
#> summary(traindata$requester_account_age_in_days_at_retrieval)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#45.29  522.20  753.30  757.70  900.30 2879.00 
#> summary(traindata$requester_days_since_first_post_on_raop_at_request)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00    0.00    0.00   16.42    0.00  785.50 
#> summary(traindata$requester_days_since_first_post_on_raop_at_retrieval)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.0   279.0   528.8   519.0   776.2  1025.0


par(mfrow=c(2,2))
hist(traindata$requester_account_age_in_days_at_request,main="requester_account_age_in_days_at_request")
hist(traindata$requester_account_age_in_days_at_retrieval,main="requester_account_age_in_days_at_retrieval")
hist(traindata$requester_days_since_first_post_on_raop_at_request,main="requester_days_since_first_post_on_raop_at_request")
hist(traindata$requester_days_since_first_post_on_raop_at_retrieval,main="requester_days_since_first_post_on_raop_at_retrieval")

#
# add additional features
#
# source("feature_generation.R")
traindata <- addTimeFeatures(traindata)
traindata <- addUserActivityScoreFeatures(traindata)


#-----------------------------------------------
# Zaehlvarialen Variablen
#----------------------------------------------

# Anzahl von Upvotes und Downvotes


summary(traindata$number_of_downvotes_of_request_at_retrieval)
summary(traindata$number_of_upvotes_of_request_at_retrieval)

par(mfrow=c(1,2))
plot(traindata$number_of_downvotes_of_request_at_retrieval,pch=".")
plot(traindata$number_of_upvotes_of_request_at_retrieval,pch=".")




# Variable subreddits ist ein String. Idee: z?hle die Anzahl von unterschiedlichen
# subreddits, wo ein User aktiv war.

subreddits<-c()
for (i in 1:length(traindata$requester_subreddits_at_request)){
  subreddits[i]<-length(strsplit(split=",", x=as.character(traindata$requester_subreddits_at_request)[i])[[1]])
}

traindata$requester_subreddits_at_request1<-subreddits

#bla<-length(strsplit(split=",", x=as.character(traindata$requester_subreddits_at_request)[4])[[1]])

