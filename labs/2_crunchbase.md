#Technology Fundamentals for Analytics 2014 
##(MGMT-6963-01)

##Lab 2: APIs and Online Data

###Background knowledge: 

###What is an API?
You may have read the REST API (Wikipedia), which we provided in syllabus, and you may come up to more detailed questions about the API. Here is an excellent miniature tutorial course on everything you need to know. https://zapier.com/learn/apis/  (Today we only cover chapter 1 to chapter 5)
Before continuing, it is worth  spending 20 minutes to check above link. The knowledge will allow you to understand how to work with many other data sources, not only CrunchBase, but also Twitter, Facebook, and so on. Additionally, make sure that you try all homework of 5 chapters on zapier.com.
Please answer the following questions, which can help you to examine whether you get the major idea of API.

*Question 1: Please use your words to give concepts of the API, the server, and the client.*


*Question 2: Please write down the methods we commonly use in APIs. What method will be most relevant for obtaining data?*


We need to be able to understand how to get data from just about every and munge it to a form that we can then do math on it.  In this lab, you will get some hands on experience with just that. 

##[Data.gov](https://www.data.gov/education/education-developers)
Look at this series of datasets from DATA.gov

[http://www.data.gov/education/page/education-developers](http://www.data.gov/education/page/education-developers)

This data has been posted in .CSV, JSON, XML, and via and API.  Sometimes we won’t have so many options from which to analyze the data, but this is a good opportunity to understand what the same data looks like in multiple forms. 

##[Socrata](http://www.socrata.com/)
Socrata API are sets of REST resources you can use to manage Socrata entities and data. Resources are grouped by areas of related high-level functionality. 
Open up the data from Socrata. 

They have a demonstration site that shows a number of ways to use their platform:
[https://soda.demo.socrata.com/](https://soda.demo.socrata.com/)

Notice how the API can be called in different ways.  Load this earthquake data:

EARTHQUAKES

CSV
[https://soda.demo.socrata.com/resource/earthquakes.csv](https://soda.demo.socrata.com/resource/earthquakes.csv)

JSON
[https://soda.demo.socrata.com/resource/earthquakes.json](https://soda.demo.socrata.com/resource/earthquakes.json)

XML
[https://soda.demo.socrata.com/resource/earthquakes.xml](https://soda.demo.socrata.com/resource/earthquakes.xml)


There is also the opportunity to select from the API as if it was a database. Read the details of SOQL here:
[http://dev.socrata.com/docs/queries](http://dev.socrata.com/docs/queries) 

This will pull earthquates from a specific time range
[https://soda.demo.socrata.com/resource/earthquakes.json?%24order=datetime%20DESC&%24limit=5](https://soda.demo.socrata.com/resource/earthquakes.json?%24order=datetime%20DESC&%24limit=5)

[https://soda.demo.socrata.com/resource/earthquakes.json?region=Washington](https://soda.demo.socrata.com/resource/earthquakes.json?region=Washington)
 
  
*Question 3. Indicate the appropriate URL for identifying earthquakes in which the magnitude is 3.0 and the source = pr.*

*Question 4.	Use the same query but download a .csv file.* 
  

##R/APIS AND MORE 

This is a bit of RCode that you should run in RSTUDIO.  Run each bit of code, line by line and observing what occurs.

The first step is to download data as a .csv file.
[https://opendata.socrata.com/Fun/Criterions-on-Netflix/sfnr-xcnq](https://opendata.socrata.com/Fun/Criterions-on-Netflix/sfnr-xcnq) 

Click on export -> CSV. This will save the file. 


```{r}
#Set the working directory to where you placed it.  
setwd("~/Downloads")
Data_Netflix=read.csv(file="Criterions_on_Netflix.csv",header=TRUE,sep=",")
 

#However, it may be easier, where possible, to just pull a .csv.
earthquakes2=read.csv(file="http://soda.demo.socrata.com/resource/4tka-6guv.csv",header=TRUE,sep=",")

#Other times it may be necessary to pull data from a JSON object into a data frame.  
install.packages("plyr")
install.packages("RJSONIO")
install.packages("stringr")
library(stringr)
library(plyr)
library(RJSONIO)
#This sets the appropriate file name.
earthquakejsonfile<-"http://soda.demo.socrata.com/resource/4tka-6guv.json"
#This imports the JSON object into a list.
earthquatelist<-fromJSON(earthquakejsonfile)
#This uses the plyr library to change the list to a data frame.  
earthquatedataframe <- ldply(earthquatelist, data.frame)

#Now you can simply save as load the file, storing it as an RDATA file.
save(earthquatedataframe, file ="earthquatedataframe.RData")
load("earthquatedataframe.RData")

```

*Question 5.	Find an API to work with that returns data in a .JSON format or a data archive available in the .JSON format.*  

*Question 6.	Provide the URL for the Dataset.*

*Question 7.	Provide an extended summary of the data provided as well as how the data might be useful.*

*Question 8.	Provide the R Code necessary to obtain the data, load it into R, and change the JSON list to a data frame.*   


#Crunchbase
### Crunchbase Dataset [http://www.crunchbase.com/](http://www.crunchbase.com/)
CrunchBase is operated by TechCrunch Company. Wikipedia concludes Crunchbase as “a database of companies and start-ups, which comprises around 500,000 data points profiling companies, people, funds, fundings and events.”  Today, we focus on this database and try to fetch some interesting data from there by using their API (Application programming interface) from R. Before we proceed to the next step, please make sure that you have registered an account and logged in Crunchbase.


###3.	Using the CrunchBase API
Now we need to go  https://developer.crunchbase.com/  to build your API applications. First, we will need to sign up for a user key. Please fill out the registration form and find your new user key in your email inbox. Next, click "API credentials" and make sure that you get the user key as following and then we can move next step.
 
###Manual Entry and API
Actually, the CrunchBase API is exceedingly simple. You will find out that the documentation is only one page, https://developer.crunchbase.com/docs, and basically there is only one type of requests, GET, that we need to deal with. Let us see what we can get from GET requests.

*"GET" companies data*
Try a few requests by yourself in the explorer. You can figure out there are several ways to get one company's data. Let us target the following company:
http://www.crunchbase.com/organization/dropbox


*Question 9: Please try to use query, name and domain_name (three different GET requests) to get the information from the above company. Post the commands that you put in different GET requests and compare the results.*


*Question 10: We still focus on finding the information of the above company. What do you get as a result if you use the ‘name’ request and choose the organization_types as 'investor'? Can you get the information of the targeted company? Why?*
 

*Question 6:  Find the right request and fetch the data of each board member and advisor of the above company. Briefly describe the procedure. Post the result.*


###When R meets API
Open Rstudio. Now we need to run a few R codes line by line to fetch data. 


```{r}

#1. Set the working directory to where you want to place it.  
setwd("~/Downloads")

#2. Clean up
rm(list=ls())

# install the packages which will be used by the code
#install.packages(“RJSONIO”) We already installed.
install.packages('RCurl')
library(RJSONIO)
library(RCurl)

# put your user key
user_key = "2353edc9a09774dd8a498d6d35cfb544"

# set up url
url = "http://api.crunchbase.com:80/v/2/"

# fetch the data
company <- fromJSON(paste(url,"organizations?organization_types=company&user_key=",user_key,"&page=1",sep=""))
investor<- fromJSON(paste(url,"organizations?organization_types=investor&user_key=",user_key,"&page=1",sep=""))
people<- fromJSON(paste(url,"people?&user_key=",user_key,"&page=1","&order=created_at+DESC", sep=""))

# read the data. Make sure you observe the result of each code.
str(company$data)
str(investor$data$items)
print(company$data$items[4])
print(investor$data$items[4])
print(people$data$items[4])


```

*Question 7: What do you get when you run the last three "print" commands (investor, company and people)? What do these three lists of name represent?*

*Question 8: What do you get if you change page from 1 to 2 in the code:
`investor<- fromJSON(paste(url,"organizations?organization_types=investor&user_key=",user_key,"&page=1",sep=""))`  Can you tell the difference between the results of page 1 and page 2?*


*Question 9: Post the result of str( company$data) and str(investor$data$items). Do you know how many “investor” we can collect? Briefly explain each result.*


*Question 10: According to the online API documentation, change parts of the code for collecting the people data while chaning the sort order. Post the changes and results.*

##CHALLENGE PROBLEM
Select an API in finance and provide R code to retreive monthly stock data for 3 companies over the last year.
(You migt find this useful).
http://stats.stackexchange.com/questions/12670/data-apis-feeds-available-as-packages-in-r 



