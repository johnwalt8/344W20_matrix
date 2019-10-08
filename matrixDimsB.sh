# print the dimensions of the matrix as the number of rows,
# followed by a space, then the number of columns. 
tempFileName="tempfile$$"

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
        rm -f "$tempFileName"
        exit 13
fi      

rows=`wc -l < $subjectFile`
total=`wc -w < $subjectFile`
columns=`expr $total / $rows`
decColumns=$(bc <<< "scale=2;$total / $rows")
intColumns=$(bc <<< "scale=2;$columns / 1")

if [[ $intColumns != $decColumns ]]
then
        echo "invalid matrix: not all rows the same length" >&2
        exit 13
fi
 
echo "$rows $columns"

rm -f "$tempFileName"