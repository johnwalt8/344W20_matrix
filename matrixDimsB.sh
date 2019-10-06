# print the dimensions of the matrix as the number of rows,
# followed by a space, then the number of columns. 

rows=`wc -l < $1`
total=`wc -w < $1`
columns=`expr $total / $rows`
decColumns=$(bc <<< "scale=2;$total / $rows")
intColumns=$(bc <<< "scale=2;$columns / 1")

if [[ $intColumns != $decColumns ]]
then
        echo "invalid matrix: not all rows the same length" >&2
        exit 13
fi
 
echo "$rows $columns"