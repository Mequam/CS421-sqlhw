default: build
	echo '[*] program compiled sucessfully'
	echo 

debug-GridRender: GridRender.class 
	java GridRender

GridRender.class: GridRender.java 
	javac GridRender.java 


#delete the db and rebuild
remakeall: cleanall build 
	echo '[*] remake'

# setup and run the program, then throw testing data into the database,
# and plop down in the db for further tests by the uer
debug: rerun 
	#sqlite3 *.db < ./project_files/test.sql
	sqlite3 *.db
	echo

#delete everything but the database, then rebuild
remake: clean build
	echo '[*] finished remake'
	echo 

#run the Main class with the proper class path set 
#to access sqlite
run: build
	echo '[*] running the program!'
	java -classpath .:sqlite-jdbc-3.43.0.0.jar Main 

# remake everything, including the database, then run the program
rerun: remakeall run 
	echo '[*] finished rerun'

#create the java program
build:
	echo '[*] building the program!'
	find . -name \*.java > to_build.txt 
	javac @to_build.txt 

clean:
	find . -name \*.class -delete
	find . -name to_build.txt -delete 

cleanall: clean 
	find . -name \*.db -delete
