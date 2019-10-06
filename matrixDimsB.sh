# print the dimensions of the matrix as the number of rows,
# followed by a space, then the number of columns. 

rows=`wc -l < $1`
total=`wc -w < $1`
columns=`expr $total / $rows`
 
echo "$rows $columns"