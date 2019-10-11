# matrixDims.sh
#!/bin/bash

# print the dimensions of the matrix as the number of rows,
# followed by a space, then the number of columns. 
tempFileName="tempfile$$"

trap "rm -f $tempFileName" EXIT
trap "echo ' SIGNAL received: deleting temp file then exiting'; rm -f $tempFileName; exit 13" INT HUP TERM

if [[ $# == 1 ]]
then
        if [[ -r $1 ]]
        then
                subjectFile=$1
        else
                echo "file is not readable" >&2
                exit 13
        fi
elif [[ $# == 0 ]]
then
        echo "enter a tab delimited matrix, then hit CTRL+D:"
        cat > $tempFileName
        subjectFile=$tempFileName
else
        echo "invalid number of arguments" >&2
        exit 13
fi      

rows=`wc -l < $subjectFile`
total=`wc -w < $subjectFile`
columns=`expr $total / $rows` # bash integer math rounds down
columnsRoundedUp=$(( ($total + ($rows-1)) / $rows ))

if [[ $columns != $columnsRoundedUp ]]
then
        echo "invalid matrix: not all rows the same length" >&2
        exit 13
fi
 
echo "$rows $columns"