triggers.sql has to be in a different folder than the others
because the automated run sql command in the java file will
not properly run triggers.sql because of the crazy formating in that file


we could resolve that by creating a better sql parser in the java land,
and if this were a buisness solution that is what I would do. 

As it stands I am not getting paid enough (or you know at all :p), nor do I currently have the time
to write a comprehensive sql parser. Thus in order to meet assigment requirements
within a reasonable amount of time and energy, we special case triggers.sql out

is this a desireable solution? No.

Does it work? Darn straight it does.
