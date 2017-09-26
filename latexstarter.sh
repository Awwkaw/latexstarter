#!/usr/bin/env bash
#
# starttexproject -- sets up folders to start latexproject, with a given name and guess for chapternumber
# 
# Created by Thorbjoern E. K. Christensen

usage() { printf "%s" "\
Usage: latexstarter [OPTION] -n 'project name'
Example: latexstarter -n 'Thesis'
         latexstarter -c 33 -p ~/Documents/preamble.tex -t 'Creating latex projects' -k -n 'thesis'
Flags:
        -a      Set the name of the document author (default none set).
        -c      Set the number of chapters (must be interger -- default one empty chapter created).
        -f      turn figure folder off, default figure folder will be created.
        -h      display this message and stop the script
        -k      Compile on creation (a pdf showing title, date, author and chapternumbers wil be created, default off).
        -n      Name of project, must be given, will be the name of the directory, main texfile and bib file.
        -p      Path to preamble, Default is the file Preamble.tex in the same folder as this bash script.
        -t      Set the tile of the project (default is the name of the project).

  "


}

end_setup() {
    if [ ! -z "$kompile" ];
    then
        cd "$path"
        pdflatex "$mainfile"
    fi
}

main_setup() {
    mainfile="$path/$name.tex" 
    echo "\\input{texfiles/Preamble.tex}" >> "$mainfile"
    if [ ! -z "$title" ];
    then
        echo "
\\title{$title}" >> "$mainfile"
    else
        echo "
\\title{$name}" >> "$mainfile"
    fi
    if [ ! -z "$author" ];
    then
        echo "\\author{$author}" >> "$mainfile"
    fi
    echo "\\begin{document}
    
\\maketitle{}

    " >> "$mainfile"

    if [ ! -z "$chapternum" ];
    then
        i="0"
        while [ $i -lt "$chapternum" ];
        do
            i=$[$i+1]
            echo "\\include{texfiles/$i}" >> "$mainfile"
        done
    else
        echo "\\chapter{}" >> "$mainfile"
    fi
    echo "
\\end{document}" >> "$mainfile"

}

setup_files() {
    path="$(pwd)/$name"
    mkdir "$path"
    mkdir "$path/texfiles" 
    if [ -z "$figure" ]; 
    then
        mkdir "$path/figures"
    fi
    if [ ! -z "$chapternum" ];
    then
        i="0"
        while [ $i -lt "$chapternum" ];
        do
            i=$[$i+1]
            touch "$path/texfiles/$i.tex" 
            echo "\\chapter{}" >> "$path/texfiles/$i.tex"
        done
    fi
    if [ ! -z "$preamblepath" ];
    then
        cp "$preamblepath" "$path/texfiles/Preamble.tex"
    fi
    if [ -z "$preamblepath" ];
    then
        preamblepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
        cp "$preamblepath/Preamble.tex" "$path/texfiles/Preamble.tex"
    fi
    touch "$path/$name.tex"
    touch "$path/$name.tex.latexmain"
    touch "$path/$name.bib"
    echo "\\bibliography{$name}" >> "$path/texfiles/Preamble.tex"
}


get_args() {
    while getopts ":n:c:t:a:pkfh" opt; do
        case "$opt" in
            "n")
                name="$OPTARG" ;;
            "c")
                chapternum="$OPTARG" ;;
            "p")
                preamblepath="$OPTARG" ;;
            "a") 
                author="$OPTARG";;
            "t")
                title="$OPTARG";;
            "k")
                kompile="on" ;;
            "f")
                figure="off" ;; 
            "h") 
                usage; exit 1 ;;
            "\?")
                echo "invalid option -$OPTARG.";;
            ":")
                echo "option -$OPTARG requires an argument." ;;
        esac
    done            
}


main() {
    get_args "$@"
    setup_files
    main_setup    
    end_setup
}


main "$@"
