#Technology Fundamentals for Analytics 2014 
##(MGMT-6963-01)

##Lab 3: Data Understanding and Data Preparation 


##Background
Data preparation, data munging, and other things related to preparing data could be a class to itself.  
Here we will go over some of the basis regarding relevant data funtions in R.

One of the relevant things to know is how to get help!  

```{r}
? cbind
help(cbind)
```

## Vector
A single set of values in a particular order.

We can create a vector using the concatenate command (c). Let's say we want to capture the ages for 4 students.

```{r}
ages<-c(18,19,18,23)
```

To see  this we can just type the name of object:
```{r}
ages
```

To pick a specific value, we can, indicate it.
```{r}
ages[4]
```

Or a range
```{r}
ages[2:4]
```

###Other Vectors
```{r}
names<-c("Sally", "Jason", "Bob", "Susy") #Text
female<-c(TRUE, FALSE, FALSE, TRUE)
grades<-c(20, 15, 13, 19) #25 points possible
```

###We can apply funtions to Vectors
```{r}
names.length<-nchar(names) #Calc number of letters and return vector
names.length #Prints integer vector vector 
```

###You can also include logic
```{r}
names.length.gt4<-nchar(names) > 4
names.length.gt4 #1.what type of vector is returned? Describe the function.
```

###Or
```{r}
names.length.gt4b<-names.length > 4
names.length.gt4b #2.what type of vector is returned? Describe the function.
```

#look at select we can do when combining vectors
names[female] #3. what type of vector is returned and what content?
names[names.length.gt4] #4.what type of vector is returned and what content?

#We can also do math on the entire vector at once
#our grades were out of 25, lets curve 3 points.
curve<-grades+3

#Now we can calculate a percentage
percent<-grades*(100/25)  #same as * 4
percent

#We can also take the log
logpercent<-log(percent)

#Create a matix by combining vectors 
mat<-cbind(ages, grades)
mat #show entire matrix

#Matrices can be specified by mat[row,column]
mat[2,1] #Row=2, Column=1
mat[1,]  #Row=1 and all columns 
mat[,1]  #Column=1, all rows

#Now let's combine data of different types
#5. A matrix has to be of the same type.  View the matrix below. Do you potentially see issues with forcing all data to be of type string?
mat2<-cbind(names, ages, grades)
mat2

#A data frame is a more flexible format and one
#we will use for the majority of our analyses.
df1<-data.frame(cbind(names,ages,grades))
df1<-data.frame(cbind(names,ages,grades))


#In reality most of the time we will be working with 
#files (but can also use file browser)
getwd()
setwd("/home/analytics/MGMT6963/labs/data")
list.files()
#(if this doesn't show "batting.csv" 
#you set the wrong working directory)

#We don't have to specify the full path here
#This is the baseball batting data
batting1=read.csv(file="batting.csv", header=TRUE,sep=",")
teams1=read.csv(file="teams.csv", header=TRUE,sep=",")

batting=read.csv(file="batting.csv", header=TRUE,sep=",", na.strings = "NULL")
teams=read.csv(file="teams.csv", header=TRUE,sep=",", na.strings = "NULL")

#6. Review the data from the the two commands above. See the structure of each using the following.  Describe how the data for batting and batting1 is being processed differently and why it matters. 
str(batting)
str(batting1)

#Now let's view the data. This type of data is called a Data Frame. 
View(teams) #show data browser
names(teams) #show the names
dim(teams) #show the dimensions of the data frame
head(teams, 2) #show the first 2 records
tail(teams, 4) #show the final 2 records
teams$yearID #show the years in the data frame
summary(teams) #summarize all variables
str(teams) #shows the structure of an R Object

#7 Use some of the commands above on the badding data.  How might you understand the structure. Provide a list of at least 5 things that you find out. 

#Notice the differences, factors, integers, numeric
#League ID (just note that this is a factor object)
#This is the type of object that incorporates different "levels"
#and can be translated into "dummy variables" quite easily
teams$lgID  #show the variable and levels

#recode it as a character
as.character(teams$lgID) #translate factor to string and print results
teams$lgIDS<-as.character(teams$lgID) #factor->string->new dataframe field
#Notice the factor levels correspond to different numbers.
cbind(teams$lgID, teams$lgIDS)

#Sometimes you may have to translate string to a factor.
str(teams$lgIDS) #this indicates the variable is a charcacter
teams$lgIDS<-as.factor(teams$lgIDS)

#You might have to treat integers as numeric.
str(teams$W)
teams$W<-as.numeric(teams$W)
str(teams$W)

#Let's change it back.
teams$W<-as.integer(teams$W)
str(teams$W)

#Now let's do a date conversion. 
#YearID is set so that there is only a year, but dates need day month.
datez <- paste("01","01", teams$yearID, sep = "/")

#Two different functions to change date
as.Date(datez, "%m/%d/%y")

#8 Look at the help (?strptime) to see why a capital Y should be used.


#This is a more flexible datetime See
#http://www.stat.berkeley.edu/classes/s133/dates.html 
strptime(datez,"%m/%d/%Y")

#Now let's add to the dataframe
teams$date<-as.Date(datez, "%m/%d/%y")
teams$datetime<-strptime(datez,"%m/%d/%Y")
str(teams$date) #View the Structure
str(teams$datetime) #View the Structure

#9 Provide a description of how you add a vector to a data frame.

#We can also do some basic statistics
mean(teams$W) #This prints the mean wins across entire data frame
sd(teams$W) #The standard deviation

#10 What does it mean for a variable to have a larger standard deviation?


#We want to subset the data, as the game has changed
#over time, so we will drop everything before 1980
#This is performing the same function of where clause.
batting.1980<-subset(batting, yearID > 1980)
teams.1980<-subset(teams, yearID > 1980)

#11 Why might you subset data to only some particluar times to do 


#We could also just select out those variables we are actually 
#interested in
teams.1980.small<-subset(teams, yearID > 1980, 
                         select = c("yearID","teamID","W","L"))
View(teams.1980.small)

#Now let's create a different variable from another variable. First
#let's get the average number of wins.  
mean.W<-mean(teams.1980$W)
mean.W

#Let's call teams who wone more that average a "winner" while 
#those less than the mean "loser."
condition <-  teams.1980$W>mean.W
teams.1980$Season=ifelse(condition, "winner", "loser")

#We can also generate a boolean variable right from the 
#condition
condition  #This will print the values
teams.1980$Winsea<-condition    

#We can also do some processes with for loops.
#(Thought there is a saying that if you are using
#for loops in R, you are doing something wrong)
#Here we are going to go iterate through the data frame 
N<-nrow(teams.1980)
for(i in 1:N){
  if (teams.1980$W[i]>mean.W) {
    teams.1980$Seasonb[i]="winner"
  } else {
    teams.1980$Seasonb[i]="loser"
  }
}

#Lists can be useful.  Again, these are similar to JSON objects.  
#Here we will take statistics on each team using summary and 
#but the results into a list.  
teams.names=unique(teams.1980.small$teamID)
teams.summary<-list()
for (t in teams.names){
  these <-teams.1980.small$teamID == t
  teams.summary[[t]]<-summary(teams.1980.small[these,])
}

#This retrieves the statistics for certain teams
teams$BAL
teams$ARI


#aggregating by group.  Here this sums across wins.
teams.1980.W<-tapply(teams.1980$W,teams.1980$teamID, sum)

#In our SQL Statement, we had calcualted these.  
#H/AB AS AVG, 
#(H+BB+HBP)/(AB+BB+HBP+SF) AS OBP
#(H+2B+2*3B+3*HR)/AB AS SLG
batting$AVG<-(batting$H/batting$AB)

#This works, but we don't want to always have to repeat the dataframe 
batting$AVGb<-with(batting, H/AB)

#We can check that we got the same answer.
batting$AVGb==batting$AVG

# WE could calculate each this way
batting$AVGb<-with(batting, H/AB)
batting$OBP<-with(batting, (H+BB+HBP)/(AB+BB+HBP+SF))
batting$SLG<-with(batting, (H+B2+2*B3+3*HR)/AB)

#Here we can use within to find a number of different variables
batting2 <- within(batting, {
                  AVG<-(H/AB)
                  OBP<-(H+BB+HBP)/(AB+BB+HBP+SF)
                  SLG<-(H+B2+2*B3+3*HR)/AB
                  })

#Sometimes it is necessary to go through the process
#Of dropping NA records. First let us subselect some of the batting data 
batting.1980.small<-subset(batting2, yearID > 1980, 
                  select = c("playerID","yearID", "teamID","AVG","OBP","SLG"))
View(batting.1980.small)

#These are 2 different ways of eliminating our cases with NA. 
batting.1980.smallna<- na.omit(batting.1980.small)
batting.1980.smallnab <- airquality[complete.cases(batting.1980.small), ]

#Aggregate
#Summary of data 
names(teams.1980.small)

#This is the aggregation of data for W and L
aggdatac <-aggregate(teams.1980.small[,3:4], 
                     by=list(teams.1980.small$yearID), FUN=mean, na.rm=TRUE)
aggdatad <-aggregate(teams.1980.small[,3:4], 
                     by=list(teams.1980.small$teamID), FUN=mean, na.rm=TRUE)

#Plyr is a commonly used package that automates the split, apply, combine model
#
install.packages("plyr")
library(plyr)
#ddply takes care of a number of summarizing 
ddply(teams.1980.small, .(teamID), summarize,
                                   N  = length(W), #Gives records (rows)
                               mean_W = mean(W),   #Gives average
                               std_W  = sd(W),     #Gives standard deviation
                               mean_L = mean(L),  
                               std_L   = sd(L))    
View(teams.1980.small)
colnames(aggdata) <- c("yearID", "Wmean", "Lmean")
#Check it out you can see the there was a strike in 1981. 
aggdata2 <-aggregate(teams[,9:10], by=list(teams$yearID), FUN=sum, na.rm=TRUE)
colnames(aggdata2) <- c("yearID","Wsum", "Lsum")
View(aggdata)
View(aggdata2)

#Natural join: (only data from both tables)
aggdata3<-merge(x = aggdata, y = aggdata2, by = "yearID")
View(aggdata3)
#Full Outer join: 
aggdata4<-merge(x = aggdata, y = aggdata2, by = "yearID", all = TRUE)
View(aggdata4)
#Left outer: 
aggdata5<-merge(x = aggdata, y = aggdata2, by = "yearID", all.x = TRUE)
View(aggdata5)
#Right outer: 
aggdata5<-merge(x = aggdata, y = aggdata2, by = "yearID", all.x = TRUE)
View(aggdata6)

#Now let's look at our first Correlations.

batting.sm<-subset(batting, yearID > 1980, select = c("AB","HR", "AVGb", "OBP", "SLG"))

#Correlations
cor(batting.sm, use="pairwise.complete.obs", method="pearson")
cor(batting.sm, use="complete.obs", method="pearson")

#Functions
testfunction <- function(x) {
    m  <- mean(x)
    return(m)
}
#test function which returns the mean
testfunction (teams$W)
#This yields the same value
mean(teams$W)

#This is our First function, one that can create correlations.
flattenSquareMatrix <- function(m) {
  if( (class(m) != "matrix") | (nrow(m) != ncol(m))) stop("Must be a square matrix.") 
  if(!identical(rownames(m), colnames(m))) stop("Row and column names must be equal.")
  ut <- upper.tri(m)
  data.frame(i = rownames(m)[row(m)[ut]],
             j = rownames(m)[col(m)[ut]],
             cor=t(m)[ut],
             p=m[ut])
}
cor.prob <- function (X, dfr = nrow(X) - 2) {
  R <- cor(X, use="pairwise.complete.obs")
  above <- row(R) < col(R)
  r2 <- R[above]^2
  Fstat <- r2 * dfr/(1 - r2)
  R[above] <- 1 - pf(Fstat, 1, dfr)
  R[row(R) == col(R)] <- NA
  R
}

#here is a package that can provide some more detailed visuals.
install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)
chart.Correlation(batting.sm)








