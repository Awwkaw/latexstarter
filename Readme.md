# LaTeXstarter
*A simple bash script trying to simplify the setup of fragmented LaTeX documents*

Simply add the path to the script to your .bashrc file, add your preamble to the same folder as latexstarter (the preamble must be named Preamble.tex) and run the command:

`latexstarter -n "name on project"`

to create the project structure.

for futher cotimisation, flags can be used:

        -a      Set the name of the document author (default none set).
        -c      Set the number of chapters (must be interger -- default one empty chapter created).
        -f      turn figure folder off, default figure folder will be created.
        -h      display this message and stop the script
        -k      Compile on creation (a pdf showing titlem date, author and chapternumbers wil be created, default off).
        -m      Minimal preamble, will overwrite the standard preamble, but not a specific preamble
        -n      Name of project, must be given, will be the name of the directory, main texfile and bib file.
        -p      Path to preamble, Default is the file .Preamble.tex in the same folder as this bash script.
        -s      Create a texfile in figures with class standalone, use for creating figueres, only created if f is not given       
        -t      Set the tile of the project (default is the name of the project).



