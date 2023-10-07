#!/bin/bash
for i in $(ls resources/sql/*.sql); do 
	sqlite3 SQLITETest1.db < $i;
done
for i in $(ls resources/sql/second/*.sql); do 
	sqlite3 SQLITETest1.db < $i;
done
