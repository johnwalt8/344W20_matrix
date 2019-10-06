# matrixDims.sh
#!/bin/bash

# print the dimensions of the matrix as the number of rows,
# followed by a space, then the number of columns. 

 rows=0
 columns=0
 previousRow=0

 while read matrixRow
 do
    columns=0
    rows=`expr $rows + 1`

    for i in $matrixRow
    do
        columns=`expr $columns + 1`
    done

    if [[ $previousRow -ne $columns && $previousRow -ne 0 ]]
    then
        echo "invalid matrix: not all rows the same length" >&2
        exit 13
    else
        previousRow=$columns
    fi
done < $1

echo "$rows $columns"