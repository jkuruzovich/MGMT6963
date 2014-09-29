#**Technology Fundamentals for Analytics Lab**
##Jason Kuruzovich
---


#Agenda
1. Review Last time
2. R vs Python
2. Data preparation in Python 
3. Introduction to Models in Python and R
4. Introduction to Model Validation


---
![fit](img/4_crisp.png)

---
![fit](img/4_crisp.png)
#Cross Industry Standard Process for Data Mining (CRISP-DM; Shearer, 2000),

---
#Stages of Model Development 
*Pay attention we will use this as a framework*
1. Data understanding
2. Data preparation
3. Modeling
4. Evaluation
5. Deployment (DDD)
5. Business Understanding

----
#Titanic: A Sample Case
![fit](img/titanic.jpg)


----
#Titanic: Case Description
The sinking of the RMS Titanic is one of the most infamous shipwrecks in history.  On April 15, 1912, during her maiden voyage, the Titanic sank after colliding with an iceberg, killing 1502 out of 2224 passengers and crew. 

One of the reasons that the shipwreck led to such loss of life was that there were not enough lifeboats for the passengers and crew. Although there was some element of luck involved in surviving the sinking, some groups of people were more likely to survive than others, such as women, children, and the upper-class.

----
#Titanic: Data Understanding
![fit](img/titanic2.png)

----
![fit](img/titanic2.png)

----
#What is the difference between the train and the test data?

----
#What variable are we trying to predict?


----
#What should be provided to Kaggle?


----
#What should be provided to Kaggle?
PassengerId,Survived
892,0
893,1
894,0
895,0
896,1
897,0
898,1
899,0
900,1
...
 
----
#Titanic: Data Understanding
VARIABLE DESCRIPTIONS:
PassengerId     Unique Identifier
survival        Survival  (0 = No; 1 = Yes)
pclass          Passenger Class (1 = 1st; 2 = 2nd; 3 = 3rd)
name            Name
sex             Sex
age             Age

----
#Titanic: Data Understanding (continued)
VARIABLE DESCRIPTIONS:
sibsp           Number of Siblings/Spouses Aboard
parch           Number of Parents/Children Aboard
ticket          Ticket Number
fare            Passenger Fare
cabin           Cabin
embarked        Port of Embarkation (C = Cherbourg; Q = Queenstown; S = Southampton)

----
#Titanic: Data Understanding (continued)
```{r}
titanic=read.csv(file="./data/titanic_train.csv",header=TRUE,sep=",")

str(titanic)
```

----
![fit](img/titanic3.png)

----
#Titanic: Data Understanding (continued)
```{r}
titanic=read.csv(file="./data/titanic_train.csv",header=TRUE,sep=",")

str(titanic)

summary(titanic)
```

----
![fit](img/titanic4.png)

----
# Titanic: Data Preparation
1. Deal with missing data.
2. Recode data to create features.



# Unix Scripting can be a useful way of splitting, searching and preprocessing text files.

----
#Unix Scripting: Creating a new file 
We will talk about sending the output of one command to another below (“pipes”), but an important command-line operator is the “redirection” operator “>”. With “>” you can send the result of your command-line processing to a file. So if you’re using grep (described next) to find all the lines that contain “foo”, you can create a new file with just these lines using redirection:

`grep 'foo' orig_file.txt > new_file.txt`


----
#Unix Scripting: Grep
A utility for pattern matching. grep is by far the most useful unix utility. While grep is conceptually very simple, an effective developer or data scientist will no doubt find themselves using grep dozens of times a day. grep is typically called like this: 

`grep [options] [pattern] [files]`
`grep 'foo bar' sample.txt` #Match all in file 
`grep -v 'foo bar' sample.txt` #Inverse Matching
`grep -R 'hee haw' .`   #Recursive matching. Here grep descends sub folders.
                                

----
# *R vs Python - Some thoughts from around the web*
* "The main advantage of Python over R is that it's a real programming language in the C family. It scales easily, so it's conceivable that anything you have in your sandbox can be used in production."
* "I use both Python (for data analysis ofcourse including numpy and scipy) and R next to each other. However, I use R exclusively to perform data analysis, and Python for more generic programming tasks (e.g. workflow control of a computer model)."

----
# *R vs Python - Some thoughts from around the web*
* "Many of the commenters brought up the fact that R, while maybe not as fast (although that too is debatable) is much better for data analysis because of the huge number of libraries, tests, and its syntactical advantages (i.e. using formulas)."
* "
----
# *iPython Notebooks*
* The IPython Notebook is a web-based interactive computational environment where you can combine code execution, text, mathematics, plots and rich media into a single document
* Use `ipython notebook` to launch
* (In the /scripts folder there is a script to install).

----
# *iPython - (1) Basics *
* The IPython Notebook

----
# *iPython - (2) More on Python *
* The IPython Notebook

----
# *iPython - (3) Regular Expressions *
* The IPython Notebook

----
# *iPython - (4) Introduction to Data Mining with Python *
* The IPython Notebook

----

----

# *This Time - Basic Data Preparation in Python*

----
#Data Preparation in Python?
* Meaning: What is the definition of the data?  How can we understand what it means?
* Data types: What is the data structure? 
* Provenance: What has the history of the data been?
* Distribution: Mean, Standard Deviation, Correlations, Skewness, Entropy

----
# *Introduction to Models and Validation*

----
#Data Preparation in Python?
* Meaning: What is the definition of the data?  How can we understand what it means?
* Data types: What is the data structure? 
* Provenance: What has the history of the data been?
* Distribution: Mean, Standard Deviation, Correlations, Skewness, Entropy

----
#Data Types - Variables
* Binary: Of two different categories. 
* Nominal: Specific categories of data that don't have a natural ordering. Model of vehicle.
* Ordinal: Categories of data that have a natural ordering.  `Education (high school, Undergrad, Masters, PhD)`
* Interval: Natural split between the levels `Satisfation (Rate on a scale of 1-10 how satisfied you are.)`
* Ratio: Intervale data with a natural 0 point. 


----
#[Correlations](http://www.tylervigen.com)


----
##"Entropy is a measure of disorder that can be applied to a set, such as one of our individual segments. Consider that we have a set of properties of members of the set, and each member has one and only one of the properties. ... Disorder corresponds to how mixed (impure) the segment is with respect to these properties of interest. So, for example, a mixed up segment with lots of write-offs and lots of non-write-offs would have high entropy."

```entropy = - p1 log (p1) - p2 log (p2) - ⋯
```

----
![fit](img/human-vs-alien.jpg)
##How do we understand the entropy among the *intelligent species* in the room?

----
#What would happen to any model predicting whether someone in the room is an alien.  


----
#Why is this relevant to creating a model?

----
![fit](img/men-vs-women.jpg)
#How would predicting a man vs. a woman be different?


----
![fit](img/men-vs-women.jpg)
#Among undergrads, is gender entropy higher or lower or same when comparing RPI vs. Harvard?


----
# *Data preparation*


----
# What do we need to *prepare* the *data?*

----
# *Data preparation*
* Cleaning: Are there incomplete records that should be removed or data inferred? 
* Feature Creation: Are there ways that data can be coded or processed to get more value?
* Merging Datasets: Often it is necessary to merge datasets based on a key. 
* Provenance: What has the history of the data been?
* Leakage: Beware of data "leaks"

----
#*Feature Creation* is when data is combined or process in such a way to provide it with alternative meaning.

----
![fit](img/slug.png) 

----
#Slugging percentage is a feature created from the raw data

----

#*Data Leakage* is when data collected in the historical data gives *information on the target variable.*

----
#*Data Leakage Example.* 
We want to predict total spend for an online shopper and find that the amount of tax paid is a great predictor of total spend.

Is this a problem?  If so why?
 
---
#*Data Modeling*


----
#What do we need to *model* the *data?*

----

# *Data Modeling*
* Data: Selected and valid dataset.
* Objective: Clear business insight into what we are trying to do. 
* Model Type: Understanding of type of model.
* Algorithm: Specific method of modeling data

----
#Types of Models
1. Classification
2. Regression
3. Similarity
4. Clustering
5. Co-occurence grouping
6. Profiling
7. Link prediction
8. Data reduction
9. Causal modeling

----
#*Evaluation*

----
# *Evaluation*
* Training set outcome: How well does the model predict for the training set.
* Testing prediction: How well does the model predict for a dataset "not" trained.
* Insights: Can I gain specific insights from the data

----
# *Evaluation*
* Comparison: How does prediction compare to other models? To a random prediction?
* Effect Size: In metrics that really matter (not p values) have can we understand identified relationships.


---
#Note two different potential outcomes *Deployment* and *Business Understanding*. What do we mean by each?

---

#What is *Deployment* likely to mean in this case?

---
# *Deployment*
* Employing mechanisms associated with DDD to implement algorithms in business process.
* Provide tools/training for repeated use of models by analysts

---
#What is *Business Understanding* likely to mean in this case?


---
# *Business Understanding*
* Associations of variables.
* Types of customers and associated behaviors

---
#Intro to R






