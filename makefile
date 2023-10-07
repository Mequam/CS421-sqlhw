default: build
	echo '[*] program compiled sucessfully'
	echo
rebuild: cleanall build 
	echo '[*] rebuild'
debug: remake run
	echo '[*] debug finished'
	echo
remake: clean build
	echo '[*] finished remake'
	echo
run: build
	echo '[*] running the program!'
	java -classpath .:sqlite-jdbc-3.43.0.0.jar DBTest
rerun: rebuild run 
	echo '[*] finished rerun'
build:
	echo '[*] building the program!'
	find . -name \*.java > to_build.txt 
	javac @to_build.txt
	echo '[*] creating database'
	./project_files/makedb.sh
clean:
	find . -name \*.class -delete
	rm to_build.txt 
cleanall: clean 
	rm *.db
