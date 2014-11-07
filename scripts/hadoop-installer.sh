#!/bin/bash

# written by Scott G Gavin 
# Oct 8 2014

#This code is designed to work with the Amazon AWS EC2 Ubuntu instance to 
#create a hadoop cluster using Pig and Hive, as desired.  It is version specific,
#and only designed to work with Ubuntu ________, and as such is not tested in other
#distributions or instances.
#All rights reserved

cd $HOME
clear
#these are here to make the link locations easy to change if desired
hadoop_link="http://www.interior-dsgn.com/apache/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz"
pig_link="http://apache.petsads.us/pig/pig-0.13.0/pig-0.13.0.tar.gz"
hive_link="http://apache.spinellicreations.com/hive/hive-0.12.0/hive-0.12.0.tar.gz"
mysqlDriver="http://dev.mysql.com/get/Download/Connector-J/mysql-connector-java-5.1.33.tar.gz"

#arrays
link[0]=$hadoop_link
link[1]=$pig_link
link[2]=$hive_link
name[0]="hadoop-1.2.1"
name[1]="pig-0.13.0"
name[2]="hive-0.12.0"
tarName[0]="hadoop-1.2.1.tar.gz"
tarName[1]="pig-0.13.0.tar.gz"
tarName[2]="hive-0.12.0.tar.gz"
tarName[3]="mysql-connector-java-5.1.33.tar.gz"
#variables
num=3
flag=0

bashrc="export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/"
sedPath=$bashrc
#make sure the user is running as root for the installations
if [ $EUID -eq 0 ]; then
{
	SUDO=''
}
else
{
	SUDO="sudo"
}
fi

sudo echo ""
#commands.  Makes it easy to make the commands verbose or quite. and ensure sudo
update="$SUDO apt-get -y update"
java="$SUDO apt-get -y install openjdk-7-jre-headless"
ssh="$SUDO apt-get -y install openssh-server"
mysqlInstall="$SUDO apt-get -y install mysql-server"
wget="wget -q"
tar="tar -xzf"

while [ $flag -ne 1 ]
do
	printf "Install Hadoop? [Y/n] "
	read Hadoop
	if [ "$Hadoop" == 'Y' ] || [ "$Hadoop" == 'y' ]; then
	{
		Hadoop=1
		bashrc=$bashrc"\nexport HADOOP_INSTALL=\"$HOME/${name[0]}\"\n"
		bashrc=$bashrc'export PATH=$PATH:$HADOOP_INSTALL/bin:$HADOOP_INSTALL/sbin\n'
		flag=1
	}
	elif [ "$Hadoop" == 'N' ] || [ "$Hadoop" == 'n' ]; then
	{
		Hadoop=0
		printf "Hadoop must be installed for Pig and Hive to function. Continue anyways? [Y/n] "
		read confirm
		if [ "$confirm" == 'Y' ] || [ "$confirm" == 'y' ]; then
		{
			flag=1
		}
		fi
	}
	else
	{
		printf "Unexpected Input\n"
	}
	fi
done
flag=0
while [ $flag -ne 1 ]
do
        printf "Install Pig? [Y/n] "
        read Pig
        if [ "$Pig" == 'Y' ] || [ "$Pig" == 'y' ]; then
        {
                Pig=1
		bashrc=$bashrc"export PIG_INSTALL=$HOME/${name[1]}\n"
		bashrc=$bashrc'export PATH=$PATH:$PIG_INSTALL/bin\n'
                flag=1
        }
        elif [ "$Pig" == 'N' ] || [ "$Pig" == 'n' ]; then
        {
                Pig=0
                flag=1
        }
        else
        {
                printf "Unexpected Input\n"
        }
        fi
done
flag=0
while [ $flag -ne 1 ]
do
        printf "Install Hive? [Y/n] "
        read Hive
        if [ "$Hive" == 'Y' ] || [ "$Hive" == 'y' ]; then
        {
                Hive=1
		bashrc=$bashrc"export HIVE_INSTALL=$HOME/${name[2]}\n"
		bashrc=$bashrc'export PATH=$PATH:$HIVE_INSTALL/bin\n'
                flag=1
		flag2=0
		while [ $flag2 -ne 1 ]
		do
       			printf "\tInstall Mysql with Hive? [Y/n] "
        		read Mysql
        		if [ "$Mysql" == 'Y' ] || [ "$Mysql" == 'y' ]; then
        		{
               	 		Mysql=1
                		flag2=1
       	 		}
		        elif [ "$Mysql" == 'N' ] || [ "$Mysql" == 'n' ]; then
		        {
                		Mysql=0
		                flag2=1
		        }
		        else
		        {
		                printf "Unexpected Input\n"
		        }
		        fi
		done
        }
        elif [ "$Hive" == 'N' ] || [ "$Hive" == 'n' ]; then
        {
                Hive=0
                flag=1
        }
        else
        {
                printf "Unexpected Input\n"
        }
        fi
done
flag=0


#this could be more efficient but im lazy
install[0]=$Hadoop
install[1]=$Pig
install[2]=$Hive

#update and install java
printf "\nUpdating the system..."
$update > /dev/null
printf "\t\t\tDone\nInstalling Java..."
$java > /dev/null
printf "\t\t\tDone\n"
if [ $Mysql -eq 1 ]; then
{
        printf "Installing Mysql..."
        $mysqlInstall
        printf "\t\t\tDone\n"
}
fi
printf "\nPlease enter the password you used for Mysql: "
read pass
printf "\n"
#download the tar.gz files needed
for ((flag=0; flag<num; flag++)) {
	if [ ${install[$flag]} -eq 1 ]; then
	{
		printf "Downloading ${tarName[$flag]}..."
		$wget ${link[$flag]}
		printf "\tDone\nUn-tarring ${tarName[$flag]}... "
		$tar ${tarName[$flag]}	
		printf "\tDone\nCleaning ${tarName[$flag]}..."
		rm ${tarName[$flag]}
		printf "\t\tDone\n"
	}
	fi
}
#install and configure ssh keys
printf "Setting up SSH..."
$ssh > /dev/null 
ssh-keygen -q -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
printf "\t\t\tDone\n"
#remember to >> this to the ~/.bashrc
printf "Editing bashrc file...\t\t\t"
printf "$bashrc" >> ~/.bashrc
printf "Done\n"
source ~/.bashrc
printf "Editing config files for:\n\t"
if [ ${install[0]} -eq 1 ]; then 
{
	printf "Hadoop:\n\t\t"
	printf "hadoop-env.sh"
		cd $HOME/${name[0]}/conf/
		printf "\n$sedPath\n" >> hadoop-env.sh
	printf "\tDone\n\t\t"
	printf "core-site.xml"
		cp core-site.xml core-site.xml.bak
		head -4 core-site.xml.bak > core-site.xml
		printf "\n<configuration>\n\t<property>\n\t\t<name>fs.default.name</name>\n\t\t<value>hdfs://localhost</value>\n\t</property>\n</configuration>" >> core-site.xml
	printf "\tDone\n\t\thdfs-site.xml"
		cp hdfs-site.xml hdfs-site.xml.bak
		head -4 hdfs-site.xml.bak > hdfs-site.xml
		printf "\n<configuration>\n\t<property>\n\t\t<name>dfs.replication</name>\n\t\t<value>1</value>\n\t</property>\n</configuration>" >> hdfs-site.xml
	printf "\tDone\n\t\tmapred-site.xml"
		cp mapred-site.xml mapred-site.xml.bak
		head -4 mapred-site.xml.bak > mapred-site.xml
		printf "\n<configuration>\n\t<property>\n\t\t<name>mapred.job.tracker</name>\n\t\t<value>localhost:8021</value>\n\t</property>\n</configuration>" >> mapred-site.xml
	printf "\tDone\n\tDone\n\t"
}
fi

if [ ${install[2]} -eq 1 ]; then
{
	hiveSite='<?xml version="1.0"?>\n'
	hiveSite=$hiveSite'<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n\n'
	if [ $Mysql -eq 1 ]; then
	{
		printf "Hive:\n\t\t"
		printf "hive-site.xml..."
			hiveSite=$hiveSite"<configuration>\n"

			#Connection URL
			hiveSite=$hiveSite"\t<property>\n"
			hiveSite=$hiveSite"\t\t<name>javax.jdo.option.ConnectionURL</name>\n"
			hiveSite=$hiveSite"\t\t<value>jdbc:mysql://localhost/hive_db?createDatabaseIfNotExist=true</value>\n"
			hiveSite=$hiveSite"\t\t<description>JDBC connect string for a JDBC metastore</description>\n"
			hiveSite=$hiveSite"\t</property>\n"

			#Connection Driver Name
			hiveSite=$hiveSite"\t<property>\n"
                        hiveSite=$hiveSite"\t\t<name>javax.jdo.option.ConnectionDriverName</name>\n"
                        hiveSite=$hiveSite"\t\t<value>com.mysql.jdbc.Driver</value>\n"
                        hiveSite=$hiveSite"\t\t<description>Driver class name for a JDBC metastore</description>\n"
                        hiveSite=$hiveSite"\t</property>\n"

			#jdbc driver
			hiveSite=$hiveSite"\t<property>\n"
                        hiveSite=$hiveSite"\t\t<name>hive.stats.jdbcdriver</name>\n"
                        hiveSite=$hiveSite"\t\t<value>com.mysql.jdbc.Driver</value>\n"
                        hiveSite=$hiveSite"\t\t<description>The JDBC driver for the database that stores temporary hive statistics.</description>\n"
                        hiveSite=$hiveSite"\t</property>\n"

			#Connection User Name
			hiveSite=$hiveSite"\t<property>\n"
                        hiveSite=$hiveSite"\t\t<name>javax.jdo.option.ConnectionUserName</name>\n"
                        hiveSite=$hiveSite"\t\t<value>root</value>\n"
                        hiveSite=$hiveSite"\t\t<description>username to use against metastore database</description>\n"
                        hiveSite=$hiveSite"\t</property>\n"
			
			#Connection Password
			hiveSite=$hiveSite"\t<property>\n"
                        hiveSite=$hiveSite"\t\t<name>javax.jdo.option.ConnectionPassword</name>\n"
                        hiveSite=$hiveSite"\t\t<value>"$pass"</value>\n"
                        hiveSite=$hiveSite"\t\t<description>password to use against metastore database</description>\n"
                        hiveSite=$hiveSite"\t</property>\n"

			#war file
			hiveSite=$hiveSite"\t<property>\n"
                        hiveSite=$hiveSite"\t\t<name>hive.hwi.war.file</name>\n"
                        hiveSite=$hiveSite"\t\t<value>lib/hive-hwi-0.12.0.war</value>\n"
                        hiveSite=$hiveSite"\t\t<description>This sets the path to the HWI war file</description>\n"
                        hiveSite=$hiveSite"\t</property>\n"
						hiveSite=$hiveSite"</configuration>\n"

			#write the file
			printf "$hiveSite" > $HOME/${name[2]}/conf/hive-site.xml
			mkdir $HOME/${name[2]}/conf/hadoop-conf/
			printf "$hiveSite" > $HOME/${name[2]}/conf/hadoop-conf/hive-site.xml
		printf "done\n"
		printf "\t\tInstalling mysql drivers..."
			cd $HOME/${name[2]}/lib/
			$wget $mysqlDriver
			$tar ${tarName[3]}
			cd mysql-connector-java-5.1.33
			mv mysql-connector-java-5.1.33-bin.jar ../
			cd ../
			rm -R mysql-connector-java-5.1.33
		printf "\tdone\n\tDone\n"
	}
	else
	{
		printf "Hive:\n\t\t"
		printf "hive-site.xml..."
			hiveSite=$hiveSite"<configuration>\n"
			hiveSite=$hiveSite"\t<property>\n"
			hiveSite=$hiveSite"\t\t<name>javax.jdo.option.ConnectionURL</name>\n"
			hiveSite=$hiveSite"\t\t<value>jdbc:derby:;databaseName="$HOME"/metaStore_db;create=true</value>\n"
			hiveSite=$hiveSite"\t\t<description>JDBC connect string for a JDBC metastore</description>\n"
			hiveSite=$hiveSite"\t</property>\n"
			hiveSite=$hiveSite"</configuration>"
			printf "$hiveSite" > $HOME/${name[2]}/conf/hive-site.xml
		printf "done\n"
		printf "\t\tCreating directories..."
			$SUDO mkdir -p /user/hive/warehouse
			$SUDO chmod a+rwx /user/hive/warehouse
			#hadoop fs -mkdir /user/hive/warehouse
			#hadoop fs -chmod g+w /user/hive/warehouse
			$SUDO mkdir -p /tmp/$USER
			$SUDO chmod a+rwx /tmp/$USER
			$SUDO mkdir -p /tmp/$USER/mapred/local
			$SUDO chmod a+rwx /tmp/$USER/mapred/local
			#hadoop fs -mkdir /tmp/$USER
			#hadoop fs -chmod g+w /tmp/$USER
		printf "\tdone\n\tdone\n"
	}
	fi
}
fi

printf "Done\n"
printf "\nInstallations complete\n"
exit

