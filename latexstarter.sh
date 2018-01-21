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
        -d      Uses \\chapter*{} instead of \\chapter{}.
        -f      turn figure folder off, default figure folder will be created.
        -h      display this message and stop the script
        -k      Compile on creation (a pdf showing title, date, author and chapternumbers wil be created, default off).
        -n      Name of project, must be given, will be the name of the directory, main texfile and bib file.
        -m      Minimal preamble, will overwrite the standard preamble, but not a specific preamble
        -p      Path to preamble, Default is the file Preamble.tex in the same folder as this bash script.
        -s      Create a texfile in figures with class standalone, use for creating figueres, only created if f is not given, also creates a standard file for plotting data.
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
    echo "\\documentclass[oneside,english,onecolumn,openbib,a4paper]{memoir}" >> "$mainfile"
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
                echo "\\input{texfiles/$i}" >> "$mainfile"
        done
    else
        if [ "$chapterstar" ] ;
        then 
            echo "\\chapter\*{}" >> "$mainfile"
        else 
            echo "\\chapter{}" >> "$mainfile"
        fi
    fi
    echo "
\\end{document}" >> "$mainfile"

}

minimal_preamble() {
    preamble="$(pwd)/$name/texfiles/Preamble.tex"
    touch "$preamble"
    echo "\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{mathtools,amssymb,bm}" >> "$preamble"
}

standalone_fig_setup() {
    standfile="$(pwd)/$name/figures/standfig.tex"
    touch "$standfile"
    echo "\\documentclass[border=0.5]{standalone}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{mathtools,amsmath}
\\usepackage{tikz}
\\usepackage{pgfplots}
\\usepgfplotslibrary{external}
\\tikzexternalize
\\tikzset{external/force remake}
\\begin{document}
\\begin{tikzpicture}

\\end{tikzpicture}
\\end{document} " >> "$standfile"
        standplot="$(pwd)/$name/figures/standplot.tex"
    touch "$standplot"
    echo "\\documentclass[border=0.5]{standalone}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{mathtools,amsmath}
\\usepackage{tikz}
\\usepackage{pgfplots}
\\usepgfplotslibrary{external}
\\tikzexternalize
\\tikzset{external/force remake}

\\begin{document}
\\begin{tikzpicture}
\\begin{axis}

\\end{axis}
\\end{tikzpicture}
\\end{document} " >> "$standplot"
}


setup_files() {
    path="$(pwd)/$name"
    mkdir "$path"
    mkdir "$path/texfiles" 
    if [ -z "$figure" ]; 
    then
        mkdir "$path/figures"
        if [ "$standalone" ];
        then
            standalone_fig_setup
        fi
    fi
    if [ ! -z "$chapternum" ];
    then
        i="0"
        if [ "$chapterstar" ];
        then 
                while [ $i -lt "$chapternum" ];
                do
                    i=$[$i+1]
                    touch "$path/texfiles/$i.tex" 
                    echo "\\chapter\*{}" >> "$path/texfiles/$i.tex"
                done
        else
                while [ $i -lt "$chapternum" ];
                do
                    i=$[$i+1]
                    touch "$path/texfiles/$i.tex" 
                    echo "\\chapter{}" >> "$path/texfiles/$i.tex"
                done
        fi
    fi
    if [ "$preamblepath" ];
    then
        cp "$preamblepath" "$path/texfiles/Preamble.tex"
        touch "$path/$name.bib"
        echo "\\bibliography{$name}" >> "$path/texfiles/Preamble.tex"
    elif [ "$minipreamble" ];
    then
        minimal_preamble
    else
        preamblepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
        cp "$preamblepath/Preamble.tex" "$path/texfiles/Preamble.tex"
        echo "$([ -z "$minipreamble" ])"
        touch "$path/$name.bib"
        echo "\\bibliography{$name}" >> "$path/texfiles/Preamble.tex"
    fi
    touch "$path/$name.tex"
    touch "$path/$name.tex.latexmain"
}


get_args() {
    while getopts ":n:c:t:a:pkfsmh" opt; do
        case "$opt" in
            "n")
                name="$OPTARG" ;;
            "c")
                chapternum="$OPTARG" ;;
            "d")
                chapterstar="on" ;;
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
            "s")
                standalone="on" ;;
            "m")
                minipreamble="on" ;;
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
