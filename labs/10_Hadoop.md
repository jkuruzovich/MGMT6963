#**Technology Fundamentals for Analytics Lab**
##Jason Kuruzovich
---


#Agenda
- Understanding data compilation in Java
- Working with MapReduce
- 

---

#Compiling in Java
1. Ensure Hadoop is included in the classpath.
2. Compile the .java files .class files
3. Compress the .class files into a .JAR file
4. Pass the Jar file to Hadoop along with the text to process


---
Complete the Cloudera Homework Lab Lecture 1 and 2.  Read through 3, but instead follow details below. 

---

The Cloudera lab 3 has a overview of the average word length. I've included the solution to this, as this isn't a programing class. However,
it is important to be able to explin what is happening. 


Review the Average wordcount in /training/workspace/averagewordlength/src/solution.  

Run the solution using the example information that you had from Cloudera Lab 2.  Review the outcome.  

You can also view the Python solution at `/training/workspace/averagewordlength/python_sample_solution`

Run only the python mapper by running: 

`echo "There once was a class called Analytics where I ran a program that involved elephants." | python mapper.py`

Then run the python version 
```
{Python}

hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
-file /home/training/workspace/averagewordlength/python_sample_solution/mapper.py    -mapper /home/training/workspace/averagewordlength/python_sample_solution/mapper.py \
-file /home/training/workspace/averagewordlength/python_sample_solution/reducer.py   -reducer /home/training/workspace/averagewordlength/python_sample_solution/reducer.py \
-input shakespeare -output outputpython
```
---
1. What is the job of the mapper in this?  What does it output?  

2. What is the job of the reducer in the average word length.  What does it do?  

3. Compare the output of the Python and the Java outcomes.  They are different.  Why?

4. You can change just a few characters in the python code to make it the same as the Java. What line should you change?

5. Read through the lab for Lecture 8.  What is the purpose of Sqoop?  Is it more relevant for Map Reduce or HDFS?

6. Examine Lab 7.  Describe what an inverted Index is.  What might be an application that would find an inverted index to be relevant?

7. Also from Lab 8, describe whe Oozie is being used for? 